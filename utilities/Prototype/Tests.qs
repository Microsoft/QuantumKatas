// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT license.

//////////////////////////////////////////////////////////////////////
// This file contains testing harness to verify
// if the `%kata` and `%check_kata` magics work as expected.
// You should not modify anything in this file.
// The tasks themselves can be found in Tasks.qs file.
//////////////////////////////////////////////////////////////////////

namespace Quantum.Kata.Prototype {
    
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Diagnostics;
    open Quantum.Kata.Utils;

    // This test imposes no limitation on the number of H gates that can be
    // called by the user to convert |0> to |+> state.
    // This test would fail on Toffoli Simulator.
    // Toffoli Simulator is only able to simulate operations
    // that use X, CNOT,etc gates(and their controlled version.)
    //
    // Note : We can't design a test that passes on QuantumSimulator but
    // fails on CounterSimulator, since latter offers all the functionality of the former
    @Test("QuantumSimulator")
    @Test("Microsoft.Quantum.Katas.CounterSimulator")
    operation QuantumSimulatorCheck() : Unit {
        use q = Qubit();

        H(q);

        FlipZeroToPlusNoRestriction(q);

        AssertQubit(Zero, q);
        
        Message("Test passed...");
    }

    // This test allows user to use only one H gate to convert |0> to |+> state.
    //
    // This test would fail on Toffoli and Quantum Simulator since they do not support
    // ResetOracleCallsCount() and GetOracleCallsCount() functionality
    @Test("Microsoft.Quantum.Katas.CounterSimulator")
    operation CounterSimulatorCheck() : Unit {
        use q = Qubit();
        H(q);

        ResetOracleCallsCount();

        FlipZeroToPlusRestriction(q);
        let nu = GetOracleCallsCount(H);

        AssertQubit(Zero, q);
        
        EqualityFactI(nu, 1, $"You are allowed to call H gate exactly once, and you called it {nu} times");
    
        Message("Test passed...");
    }

    // This test allocates and manipulates 50 qubits(>30 qubits), so that
    // full state simulator runs out of memory during the qubit allocation
    @Test("ToffoliSimulator")
    operation ToffoliSimulatorCheck() : Unit {
        use qs = Qubit[150];

        FlipZerosToOnes(qs);

        for q in qs
        {
            AssertQubit(One, q);
        }

        ResetAll(qs);

        Message("Test passed...");
	}


    // This test checks if qubits are in |1..1> state.
    // This test would pass on all simulators if the user used X gate,
    // CNOT and their controlled versions
    @Test("QuantumSimulator")
    @Test("ToffoliSimulator")
    @Test("Microsoft.Quantum.Katas.CounterSimulator")
    operation MultipleSimulatorCheck() : Unit {
        use qs = Qubit[2];

        FlipZerosToOnes(qs);

        for q in qs
        {
            AssertQubit(One, q);
        }

        ResetAll(qs);

        Message("Test passed...");
	}

}
