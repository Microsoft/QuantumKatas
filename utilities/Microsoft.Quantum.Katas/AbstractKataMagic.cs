// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT license.

using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using System.Linq;
using System.Reflection;
using Microsoft.Extensions.Logging;
using Microsoft.Jupyter.Core;
using Microsoft.Quantum.IQSharp;
using Microsoft.Quantum.IQSharp.Common;
using Microsoft.Quantum.Simulation.Common;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Simulators;
using Microsoft.Quantum.QsCompiler.SyntaxTree;

namespace Microsoft.Quantum.Katas
{
    public abstract class AbstractKataMagic : MagicSymbol
    {
        /// <summary>
        /// IQ# Magic that enables executing the Katas on Jupyter.
        /// </summary>
        public AbstractKataMagic(IOperationResolver resolver, ILogger? logger = null)
        {
            this.Kind = SymbolKind.Magic;
            this.Execute = this.Run;

            this.Resolver = resolver;
            this.Logger = logger;

            this.AllAnswers = new Dictionary<OperationInfo, OperationInfo>();
        }

        /// <summary>
        /// The Resolver lets us find compiled Q# operations from the workspace
        /// </summary>
        protected IOperationResolver Resolver { get; }
        
        /// <summary>
        /// Logger to log messages to the jupyter console.
        /// </summary>
        protected ILogger? Logger { get; }

        /// <summary>
        /// A Dictionary which stores the relevant answer to verify the appropriate answer
        /// For KataMagic, it verfies the <c>userAnswer</c>
        /// For CheckKataMagic, it verfies the <c>referenceImplementation</c>
        /// </summary>
        protected Dictionary<OperationInfo, OperationInfo> AllAnswers { get; }

        /// <summary>
        /// What this Magic does when triggered. It will:
        /// - find the Test to execute based on the given name,
        /// - compile/semi-compile the code after it found the full/partial user's answer.
        /// - run (simulate) the test and report its result.
        /// </summary>
        protected virtual async Task<ExecutionResult> Run(string input, IChannel channel)
        {
            Assembly asm = Assembly.GetExecutingAssembly();
            Logger.LogDebug($"Asm for the magics in quantumKatas : {asm}");

            channel = channel.WithNewLines();

            // Expect exactly two arguments, the name of the Kata and the user's answer (code).
            var args = input?.Split(new char[] { ' ', '\n', '\t' }, 2);
            if (args == null || args.Length != 2)
            {
                channel.Stderr("Invalid parameters. Usage: `%kata Test \"Q# operation\"`");
                return ExecuteStatus.Error.ToExecutionResult();
            }

            var name = args[0];
            var code = args[1];

            var test = FindTest(name);
            if (test == null)
            {
                channel.Stderr($"Invalid test name: {name}");
                return ExecuteStatus.Error.ToExecutionResult();
            }

            var userAnswer = Compile(code, channel);
            if (userAnswer == null) { return ExecuteStatus.Error.ToExecutionResult(); }

            return Simulate(test, userAnswer, channel)
                ? "Success!".ToExecutionResult()
                : ExecuteStatus.Error.ToExecutionResult();
        }

        /// <summary>
        /// Returns the OperationInfo with the Test to run based on the given name.
        /// </summary>
        protected virtual OperationInfo FindTest(string testName) =>
             Resolver.Resolve(testName);

        /// <summary>
        /// Compiles or semi-compiles the given code depending upon the situation
        /// Checks there is only one operation defined in the code,
        /// and returns its corresponding userAnswer
        /// </summary>
        protected virtual string? Compile(string code, IChannel channel)
        {
            try
            {
                var result = GetDeclaredCallables(code, channel);

                // Gets the names of all the operations found for this snippet
                var opsNames =
                        result
                        .Where(e => e.IsQsCallable)
                        .Select(e => e.ToFullName().WithoutNamespace(Microsoft.Quantum.IQSharp.Snippets.SNIPPETS_NAMESPACE))
                        .OrderBy(o => o)
                        .ToArray();

                if (opsNames.Length > 1)
                {
                    channel.Stdout("Expecting only one Q# operation in code. Using the first one");
                }

                return opsNames.First();
            }
            catch (CompilationErrorsException c)
            {
                foreach (var m in c.Errors) channel.Stderr(m);
                return null;
            }
            catch (Exception e)
            {
                Logger?.LogWarning(e, "Unexpected error.");
                channel.Stderr(e.Message);
                return null;
            }
        }

