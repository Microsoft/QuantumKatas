// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT license.

//////////////////////////////////////////////////////////////////////
// This file contains testing harness for all tasks.
// You should not modify anything in this file.
// The tasks themselves can be found in Tasks.qs file.
//////////////////////////////////////////////////////////////////////

namespace Quantum.Kata.Counting {
    
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Math;
	open Microsoft.Quantum.Intrinsic;
    
    
	operation Compute_Average(n_bit : Int, n_sol: Int, precision: Int, iterations: Int, tolerance_fraction: Double): Unit
	{
		mutable sum=0.0;
		let tolerance=tolerance_fraction*IntAsDouble(n_sol);

		for (i in 1..iterations)
		{
			let reference=Counting(n_bit,n_sol,precision);
			Message(DoubleAsString(reference));
			set sum=sum+reference;
	    }
		let average=sum/IntAsDouble(iterations);
		Message("Expected :"+IntAsString(n_sol)+" Found (average): "+DoubleAsString(average));
		EqualityWithinToleranceFact(average,IntAsDouble(n_sol),tolerance);
	}
    
    // ------------------------------------------------------
    operation T7_16_5_Counting_Test () : Unit {
		let iterations=10;
		let n_bit=7;
		let n_sol=16;
		let precision=5;
		let tolerance_fraction=0.7;
		Compute_Average(n_bit,n_sol,precision,iterations,tolerance_fraction);
    }

    operation T7_20_5_Counting_Test () : Unit {
		let iterations=10;
		let n_bit=7;
		let n_sol=20;
		let precision=5;
		let tolerance_fraction=0.7;
		Compute_Average(n_bit,n_sol,precision,iterations,tolerance_fraction);
    }

    operation T7_40_5_Counting_Test () : Unit {
		let iterations=10;
		let n_bit=7;
		let n_sol=40;
		let precision=5;
		let tolerance_fraction=0.7;
		Compute_Average(n_bit,n_sol,precision,iterations,tolerance_fraction);
    }
}
