// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT license.

//////////////////////////////////////////////////////////////////////
// This file contains reference solutions to all tasks.
// You should not modify anything in this file.
//////////////////////////////////////////////////////////////////////

namespace Quantum.Kata.Prototype {

    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Canon;

    operation QsharpUnit_Reference() : Unit{

    }

    operation FlipZeroToPlusNoRestriction_Reference(q : Qubit) : Unit{
        H(q);
        H(q);
        H(q);
    }

    operation FlipZeroToPlusRestriction_Reference(q : Qubit) : Unit{
        H(q);
    }

    operation FlipZerosToOnes_Reference(qs : Qubit[]) : Unit{
        ApplyToEach(X, qs);
    }
}