        /// <summary>
        /// Compiles or semi-compiles the given code depending upon the situation
        /// and returns the corresponding QsNamespaceElement Array
        /// </summary>
        protected abstract IEnumerable<QsNamespaceElement> GetDeclaredCallables(string code, IChannel channel);

        /// <summary>
        /// Executes the given kata using the <c>relevantAnswer</c> as the actual answer.
        /// To do this, it finds another operation with the same name but in the Kata's namespace
        /// (by calling <c>FindSkeltonAnswer</c>) and replace its implementation with the <c>relevantAnswer</c>
        /// in the simulator.
        /// </summary>
        protected virtual bool Simulate(OperationInfo test, string userAnswer, IChannel channel)
        {
            var skeletonAnswer = FindSkeletonAnswer(test, userAnswer);
            if (skeletonAnswer == null)
            {
                channel.Stderr($"Invalid task: {userAnswer}");
                return false;
            }
            SetAllAnswers(skeletonAnswer, userAnswer);

            SimulatorBase? currSim = null;
            try
            {
                List<SimulatorBase> testSimulators = CreateSimulators(channel, test);

                if(testSimulators.Count() == 0)
                {
                    throw new Exception($"Got no simulator(s) for the test {test.FullName}");
                }

                foreach(SimulatorBase testSim in testSimulators)
                {
                    Logger.LogDebug($"Simulating test {test.FullName} on {testSim.GetType().Name}");

                    currSim = SetDisplay(testSim, channel);

                    // Register all solutions to previously executed tasks (including the current one)
                    foreach (KeyValuePair<OperationInfo, OperationInfo> answer in AllAnswers) {
                        Logger.LogDebug($"Registering {answer.Key.FullName}");
                        currSim.Register(answer.Key.RoslynType, answer.Value.RoslynType, typeof(ICallable));
                    }

                    var value = test.RunAsync(currSim, null).Result;

                    channel.Stdout($"Success on {currSim.GetType().Name}!");

                    if (currSim is IDisposable dis) { dis.Dispose(); }
                }

                return true;
            }
            catch (AggregateException agg)
            {
                foreach (var e in agg.InnerExceptions) { channel.Stderr(e.Message); }
                channel.Stderr(currSim != null ? $"Test failed on {currSim.GetType().Name}!" : "Test failed.");
                channel.Stderr($"Try again!");
                return false;
            }
            catch (Exception e)
            {
                channel.Stderr(e.Message);
                channel.Stderr(currSim != null ? $"Test failed on {currSim.GetType().Name}!" : "Test failed.");
                channel.Stderr($"Try again!");
                return false;
            }
        }

        /// <summary>
        /// Returns the original shell for the test's answer in the workspace for the given userAnswer.
        /// It does this by finding another operation with the same name as the <c>userAnswer</c> but in the 
        /// test's namespace
        /// </summary>
        protected virtual OperationInfo FindSkeletonAnswer(OperationInfo test, string userAnswer)
        {
            var skeletonAnswer = Resolver.Resolve($"{test.Header.QualifiedName.Namespace}.{userAnswer}");
            Logger.LogDebug($"Resolved {userAnswer} to {skeletonAnswer.FullName}");
            return skeletonAnswer;
        }

        /// <summary>
        /// Sets the <c>relevantAnswer</c> using <c>userAnswer</c> corresponding to the
        /// <c>skeletonAnswer</c> to be verified by magic.
        /// For KataMagic, it verfies the <c>userAnswer</c>
        /// For CheckKataMagic, it verfies the <c>referenceImplementation</c>
        /// </summary>
        protected abstract void SetAllAnswers(OperationInfo skeletonAnswer, string userAnswer);

