// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT license.

namespace Quantum.Kata.CHSHGame {

    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Extensions.Math;
    open Microsoft.Quantum.Primitive;


    ///////////////////////////////////////////////////////////////////////
    //                                                                   //
    //  CHSH Game Kata                                                   //
    //                                                                   //
    ///////////////////////////////////////////////////////////////////////

    // Task 1. Entangled pair
    // Input: An array of two qubits in the |00⟩ state.
    // Goal:  Create a Bell state |Φ⁺⟩ = (|00⟩ + |11⟩) / sqrt(2) on these qubits.
    operation CreateEntangledPair (qs : Qubit[]) : Unit {
        // The following lines enforce the constraints on the input that you are given.
        // You don't need to modify them. Feel free to remove them, this won't cause your code to fail.
        AssertIntEqual(Length(qs), 2, "The array should have exactly 2 qubits.");

        // ...
    }


    // Task 2. Measure Alice's qubit
    // Input: The classical bit Alice was given, and Alice's entangled qubit
    // Goal:  Measure Alice's qubit in the Z basis if her bit is 0 or the X basis if her bit is 1
    operation MeasureAliceQubit (bit : Bool, qubit : Qubit) : Result {
        // ...
        return Zero;
    }


    // Task 3. Rotate Bob's qubit
    // Input: The direction to rotate, and Bob's entangled qubit
    // Goal:  Rotate Bob's qubit π/8 radians around the Y axis either clockwise or counterclockwise.
    operation RotateBobQubit (clockwise : Bool, qubit : Qubit) : Unit {
        // ...
    }


    // Task 4. Measure Bob's qubit
    // Input: The classical bit Bob was given, and Alice's entangled qubit
    // Goal:  Measure Bob's qubit in the π/8 basis if his bit is 0 or the -π/8 basis if his bit is
    // 1.
    operation MeasureBobQubit (bit : Bool, qubit : Qubit) : Result {
        // ...
        return Zero;
    }


    // Task 5. Play the CHSH game using the quantum strategy
    // Input: Alice and Bob's X and Y bits and whether Alice should measure first.
    // Goal: Return A XOR B.
    operation PlayQuantumStrategy (aliceBit : Bool, bobBit : Bool, aliceMeasuresFirst : Bool) : Bool {
        // ...
        return false != false;
    }

}
