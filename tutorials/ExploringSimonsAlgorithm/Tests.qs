// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT license.

//////////////////////////////////////////////////////////////////////
// This file contains testing harness for all tasks.
// You should not modify anything in this file.
//////////////////////////////////////////////////////////////////////

namespace Quantum.Kata.ExploringSimonsAlgorithm {
    
    open Microsoft.Quantum.Diagnostics;

    open Quantum.Kata.Utils;
    
  
    //////////////////////////////////////////////////////////////////
    // Part II. Oracles
    //////////////////////////////////////////////////////////////////

    operation ApplyOracleWithOutputArrA (qs : Qubit[], oracle : ((Qubit[], Qubit[]) => Unit is Adj), outputSize : Int) : Unit
    is Adj {
        let N = Length(qs);
        oracle(qs[0 .. (N - 1) - outputSize], qs[N - outputSize .. N - 1]);
    }


    operation AssertTwoOraclesWithOutputArrAreEqual (
        inputSize : Int, 
        outputSize : Int, 
        oracle1 : ((Qubit[], Qubit[]) => Unit is Adj), 
        oracle2 : ((Qubit[], Qubit[]) => Unit is Adj)) : Unit {
        let sol = ApplyOracleWithOutputArrA(_, oracle1, outputSize);
        let refSol = ApplyOracleWithOutputArrA(_, oracle2, outputSize);
        AssertOperationsEqualReferenced(inputSize + outputSize, sol, refSol);
    }

    // Exercise 1.
    operation E1_QuantumOracle_Test () : Unit {
        for (n in 2 .. 6) {
            AssertTwoOraclesWithOutputArrAreEqual(n, n, Bitwise_LeftShift_Oracle, Bitwise_LeftShift_Oracle_Reference);
        }
    }
}