// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT license.

namespace Quantum.Kata.ExploringSimonsAlgorithm {
    
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Canon;
    
    
    //////////////////////////////////////////////////////////////////
    // Welcome!
    //////////////////////////////////////////////////////////////////
    
    // "Simon's Algorithm" kata is a series of exercises designed to teach a quantum algorithm for
    // a problem of identifying a bit string that is implicitly defined (or, in other words, "hidden") by
    // some oracle that satisfies certain conditions. It is arguably the most simple case of an (oracle)
    // problem for which a quantum algorithm has a *provable* exponential advantage over any classical algorithm.
    
    // Each task is wrapped in one operation preceded by the description of the task. Each task (except tasks in
    // which you have to write a test) has a unit test associated with it, which initially fails. Your goal is to
    // fill in the blank (marked with // ... comment) with some Q# code to make the failing test pass.
    
    //////////////////////////////////////////////////////////////////
    // Part II. Oracles
    //////////////////////////////////////////////////////////////////
        
    // Exercise 1. Bitwise left shift
    // Inputs:
    //      1) N qubits in an arbitrary state |x⟩
    //      2) N qubits in an arbitrary state |y⟩
    // Goal: Transform state |x, y⟩ into |x, y ⊕ f(x)⟩, where f is bitwise left shift function, i.e.,
    // |y ⊕ f(x)⟩ = |y_0 ⊕ x_1, y_1 ⊕ x_2, ..., y_{n-1} ⊕ x_{n}⟩ (⊕ is addition modulo 2).
    operation Bitwise_LeftShift_Oracle (x : Qubit[], y : Qubit[]) : Unit
    is Adj {        
        // ...
    }
    
    
    //////////////////////////////////////////////////////////////////
    // Part III. Simon's Algorithm
    //////////////////////////////////////////////////////////////////
    
    // Exercise 2. Quantum part of Simon's algorithm
    // Inputs:
    //      1) the number of qubits in the input register N for the function f
    //      2) a quantum operation which implements the oracle |x⟩|y⟩ -> |x⟩|y ⊕ f(x)⟩, where
    //         x is N-qubit input register, y is N-qubit answer register, and f is a function
    //         from N-bit strings into N-bit strings
    //
    // The function f is guaranteed to satisfy the following property:
    // there exists some N-bit string s such that for all N-bit strings b and c (b != c)
    // we have f(b) = f(c) if and only if b = c ⊕ s. In other words, f is a two-to-one function.
    //
    // An example of such function is bitwise right shift function from task 1.2;
    // the bit string s for it is [0, ..., 0, 1].
    //
    // Output:
    //      Any bit string b such that Σᵢ bᵢ sᵢ = 0 modulo 2.
    //
    // Note that the whole algorithm will reconstruct the bit string s itself, but the quantum part of the
    // algorithm will only find some vector orthogonal to the bit string s. The classical post-processing
    // part is already implemented, so once you implement the quantum part, the tests will pass.
    operation Simon_Algorithm (N : Int, Uf : ((Qubit[], Qubit[]) => Unit)) : Int[] {
        
        // Declare an Int array in which the result will be stored;
        // the variable has to be mutable to allow updating it.
        mutable b = new Int[N];
        
        // ...

        return b;
    }
    
}
