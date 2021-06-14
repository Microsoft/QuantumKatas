// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT license.

//////////////////////////////////////////////////////////////////////
// This file contains testing harness for all tasks.
// You should not modify anything in this file.
// The tasks themselves can be found in Tasks.qs file.
//////////////////////////////////////////////////////////////////////

namespace Quantum.Kata.FunctionalProgrammingTechniques {
    
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Diagnostics;
 
    function T101_SimpleAdder_Test () : Unit {
        for ( i in 0..7) {
            EqualityFactI( SimpleAdder(i), SimpleAdder_Reference(i), "error:  incorrect result" );
		}
	}

    function T102_Fold_Sum_Test () : Unit {
        let tests = [ [ 42.0 , 12.0, 13.0, 17.0 ],
		[ 77.0, 3.0, 7.0, 10.0, 20.0, 30.0 ]
        ];

        for ( xs in tests) {
            NearEqualityFactD(Fold_Sum(xs), Fold_Sum_Reference(xs));
		}
	}

    function T103_Fold_Product_Test () : Unit {
        let tests = [ [ 2.0 , 4.0, 6.0 ],
		[ 3.0, 5.0 ]
        ];

        for ( xs in tests) {
            if (Fold_Product(xs) == 0.0) {
			    Message("Be sure to check the Input state parameter to your Fold");
            }

            NearEqualityFactD(Fold_Product(xs), Fold_Product_Reference(xs));
		}
	}

    function T104_Compose_Functions_Test () : Unit {
        let tests = [ [ 1, 2],
        [1, 1],
        [3, 2], 
        [2, 1]
	    ];

        for ( fraction in tests ) {
            NearEqualityFactD(Compose_Functions(fraction[0], fraction[1]), Compose_Functions_Reference(fraction[0], fraction[1])) ; 
		}
	}

    // ------------------------------------------------------
    // Helper operation to show the difference between the reference solution and the learner's one
    operation DumpDiff (N : Int,
                        testImpl : (Qubit[] => Unit is Adj+Ctl),
                        refImpl : (Qubit[] => Unit is Adj+Ctl)
                       ) : Unit {
        using (qs = Qubit[N]) {
            // Apply the reference solution and show result
            refImpl(qs);
            Message("The desired state:");
            DumpMachine();
            ResetAll(qs);

            // Apply learner's solution and show result
            testImpl(qs);
            Message("The actual state:");
            DumpMachine();
            ResetAll(qs);
        }
    }

    operation T201_Uniform_Superposition_Test () : Unit {
        for (N in 3 .. 5) {
            DumpDiff(N, Uniform_Superposition, Uniform_Superposition_Reference);
            AssertOperationsEqualReferenced(N, Uniform_Superposition, Uniform_Superposition_Reference);
        } 
	}

    operation T202_Multiple_CNOT_Test () : Unit {
        for (N in 5 .. 7) {
            DumpDiff(N, Multiple_CNOT, Multiple_CNOT_Reference);
            AssertOperationsEqualReferenced(N, Multiple_CNOT, Multiple_CNOT_Reference);
        }
	}

    operation T203_ConstantZero_Test() : Unit {
        EqualityFactB(IsConstantZeroConstant(), IsConstantZeroConstant_Reference(), "error:  incorrect result");
	}

    operation T204_ConstantOne_Test() : Unit {
        EqualityFactB(IsConstantOneConstant(), IsConstantOneConstant_Reference(), "error:  incorrect result");
	}

    operation T205_Identity_Test() : Unit {
        EqualityFactB(IsIdentityConstant(), IsIdentityConstant_Reference(), "error:  incorrect result");
	}

    operation T206_Negation_Test() : Unit {
        EqualityFactB(IsNegationConstant(), IsNegationConstant_Reference(), "error:  incorrect result");
	}
}
