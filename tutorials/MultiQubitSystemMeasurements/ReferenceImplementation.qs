// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT license.

//////////////////////////////////////////////////////////////////////
// This file contains reference solutions to all tasks.
// You should not modify anything in this file.
// We recommend that you try to solve the tasks yourself first,
// but feel free to look up the solution if you get stuck.
//////////////////////////////////////////////////////////////////////

namespace Quantum.Kata.MultiQubitSystemMeasurements {
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Measurement;
    
    // Exercise 3. Identify computational basis states
    operation BasisStateMeasurement_Reference(qs : Qubit[]) : Int {
        // Measurement on the first qubit gives the higher bit of the answer, on the second - the lower
        let m1 = M(qs[0]) == Zero ? 0 | 1;
        let m2 = M(qs[1]) == Zero ? 0 | 1;
        return m1 * 2 + m2;
    }
    // Exercise 5. Distinguish orthogonal states
    operation IsPlusPlusMinus_Reference (qs : Qubit[]) : Int {
        return Measure([PauliX], [qs[0]]) == Zero  ? 0 | 1;
    }

    // Exercise 7. State selection using partial measurements
    operation StateSelction_Reference(qs : Qubit[], i : Int) : Unit  {
        if (i == 0) {
            if (M(qs[0]) == One){
                // apply the X gate to the second qubit
                X(qs[1]);
            }
        } else {
            if (M(qs[0]) == Zero){
                // apply the X gate to the second qubit only
                X(qs[1]);
            }
        }
    }

    // Exercise 8. State preparation using partial measurements
    operation PostSelection_Reference ( qs : Qubit[] ): Unit {
        // Initialize the extra qubit
        use anc = Qubit();
        // Using the repeat-until-success pattern to prepare the right state
        repeat {
            ApplyToEach(H, qs);
            Controlled X(qs, anc);
            let res = MResetZ(anc);
        } 
        until (res == Zero)
        fixup {
            ResetAll(qs);
        }
    }

    // Exercise 9. Two qubit parity Measurement
    operation ParityMeasurement_Reference(qs : Qubit[]) : Int {
        return Measure([PauliZ, PauliZ], qs) == Zero ? 0 | 1;
    }
}