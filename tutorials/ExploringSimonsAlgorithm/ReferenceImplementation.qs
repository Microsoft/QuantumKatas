// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT license.

//////////////////////////////////////////////////////////////////////
// This file contains reference solutions to all tasks.
// The tasks themselves can be found in Tasks.qs file.
// We recommend that you try to solve the tasks yourself first,
// but feel free to look up the solution if you get stuck.
//////////////////////////////////////////////////////////////////////

namespace Quantum.Kata.ExploringSimonsAlgorithm {
    
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Canon;
    
    
    //////////////////////////////////////////////////////////////////
    // Part II. Oracles
    //////////////////////////////////////////////////////////////////
    
    // Exercise 1. Bitwise left shift
    operation Bitwise_LeftShift_Oracle_Reference (x : Qubit[], y : Qubit[]) : Unit
    is Adj {
        
        let N = Length(x);

        for (i in 1 .. N - 1) {
            CNOT(x[i], y[i - 1]);
        }
    }
    
        
    //////////////////////////////////////////////////////////////////
    // Part III. Simon's Algorithm
    //////////////////////////////////////////////////////////////////
    
    // Exercise 2. Quantum part of Simon's algorithm
    operation Simons_Algorithm_Reference (N : Int, Uf : ((Qubit[], Qubit[]) => Unit)) : Int[] {
                
        // allocate input and answer registers with N qubits each
        using ((x, y) = (Qubit[N], Qubit[N])) {
            // prepare qubits in the right state
            ApplyToEach(H, x);
            
            // apply oracle
            Uf(x, y);
            
            // apply Hadamard to each qubit of the input register
            ApplyToEach(H, x);
            
            // measure all qubits of the input register;
            // the result of each measurement is converted to an Int
            mutable j = new Int[N];
            for (i in 0 .. N - 1) {
                if (M(x[i]) == One) {
                    set j w/= i <- 1;
                }
            }
            
            // before releasing the qubits make sure they are all in |0⟩ states
            ResetAll(x);
            ResetAll(y);
            return j;
        }
    }
    
}
