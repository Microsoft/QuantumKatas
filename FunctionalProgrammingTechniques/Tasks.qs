// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT license.

namespace Quantum.Kata.FunctionalProgrammingTechniques {
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Measurement;

    //////////////////////////////////////////////////////////////////
    // Welcome!
    //////////////////////////////////////////////////////////////////
    //
    //  The Tasks below are laid out in two sections:
    //      one for Classical functional programming (ie, without Qubits)  
    //      and one for Quantum functional programming (ie, with Qubits)
    //  
    
    
    //////////////////////////////////////////////////////////////////
    // Part I. Classical Functional Techniques in Q#
    //////////////////////////////////////////////////////////////////

    //Additional function for Task 1.1
    function Add7 ( addend: Int ) : Int {
        return addend + 7;
    }

    // Task 1.1. Functions as first-class citizens
    // Input: An Integer
    // Goal:  Add 7 to the input Integer, by using the adder variable, defined below.
    //        The adder variable is assigned to the Add7 function, defined above.
    // 
    // Hint:  For this first task, all you have to do is comment out the current return statement 
    //        and uncomment the statement below it.
    function SimpleAdder ( addend: Int ) : Int {
        let adder = Add7;
    
        return addend;
        //return adder(addend);
	}


    //Additional functions for Task 1.2 and 1.3
    function Sum ( a: Double , b: Double) : Double {
        return a + b;
	}

    function Product ( a: Double , b: Double) : Double {
        return a * b;
	}

    // Task 1.2. Higher-Order Functions: Fold (Sum)
    // Input: An Array of Double
    // Goal:  Sum all of the elements of the input Array, without expicitly enumerating them.  You can use the Sum 
    //        function above to help you with this task.
    //        
    // This is a common task in Functional programming, so much so that non-functional languages have also encorpated
    // this capability.
    // This higher-order function is often called Fold (see:  https://en.wikipedia.org/wiki/Fold_%28higher-order_function%29 )
    // In the Q# Library, under the Microsoft.Quantum.Arrays namespace you will also find documentation on a Fold function.
    // (see: https://docs.microsoft.com/en-us/qsharp/api/qsharp/microsoft.quantum.arrays.fold )
    // 
    function Fold_Sum ( xs: Double[] ) : Double {
        // ...

        return 0.0;
	}


    // Task 1.3. Higher-Order Functions: Fold (Product)
    // Input: An Array of Double
    // Goal:  Multiply all of the elements of the input Array togather, without expicitly enumerating them.  You can use the Product 
    //        function above to help you with this task.
    // 
    function Fold_Product ( xs: Double[] ) : Double {
        // ...

        return 0.0;
	}


    //Additional functions for Task 1.4
    function FractionPi_to_Radians ( fractionPiNumerator: Int , fractionPiDenominator: Int ) : Double {
        return IntAsDouble(fractionPiNumerator) * PI() / IntAsDouble(fractionPiDenominator); 
	}

    function Radians_to_Degrees ( radians: Double ) : Double {
        return radians * 180.0 / PI();
	}

    function ComposeImpl ( outerfn: (Double -> Double), innerfn: ( (Int, Int) -> Double ), fractionPiNumerator: Int, fractionPiDenominator: Int ) : Double {
        return outerfn(innerfn(fractionPiNumerator, fractionPiDenominator));
	}

    function DummyFn(dummyvar1: Int, dummyvar2: Int) : Double {
        return 0.0;
	}

    function Compose ( outerfn: (Double -> Double), innerfn: ( (Int, Int) -> Double )) : ( (Int, Int) -> Double ) {
        // ...
        return DummyFn;
	}


    // Task 1.4. Composing Functions and Partial Function Application
    // Input: Two Integers which represent the numerator and denominator of a fraction of Pi for an angle.  For 3Pi/2 the inputs would be 3 and 2, respectively 
    // Goal:  You are provided a function that maps from the numerator and denominator of a fraction of Pi (the measure of an angle) to Radians.  You are also provided 
    //        a function that maps from Radians to Degrees.  The goal is to compose those functions together, into a function which takes the fractional components and
    //        converts them to Degrees.  The main function below is written for you, as well.  Your task is to write the Compose function, by calling the ComposeImpl function.
    // 
    // For a general discussion of Partial Function Application from a computer-science theoretical perspective, see:  https://en.wikipedia.org/wiki/Partial_application.
    // For details on Q# function composition, see: https://docs.microsoft.com/en-us/quantum/user-guide/using-qsharp/operations-functions  
    //
    function Compose_Functions (fractionPiNumerator: Int, fractionPiDenominator: Int) : Double {
        let FractionPi_to_Degrees = Compose(Radians_to_Degrees, FractionPi_to_Radians);
        return FractionPi_to_Degrees(fractionPiNumerator, fractionPiDenominator);
	}


