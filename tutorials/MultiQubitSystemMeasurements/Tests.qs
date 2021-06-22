// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT license.

//////////////////////////////////////////////////////////////////////
// This file contains testing harness for all tasks.
// You should not modify anything in this file.
//////////////////////////////////////////////////////////////////////

namespace Quantum.Kata.MultiQubitSystemMeasurements {
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Measurement;
    open Microsoft.Quantum.Random;

    open Quantum.Kata.Utils;
    // ------------------------------------------------------
    // "Framework" operation for testing multi-qubit tasks for distinguishing states of an array of qubits
    // with Int return
    operation DistinguishStates_MultiQubit (nQubits : Int,
                                            nStates : Int,
                                            statePrep : ((Qubit[], Int, Double) => Unit is Adj),
                                            testImpl : (Qubit[] => Int),
                                            preserveState : Bool,
                                            stateNames : String[]) : Unit {
        let nTotal = 100;
        // misclassifications will store the number of times state i has been classified as state j (dimension nStates^2)
        mutable misclassifications = new Int[nStates * nStates];
        // unknownClassifications will store the number of times state i has been classified as some invalid state (index < 0 or >= nStates)
        mutable unknownClassifications = new Int[nStates];
                
        use qs = Qubit[nQubits];
        for i in 1 .. nTotal {
            // get a random integer to define the state of the qubits
            let state = DrawRandomInt(0, nStates - 1);
            // get a random rotation angle to define the exact state of the qubits
            // for some exercises, this value might be a dummy variable which does not matter
            let alpha = DrawRandomDouble(0.0, 1.0) * PI();
                
            // do state prep: convert |0...0⟩ to outcome with return equal to state
            statePrep(qs, state, alpha);

            // get the solution's answer and verify that it's a match, if not, increase the exact mismatch count
            let ans = testImpl(qs);
            if ((ans >= 0) and (ans < nStates)) {
                // classification result is a valid state index - check if is it correct
                if (ans != state) {
                    set misclassifications w/= ((state * nStates) + ans) <- (misclassifications[(state * nStates) + ans] + 1);
                }
            }
            else {
                // classification result is an invalid state index - file it separately
                set unknownClassifications w/= state <- (unknownClassifications[state] + 1);  
            }

            if (preserveState) {
                // check that the state of the qubit after the operation is unchanged
                Adjoint statePrep(qs, state, alpha);
                AssertAllZero(qs);
            } else {
                // we're not checking the state of the qubit after the operation
                ResetAll(qs);
            }
        }
        
        mutable totalMisclassifications = 0;
        for i in 0 .. nStates - 1 {
            for j in 0 .. nStates - 1 {
                if (misclassifications[(i * nStates) + j] != 0) {
                    set totalMisclassifications += misclassifications[i * nStates + j];
                    Message($"Misclassified {stateNames[i]} as {stateNames[j]} in {misclassifications[(i * nStates) + j]} test runs.");
                }
            }
            if (unknownClassifications[i] != 0) {
                set totalMisclassifications += unknownClassifications[i];
                Message($"Misclassified {stateNames[i]} as Unknown State in {unknownClassifications[i]} test runs.");
            }
        }
        // This check will tell the total number of failed classifications
        Fact(totalMisclassifications == 0, $"{totalMisclassifications} test runs out of {nTotal} returned incorrect state (see output for details).");
    }
    
    // ------------------------------------------------------
    // Exercise 3: Distinguish four basis states
    // ------------------------------------------------------
    operation StatePrep_BasisStateMeasurement(qs : Qubit[], state : Int, dummyVar : Double) : Unit is Adj {
        if (state / 2 == 1) {
            // |10⟩ or |11⟩
            X(qs[0]);
        }
        if (state % 2 == 1) {
            // |01⟩ or |11⟩
            X(qs[1]);
        }
    }

    @Test("Microsoft.Quantum.Katas.CounterSimulator")
    operation T1_BasisStateMeasurement () : Unit {
        DistinguishStates_MultiQubit(2, 4, StatePrep_BasisStateMeasurement, BasisStateMeasurement, false, ["|00⟩", "|01⟩", "|10⟩", "|11⟩"]);
    }


