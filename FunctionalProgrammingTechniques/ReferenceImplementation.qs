// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT license.

//////////////////////////////////////////////////////////////////////
// This file contains reference solutions to all tasks.
// The tasks themselves can be found in Tasks.qs file.
// We recommend that you try to solve the tasks yourself first,
// but feel free to look up the solution if you get stuck.
//////////////////////////////////////////////////////////////////////

namespace Quantum.Kata.FunctionalProgrammingTechniques {
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Math;

    //TODO:  copy in comments

    function SimpleAdder_Reference ( addend: Int ) : Int {
        return Add7 ( addend ); 
    }

    function Fold_Sum_Reference ( xs: Double[] ) : Double {
        return Fold ( Sum, 0.0, xs );
	}

    function Fold_Product_Reference ( xs: Double[] ) : Double {
        return Fold( Product, 1.0, xs);
	}

    function ComposeImpl_Reference( outerfn: (Double -> Double), innerfn: ( (Int, Int) -> Double ), fractionPiNumerator: Int, fractionPiDenominator: Int ) : Double {
        return outerfn(innerfn(fractionPiNumerator, fractionPiDenominator));
	}

    function Compose_Reference(outerfn: (Double -> Double), innerfn: ( (Int, Int) -> Double )) : ( (Int, Int) -> Double ) {
        return ComposeImpl_Reference(outerfn, innerfn, _, _);
	}

    function Compose_Functions_Reference (fractionPiNumerator: Int, fractionPiDenominator: Int) : Double {
        let FractionPi_to_Degrees_Reference = Compose_Reference(Radians_to_Degrees, FractionPi_to_Radians);
        return FractionPi_to_Degrees_Reference(fractionPiNumerator, fractionPiDenominator);
    }

    operation Uniform_Superposition_Reference ( qs: Qubit[] ) : Unit is Adj + Ctl {
        ApplyToEachCA(H, qs);
	}

    operation Multiple_CNOT_Reference(qs: Qubit[]) : Unit is Adj + Ctl {
        let nQubits = Length(qs);
        ApplyToEachCA(CNOT, Zip(qs[0..nQubits -2], qs[1..nQubits - 1]));
	}

    operation IsConstantZeroConstant_Reference() : Bool {
        return(IsOracleConstant(ConstantZero_Oracle));
	}

    operation IsConstantOneConstant_Reference() : Bool {
        return(IsOracleConstant(ConstantOne_Oracle));
	}

    operation IsIdentityConstant_Reference() : Bool {
        return(IsOracleConstant(Identity_Oracle));
	}

    operation IsNegationConstant_Reference() : Bool {
        return(IsOracleConstant(Negation_Oracle));
	}
}