    //////////////////////////////////////////////////////////////////
    // Part II. Quantum Functional Techniques in Q#
    //////////////////////////////////////////////////////////////////
    //
    // As we move into Quantum applications of functional techniques, the Standard Quantum Libararies provide additional support for these techniques.
    // A good jumping off point for this capability is here:  https://docs.microsoft.com/en-us/quantum/user-guide/libraries/standard/control-flow
    //
    // Also note that we are moving from functions to operations for our work, where the Conrolled and Adjunct functors begin to play a role.
    // For more information, see:  https://docs.microsoft.com/en-us/quantum/user-guide/using-qsharp/operations-functions#controlled-and-adjoint-operations

    // Task 2.1. Creating a Uniform Superposition on a register(an Array) of Qubits
    // Input:  A register of qubits (ie, an Array of qubits that could be any length)
    // Goal:   Place the register into a uniform superposition
    // Hint:   You only need one command to accomplish this task

    operation Uniform_Superposition( xs: Qubit[] ) : Unit is Adj + Ctl {
        //...
	}



    // Task 2.2. Operating on Multiple Pairs of Qubits in a Register of Qubits
    //
    // Some quantum algorythms call for a chain of applications of a CNOT gate to a set of qubits.  For example, if you have 4 qubits, you may need to apply a
    // series of CNOT gates in this fashon:
    // CNOT(first_qubit, second_qubit)
    // CNOT(second_qubit, third_qubit)
    // CNOT(third_qubit, fourth_qubit)
    // and the Quantum Standard Libraries assist with this sort of higher-order control flow
    //
    // Input:  A register of qubits (ie, an Array of qubits that could be any length)
    // Goal:   Apply the CNOT to each successive pair of qubits in the register
    // Hint:   You can use the Zip command to simplify this task

    operation Multiple_CNOT(qs: Qubit[]) : Unit is Adj + Ctl {
        //...

	}

    // Task 2.3. - 2.6 Assembling Parts of the Deutsch-Jozsa Algorithm from Oracles (Functions)
    //
    // For deeper explaination of the Deutsch-Jozsa Algorithm, you start by reading the introductions for:
    //    the Quantum Kata tutorial here:  ../turorials/ExploringDeutschJozsaAlgorithm/README.md
    //    and the Quantum Kata here: ../DeutschJozsaAlgorithm/README.md
    // 
    // For the purposes of these next few tasks, we have simplified the implementation to two qubits:  one qubit for the input and one qubit to make the Oracle
    // reversable (Adjoint).  so the function that we are trying to determine is either constant or balanced will be one of these four functions:
    //    1.  Constant 0:  always returning 0                      mapping 0 -> 0 and mapping 1 -> 0
    //    2.  Constant 1:  always returning 1                      mapping 0 -> 1 and mapping 1 -> 1
    //    3.  Identity:    always returning the input unchanged    mapping 0 -> 0 and mapping 1 -> 1
    //    4.  Negation:    always returning the opposite           mapping 0 -> 1 and mapping 1 -> 0
    //
    // Inputs:  The oracle operation and the IsOracleConstant operation below
    // Goal:    Compose one Oracle operation with the IsOracleConstant operation to complete each Task, to answer the question IsXXXXXXXConstant


    // oracles are the next 4 functions
    operation ConstantZero_Oracle(qs: Qubit[]) : Unit is Adj + Ctl {
	}

    operation ConstantOne_Oracle(qs: Qubit[]) : Unit is Adj + Ctl {
        X(qs[1]);
	}

    operation Identity_Oracle(qs:  Qubit[]) : Unit is Adj + Ctl {
        CNOT(qs[0], qs[1]);
	}

    operation Negation_Oracle(qs:  Qubit[]) : Unit is Adj + Ctl {
        CNOT(qs[0], qs[1]);
        X(qs[1]);
	}

    // this is the core of the DJ algorithm, where the qubits are prepared and then the oracle is applied, qubits are post-processed and then measured
    operation IsOracleConstant(oracle: (Qubit[] => Unit )) : Bool {
        mutable result = Zero;

        using (qs = Qubit[2])
		{
			X(qs[0]);
			X(qs[1]);
			H(qs[0]);
			H(qs[1]);

			oracle(qs);

			H(qs[0]);
			H(qs[1]);

			set result = M(qs[0]);
            let _ = M(qs[1]);
		}

		return One == result;
	}

    // Task 2.3. Deutsch-Jozsa Algorithm:  determine if Constant Zero oracle is constant or balanced
    operation IsConstantZeroConstant() : Bool {
        //note:  the answer below is wrong, but this will compile
        return false;
	}

    // Task 2.4. Deutsch-Jozsa Algorithm:  determine if Constant One oracle is constant or balanced
    operation IsConstantOneConstant() : Bool {
        //note:  the answer below is wrong, but this will compile
        return false;
	}

    // Task 2.5. Deutsch-Jozsa Algorithm:  determine if Identity oracle is constant or balanced
    operation IsIdentityConstant() : Bool {
        //note:  the answer below is wrong, but this will compile
        return true;
	}

    // Task 2.6. Deutsch-Jozsa Algorithm:  determine if Negation oracle is constant or balanced
    operation IsNegationConstant() : Bool {
        //note:  the answer below is wrong, but this will compile
        return true;
	}
}
