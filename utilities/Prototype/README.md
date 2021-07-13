# Welcome!

The Protototype kata is an attempt to serve as check for validating the functionality of `%kata` and `%check_kata` magic.

You can [run the Prototype kata as a Jupyter Notebook](https://mybinder.org/v2/gh/Microsoft/QuantumKatas/main?filepath=utilities%2FPrototype%2FPrototype.ipynb)!

#### Theory
* We need to check if things work as expected for the set {`QuantumSimulator`, `CounterSimulator` and `ToffoliSimulator`}.
* Tests using {`ResourcesEstimator` and `QCTraceSimulator`} would be written in C# or Python, estimating some Q# code and analyzing the results outside of Q#, so not in scope of magic validation.
* Tests that pass on `CounterSimulator` only should use counting operations such as `GetOracleCallsCount` and `ResetOracleCallsCount`. The other two simulators don't define them, so those tests should fail at runtime.
* Tests that pass on `QuantumSimulator` but not on `ToffoliSimulator` should use gates other than `X`, `CNOT` and controlled variants of those - a Hadamard will fail immediately, since it's not supported by `ToffoliSimulator`.
    > Note : No test can be designed such that it passes on `QuantumSimulator` but fails on `CounterSimulator`, since the latter offers all functionality of the former.
* Tests that pass on `ToffoliSimulator` only should allocate and manipulate a lot of qubits - full state simulator should run out of memory trying to do this.

#### Q# materials

* Information about simulators in the QDK can be found [here](https://docs.microsoft.com/en-us/azure/quantum/user-guide/machines/).
