// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT license.

using System;
using System.Collections.Generic;
using Microsoft.Extensions.Logging;
using Microsoft.Jupyter.Core;
using Microsoft.Quantum.IQSharp;
using Microsoft.Quantum.Simulation.Common;
using Microsoft.Quantum.QsCompiler.SyntaxTree;

namespace Microsoft.Quantum.Katas
{
    public class CheckKataMagic : AbstractKataMagic
    {
        /// <summary>
        /// IQ# Magic that checks that the reference implementation of a Kata's test runs successfully.
        /// </summary>
        public CheckKataMagic(IOperationResolver resolver, ILogger<CheckKataMagic> logger, ICompilerService compiler)
            : base(resolver, logger)
        {
            this.Name = $"%check_kata";
            this.Documentation = new Microsoft.Jupyter.Core.Documentation
            {
                Summary = "Checks the reference implementation for a single kata's test.",
                Description =
                    "Substitutes the reference implementation for a " +
                    "single task into the cell, and reports whether the test " +
                    "passed successfully using the reference implementation.",
                Examples = new []
                {
                    "To check a test called `Test`:\n" +
                    "```\n" +
                    "In []: %check_kata T101_StateFlip \n" +
                    "       operation StateFlip (q : Qubit) : Unit is Adj + Ctl {\n" +
                    "           // The Pauli X gate will change the |0⟩ state to the |1⟩ state and vice versa.\n" +
                    "           // Type X(q);\n" +
                    "           // Then run the cell using Ctrl/⌘+Enter.\n" +
                    "\n" +
                    "           // ...\n" +
                    "       }\n" +
                    "Out[]: Success!\n" +
                    "```\n"
                }
            };
            this.Compiler = compiler;
        }

        /// <summary>
        /// The list of user-defined Q# code snippets from the notebook.
        /// </summary>
        protected ICompilerService Compiler { get; }

        /// <summary>
        /// Semi-compiles the given code. Checks there is only one operation defined in the code,
        /// and returns its corresponding OperationInfo
        /// The compiler does this on a best effort basis, and in particular without relying on any context and/or type information,
        /// so it will return the operation even if the compilation fails.
        /// </summary>
        protected override IEnumerable<QsNamespaceElement> GetDeclaredCallables(string code, IChannel channel) =>
               Compiler
               .IdentifyElements(code);

        /// <summary>
        /// Returns the reference implementation for the test's answer in the workspace for the given userAnswer.
        /// It does this by finding another operation with the same name as the <c>userAnswer</c> but in the 
        /// skeletonAnswer's namespace and with <c>_Reference</c> added to the userAnswer's name.
        /// </summary>
        protected virtual OperationInfo FindReferenceImplementation(OperationInfo skeletonAnswer, string userAnswer)
        {
            var referenceAnswer = Resolver.Resolve($"{skeletonAnswer.Header.QualifiedName.Namespace}.{userAnswer}_Reference");
            Logger.LogDebug($"Found Reference answer {referenceAnswer} for {userAnswer}");

            if (referenceAnswer == null)
            {
                throw new Exception($"Reference answer not found for : {userAnswer}");
            }
            return referenceAnswer;
        }

        /// <inheritdoc/>
        protected override void SetAllAnswers(OperationInfo skeletonAnswer, string userAnswer)
        {
            var referenceAnswer = FindReferenceImplementation(skeletonAnswer, userAnswer);
            AllAnswers[skeletonAnswer] = referenceAnswer;
        }

        /// <inheritdoc/>
        protected override SimulatorBase SetDisplay(SimulatorBase simulator, IChannel channel)
        {
            SimulatorBase sim = base.SetDisplay(simulator, channel);

            var simHasWarnings = false;

            sim.OnLog -= channel.Stdout; // Unsubscribe from base Logging
            sim.OnLog += (msg) =>
            {
                simHasWarnings = msg?.StartsWith("[WARNING]") ?? simHasWarnings;
                if(simHasWarnings == true)
                {
                    throw new Exception($"Errors on {sim.GetType().Name} : " + msg);
                }
                else
                {
                    channel.Stdout($"Msg from {sim.GetType().Name} : " + msg);
                }
            };
            return sim;
        }
    }
}
