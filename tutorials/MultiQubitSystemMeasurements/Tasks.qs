// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT license.

//////////////////////////////////////////////////////////////////
// This file is a back end for the tasks in the tutorial.
// We strongly recommend to use the Notebook version of the tutorial
// to enjoy the full experience.
//////////////////////////////////////////////////////////////////

namespace Quantum.Kata.MultiQubitSystemMeasurements {
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Math;
    
    // Exercise 3. Identify computational basis states
    operation BasisStateMeasurement(qs : Qubit[]) : Int {
        // ...
        return 0;
    }

    // Exercise 5. Distinguish orthogonal states
    operation IsPlusPlusMinus(qs : Qubit[]) : Int {
        // ...
        return 0;
    }

    // Exercise 7. State selection using partial measurements
    operation StateSelction(qs : Qubit[], i : Int) : Unit  {
        // ...
    }

    // Exercise 8. State preparation using partial measurements
    operation PostSelection( qs : Qubit[] ): Unit {
        // ...
    }

    // Exercise 9. Two qubit parity Measurement
    operation ParityMeasurement(qs : Qubit[]) : Int{
        // ...
        return 1;
    }
}