    // ------------------------------------------------------
    // Exercise 5: Distinguish orthogonal states using partial measurements
    // ------------------------------------------------------
    operation StatePrep_IsPlusPlusMinus (qs : Qubit[], state : Int, dummyVar : Double) : Unit is Adj{
        if (state == 0){
            // prepare the state |++-⟩
            H(qs[0]);
            H(qs[1]);
            X(qs[2]);
            H(qs[2]);
        } else {
            // prepare the state |---⟩
            X(qs[0]);
            H(qs[0]);
            X(qs[1]);
            H(qs[1]);
            X(qs[2]);
            H(qs[2]);
        }
    }

    @Test("Microsoft.Quantum.Katas.CounterSimulator")
    operation T2_IsPlusPlusMinus () : Unit {
        DistinguishStates_MultiQubit(3, 2, StatePrep_IsPlusPlusMinus, IsPlusPlusMinus, false, ["|++-⟩", "|---⟩"]);
    }

    
    

    // ------------------------------------------------------
    // Exercise 7: State selection using partial measurements
    // ------------------------------------------------------
    operation stateInitialize_StateSelction(alpha: Double, qs : Qubit[]) : Unit {
        // Prepare the state to be input to the testImplementation
        // set the second qubit in a superposition a |0⟩ + b|1⟩
        // with a = cos alpha, b = sin alpha
        Ry(2.0 * alpha, qs[1]); 

        H(qs[0]);
        // Apply CX gate
        CX(qs[0], qs[1]);
    }

    operation statePrepare_StateSelction(alpha : Double, Choice : Int, qs : Qubit[]) : Unit is Adj {
        // The expected state of the second qubit for the exercise.

        // set the second qubit in a superposition a |0⟩ + b|1⟩
        // with a = cos alpha, b = sin alpha
        Ry(2.0 * alpha, qs[1]); 
        if (Choice == 1) { 
            // if the Choice is 1, change the state to b|0⟩ + a|1⟩
            X(qs[1]);
        }
    }


    @Test("QuantumSimulator")
    operation T3_StateSelction() : Unit {
        use qs = Qubit[2];
        for i in 0 .. 5 {
            let alpha = (PI() * IntAsDouble(i)) / 5.0;
            
            //for Choice = 0 and 1,
            for Choice in 0 .. 1 {
                // Prepare the state to be input to the testImplementation
                stateInitialize_StateSelction(alpha, qs);

                // operate testImplementation
                StateSelction(qs, Choice);
                // reset the first qubit, since its state does not matter
                Reset(qs[0]);

                // apply adjoint reference operation and check that the result is correct
                Adjoint statePrepare_StateSelction(alpha, Choice, qs);
                
                AssertAllZero(qs);
                ResetAll(qs);
                
            }           
        }
    }

    
    // ------------------------------------------------------
    // Exercise 8: State preparation using partial measurements
    // ------------------------------------------------------

    operation RefImpl_T4 (qs : Qubit[]) : Unit is Adj {
        // Rotate first qubit to (sqrt(2) |0⟩ + |1⟩) / sqrt(3) (task 1.4 from BasicGates kata)
        let theta = ArcSin(1.0 / Sqrt(3.0));
        Ry(2.0 * theta, qs[0]);

        // Split the state sqrt(2) |0⟩ ⊗ |0⟩ into |00⟩ + |01⟩
        (ControlledOnInt(0, H))([qs[0]], qs[1]);
    }


    @Test("QuantumSimulator")
    operation T4_PostSelection() : Unit {
        use qs = Qubit[2];

        // operate the test implementation
        PostSelection(qs);

        // apply adjoint reference operation and check that the result is |0⟩
        Adjoint RefImpl_T4(qs);
        AssertAllZero(qs);
    }


    // ------------------------------------------------------
    // Exercise 9: Two qubit parity Measurement
    // ------------------------------------------------------

    
    // ------------------------------------------------------
    operation StatePrep_ParityMeasurement (qs : Qubit[], state : Int, alpha : Double) : Unit is Adj {
        
        // prep cos(alpha) * |0..0⟩ + sin(alpha) * |1..1⟩
        Ry(2.0 * alpha, qs[0]);
        for i in 1 .. Length(qs) - 1 {
            CNOT(qs[0], qs[i]);
        }
            
        if (state == 1) {
            // flip the state of the first half of the qubits
            for i in 0 .. Length(qs) / 2 - 1 {
                X(qs[i]);
            }
        }
    }

    // ------------------------------------------------------
    @Test("QuantumSimulator")
    operation T5_ParityMeasurement () : Unit {
        DistinguishStates_MultiQubit(2, 2, StatePrep_ParityMeasurement, ParityMeasurement, true, ["α|00⟩ + β|11⟩", "α|01⟩ + β|10⟩"]);
    }

}