        /// <summary>
        /// Creates the instance of the simulator(s) on which
        /// the test operation is to be run
        /// These simulators are read from the configuration in @Test attribute
        ///
        /// [TODO] Support custom simulator(s) in Q# project
        /// </summary>
        protected virtual List<SimulatorBase> CreateSimulators(IChannel channel, OperationInfo test)
        {
            List<SimulatorBase> testSimulators = new List<SimulatorBase> ();

            var testSimNames = GetSimNamesFromTestAttribute(test);
            Logger.LogDebug($"Simulator count for {test.FullName} = {testSimNames.Count()}");

            List<Assembly> simulatorAssemblies = GetSimulatorAssemblies();

            foreach(var simName in testSimNames)
            {
                Logger.LogDebug($"Trying to create simulator of the type : {simName}");

                object? simulator = null;
                bool isSimQualified = simName.Contains('.');
                string simTypeName = isSimQualified ? simName : "Microsoft.Quantum.Simulation.Simulators." + simName ;

                try
                {
                    foreach(Assembly asm in simulatorAssemblies)
                    {
                        // Gets the Type object with the specified name in the assembly instance
                        // https://docs.microsoft.com/en-us/dotnet/api/system.reflection.assembly.gettype?view=net-5.0#System_Reflection_Assembly_GetType_System_String_
                        Type? simType = asm.GetType(simTypeName);

                        // Using binding flags to invoke parameterised constructor with default values
                        // For more details, please refer https://stackoverflow.com/questions/2501143/activator-createinstancetype-for-a-type-without-parameterless-constructor
                        simulator = (simType != null)
                            ?   Activator.CreateInstance
                                (
                                    type : simType,
                                    bindingAttr : BindingFlags.CreateInstance |
                                                BindingFlags.Public |
                                                BindingFlags.Instance |
                                                BindingFlags.OptionalParamBinding,
                                    binder : null,
                                    args : null,
                                    culture : null
                                )
                            :   null;

                        if(simulator != null)
                        {
                            if(simulator is SimulatorBase sim)
                            {
                                testSimulators.Add(sim);
                            }
                            break;
                        }
                    }
                    string errorMessage = $"Error while creating an instance of {simName}. " +
                        $"{simName} not a valid execution target. " +
                        "Either consider using a fully qualified name for the simulator. " +
                        "or see that you aren't using Custom simulators as part of Q# projects." ;
                    if(simulator == null)
                        throw new Exception(errorMessage);
                }
                catch (Exception ex)
                {
                    channel.Stderr(ex.Message);
                    throw new Exception("Error while creating desired simulator(s) for test.");
                }
            }
            return testSimulators;
        }

        /// <summary>
        /// Returns the list of simulator names specified via @Test attribute
        /// </summary>
        protected virtual List<string> GetSimNamesFromTestAttribute(OperationInfo test)
        {
            List<string> testSimNames = test.Header.Attributes.Where(
                attribute =>
                // Since QsNullable<UserDefinedType>.Item can be null,
                // we use a pattern match here to make sure that we have
                // an actual UDT to compare against.
                attribute.TypeId.Item is UserDefinedType udt &&
                udt.Name == "Test"
	        )
            .Select(
                attribute =>
                    attribute.Argument.TryAsStringLiteral()
            )
            .Where(value => value != null)
            // The Where above ensures that all elements are non-nullable,
            // but the C# compiler doesn't quite figure that out, so we
            // need to help it with a no-op that uses the null-forgiving
            // operator.
            .Select(value => value!)
            .ToList() ;

            return testSimNames;
        }

        /// <summary>
        /// Returns the list of relevant assemblies to search for simulators.
        /// </summary>
        protected virtual List<Assembly> GetSimulatorAssemblies()
        {
            List<Assembly> simulatorAssemblies = new List<Assembly>()
            {
                typeof(QuantumSimulator).Assembly,
                typeof(CounterSimulator).Assembly
            };

            foreach(Assembly asm in simulatorAssemblies)
            {
                Logger.LogDebug($"Assembly to look for simulator(s): {asm.FullName}");
            }

            return simulatorAssemblies;
        }

        /// <summary>
        /// Configures the display method for the simulators.
        /// Default behaviour is to log the messages in text format provided by the simulator
        /// </summary>
        protected virtual SimulatorBase SetDisplay(SimulatorBase simulator, IChannel channel)
        {
            simulator.DisableExceptionPrinting();
            simulator.DisableLogToConsole();

            simulator.OnLog += channel.Stdout;
            simulator.OnDisplayableDiagnostic += channel.Display;

            return simulator;
        }
    }
}
