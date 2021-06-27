// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT license.

//////////////////////////////////////////////////////////////////////
// This file contains testing harness for all tasks.
// You should not modify anything in this file.
// The tasks themselves can be found in Tasks.qs file.
//////////////////////////////////////////////////////////////////////

namespace Quantum.Kata.WGame {

    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Diagnostics;

    // All possible starting bits (r, s and t) that the referee can give
    // to Alice, Bob and Charlie.
    function RefereeBits () : Bool[][] {
        return [[false, false, false],
                [true, true, false],
                [false, true, true],
                [true, false, true]];
    }

    operation T11_WinCondition_Test () : Unit {
        for (rst in RefereeBits()) {
            for (i in 0..1 <<< 3 - 1) {
                let abc = IntAsBoolArray(i, 3);
                EqualityFactB(
                    WinCondition(rst, abc),
                    WinCondition_Reference(rst, abc),
                    $"Win condition is wrong for rst={rst}, abc={abc}");
            }
        }
    }


    // ------------------------------------------------------
    operation GetClassicalStrategySuccessRate (N : Int, strategy : (Bool => Bool)) : Double {
        let inputs = RefereeBits();
        mutable wins = 0;
        for (i in 0..N - 1) {
            let rst = inputs[RandomInt(Length(inputs))];
            let abc = PlayClassicalW_Reference(strategy, rst);
            if (WinCondition_Reference(rst, abc)) {
                set wins = wins + 1;
            }
        }
        return IntAsDouble(wins) / IntAsDouble(N);
    }

    operation T12_RandomClassical_Test () : Unit {
        EqualityWithinToleranceFact(GetClassicalStrategySuccessRate(10000, RandomClassicalStrategy), 0.5625, 0.02);
    }


    // ------------------------------------------------------
    operation T13_SimpleClassical_Test () : Unit {
        EqualityWithinToleranceFact(GetClassicalStrategySuccessRate(10000, SimpleClassicalStrategy), 0.75, 0.02);
    }


    // ------------------------------------------------------
    operation T14_BestClassical_Test () : Unit {
        EqualityWithinToleranceFact(GetClassicalStrategySuccessRate(10000, BestClassicalStrategy), 0.8611, 0.02);
    }


    // ------------------------------------------------------
    operation TestStrategy (input : Bool, mode : Int) : Bool {
        return mode == 0 ? false | mode == 1 ? true | mode == 2 ? input | not input;
    }


    operation T15_PlayClassicalW_Test () : Unit {
        // To test the interaction, run it on several deterministic strategies (not necessarily good ones)
        let inputs = RefereeBits();
        for (rst in inputs) {
            for (mode in 0..3) {
                let result = PlayClassicalW(TestStrategy(_, mode), rst);
                let expected = PlayClassicalW_Reference(TestStrategy(_, mode), rst);
                AllEqualityFactB(result, expected, $"Unexpected result for rst={rst}");
            }
        }
    }

    //////////////////////////////////////////////////////////////////
    // Part II. Quantum W game
    //////////////////////////////////////////////////////////////////

    operation AssertEqualOnZeroState (N : Int, taskImpl : (Qubit[] => Unit), refImpl : (Qubit[] => Unit is Adj)) : Unit {
        using (qs = Qubit[N]) {
            // apply operation that needs to be tested
            taskImpl(qs);
            
            // apply adjoint reference operation and check that the result is |0ᴺ⟩
            Adjoint refImpl(qs);
            
            // assert that all qubits end up in |0⟩ state
            AssertAllZero(qs);
        }
    }

    operation T21_CreateEntangledTriple_Test () : Unit {
        AssertEqualOnZeroState(3, CreateEntangledTriple, CreateEntangledTriple_Reference);
    }


    // ------------------------------------------------------
    operation T22_QuantumStrategy_Test () : Unit {
        using (q = Qubit()) {
            EqualityFactB(QuantumStrategy(false, q), false, "|0⟩ not measured as false");
            Reset(q);

            X(q);
            EqualityFactB(QuantumStrategy(false, q), true, "|1⟩ not measured as true");
            Reset(q);

            H(q);
            EqualityFactB(QuantumStrategy(true, q), false, "|+⟩ is not measured as false");
            Reset(q);

            X(q);
            H(q);
            EqualityFactB(QuantumStrategy(true, q), true, "|-⟩ is not measured as true");
            Reset(q);
        }
    }


    // ------------------------------------------------------
    operation T23_PlayQuantumW_Test () : Unit {
        mutable wins = 0;
        for (i in 1..10000) {
            let rst = (RefereeBits())[RandomInt(Length(RefereeBits()))];
            let strategies = [QuantumStrategy_Reference(rst[0], _), 
                              QuantumStrategy_Reference(rst[1], _), 
                              QuantumStrategy_Reference(rst[2], _)];
            let abc = PlayQuantumW(strategies);
            if (WinCondition_Reference(rst, abc)) {
                set wins = wins + 1;
            }
        }
        EqualityWithinToleranceFact(IntAsDouble(wins) / 10000.0, 0.9375, 0.01);
    }

}
