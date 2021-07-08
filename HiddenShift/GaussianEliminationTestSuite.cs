using Microsoft.Quantum.Simulation.XUnit;
using Microsoft.Quantum.Simulation.Simulators;
using Xunit.Abstractions;
using System.Diagnostics;

namespace Quantum.Kata.HiddenShift
{
    public class GaussianEliminationTestSuite
    {
        private readonly ITestOutputHelper output;

        public GaussianEliminationTestSuite(ITestOutputHelper output)
        {
            this.output = output;
        }
        
        // Use another namespace so tests are seperated in VSTest
        [OperationDriver(TestNamespace = "Quantum.Kata.HiddenShift.GaussianEliminationTests", DisplayName = "Gaussian Elimination")]
        public void TestGaussianElimination(TestOperation op)
        {
            using (var sim = new QuantumSimulator())
            {
                // OnLog defines action(s) performed when Q# test calls function Message
                sim.OnLog += (msg) => { output.WriteLine(msg); };
                sim.OnLog += (msg) => { Debug.WriteLine(msg); };
                op.TestOperationRunner(sim);
            }
        }
    }
}
