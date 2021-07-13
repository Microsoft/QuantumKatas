// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT license.

using System;
using System.Linq;
using System.Collections.Generic;
using Microsoft.Extensions.Logging;
using Microsoft.Jupyter.Core;
using Microsoft.Quantum.IQSharp;
using Microsoft.Quantum.IQSharp.Jupyter;
using Microsoft.Quantum.Simulation.Common;
using Microsoft.Quantum.Simulation.Simulators;
using Microsoft.Quantum.QsCompiler.SyntaxTree;

namespace Microsoft.Quantum.Katas
{
    public class KataMagic : AbstractKataMagic
    {
        /// <summary>
        /// IQ# Magic that enables executing the Katas on Jupyter.
        /// </summary>
        public KataMagic(IOperationResolver resolver, ILogger<KataMagic> logger, ISnippets snippets, IConfigurationSource configurationSource)
            : base(resolver, logger)
        {
            this.Name = $"%kata";
            this.Documentation = new Microsoft.Jupyter.Core.Documentation
            {
                Summary = "Executes a single test.",
                Description = "Executes a single test, and reports whether the test passed successfully.",
                Examples = new []
                {
                    "To run a test called `Test`:\n" +
                    "```\n" +
                    "In []: %kata T101_StateFlip \n" +
                    "       operation StateFlip (q : Qubit) : Unit is Adj + Ctl {\n" +
                    "           // The Pauli X gate will change the |0⟩ state to the |1⟩ state and vice versa.\n" +
                    "           // Type X(q);\n" +
                    "           // Then run the cell using Ctrl/⌘+Enter.\n" +
                    "\n" +
                    "           // ...\n" +
                    "       }\n" +
                    "Out[]: Qubit in invalid state. Expecting: Zero\n" +
	                "       \tExpected:\t0\n"+
	                "       \tActual:\t0.5000000000000002\n" +
                    "       Try again!\n" +
                    "```\n"
                }
            };
            this.Snippets = snippets;
            this.ConfigurationSource = configurationSource;
        }

        /// <summary>
        /// The list of user-defined Q# code snippets from the notebook.
        /// </summary>
        protected ISnippets Snippets { get; }

        /// <summary>
        ///     The configuration source used by this magic command to control
        ///     simulation options (e.g.: dump formatting options).
        /// </summary>
        protected IConfigurationSource ConfigurationSource { get; }

        ///<inheritdoc/>
        protected override IEnumerable<QsNamespaceElement> GetDeclaredCallables(string code, IChannel channel)
        {
            var result = Snippets.Compile(code);

            foreach (var m in result.warnings) { channel.Stdout(m); }

            return result.Elements;
        }

        /// <summary>
        /// Returns the userAnswer as an operation so that we could verify
        /// if userAnswer is correct by running appropriate test. 
        /// </summary>
        protected virtual OperationInfo FindSolution(string userAnswer)
        {
            var solution = Resolver.Resolve(userAnswer);

            Logger.LogDebug($"Found solution operation {solution}");

            if (solution == null)
            {
                throw new Exception($"Solution not found for : {solution}");
            }
            return solution;
        }

        /// <inheritdoc/>
        protected override void SetAllAnswers(OperationInfo skeletonAnswer, string userAnswer)
        {
            var solution = FindSolution(userAnswer);
            AllAnswers[skeletonAnswer] = FindSolution(userAnswer);
        }

        /// <summary>
        /// Logs the messages with rich Jupyter formatting for simulators of the type QuantumSimulator
        /// and stack traces for exceptions for the other simulators
        /// </summary>
        protected override SimulatorBase SetDisplay(SimulatorBase simulator, IChannel channel)
        {
            SimulatorBase sim = base.SetDisplay(simulator, channel);

            if(sim is QuantumSimulator qsim)
            {
                // To avoid double printing
                qsim.OnLog -= channel.Stdout;
                // To display diagnostic output with rich Jupyter formatting
                return qsim.WithJupyterDisplay(channel, ConfigurationSource);
            }
            else
            {
                return sim;
            }
        }
    }
}
