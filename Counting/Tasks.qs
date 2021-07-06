// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT license.

namespace Quantum.Kata.Counting {
    
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Oracles;
    open Microsoft.Quantum.Arithmetic;    
    open Microsoft.Quantum.Characterization;
   
    
    //////////////////////////////////////////////////////////////////
    // Welcome!
    //////////////////////////////////////////////////////////////////
    
    // The "Counting" quantum kata is a series of exercises designed
    // to get you familiar with Quantum Counting.
    // It covers the following topics:
    //  - writing oracles for counting,
    //  - performing actual counting.
    
    // Each task is wrapped in one operation preceded by the description of the task.
    // Each task (except tasks in which you have to write a test) has a unit test associated with it,
    // which initially fails. Your goal is to fill in the blank (marked with // ... comment)
    // with some Q# code to make the failing test pass.
    
    // Within each section, tasks are given in approximate order of increasing difficulty;
    // harder ones are marked with asterisks.
    
    
    //////////////////////////////////////////////////////////////////
    // Part I. Oracle for Counting
    //////////////////////////////////////////////////////////////////
    
    // Task 1.1. The solution count oracle
    // Designate first nSol integers solutions (since we don't really care which ones are solutions)

	operation Oracle_Solution_Count  (queryRegister : Qubit[], target : Qubit, nSol : Int) : Unit is Ctl+ Adj {
	//
	}

    //////////////////////////////////////////////////////////////////
    // Part I. Counting
    //////////////////////////////////////////////////////////////////
	// Implement counting using operations from ReferenceImplementation.qs
	// - GroverIteration (register : Qubit[], oracle : ((Qubit[],Qubit) => Unit is Ctl+Adj)) : Unit  is Ctl+Ad
	//   for the Grover operator
	// - QuantumPhaseEstimation (oracle : Microsoft.Quantum.Oracles.DiscreteOracle, targetState : Qubit[], controlRegister : Microsoft.Quantum.Arithmetic.BigEndian) : Unit
	//   from Microsoft.Quantum.Characterization, for estimating the phase
	// Counting should return the number of models, n_sol 
	operation Counting(n_bit : Int, n_sol: Int, precision: Int) : Double {
		// ....
		return 0.0;
    }
    
    
   
    
}
