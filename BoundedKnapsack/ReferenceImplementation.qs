// Copyright (c) Wenjun Hou.
// Licensed under the MIT license.

//////////////////////////////////////////////////////////////////////
// This file contains reference solutions to all tasks.
// The tasks themselves can be found in Tasks.qs file.
// We recommend that you try to solve the tasks yourself first,
// but feel free to look up the solution if you get stuck.
//////////////////////////////////////////////////////////////////////

namespace Quantum.Kata.BoundedKnapsack {

    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Arithmetic;
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Measurement;


    //////////////////////////////////////////////////////////////////
    // Part I. 0-1 Knapsack Problem
    //////////////////////////////////////////////////////////////////
    

    // Task 1.1. Read combination from a register
    operation MeasureCombination_01_Reference (register : Qubit[]) : Bool[] {
        return ResultArrayAsBoolArray(MultiM(register));
    }

    
    // Task 1.2. Calculate the number of qubits necessary to hold the maximum total value
    function NumQubitsTotalValue_01_Reference (itemValues : Int[]) : Int {
        mutable maxValue = 0;
        for (itemValue in itemValues){
            set maxValue += itemValue;
        }
        return BitSizeI(maxValue);
    }
    

    // Task 1.3. Calculate total value of selected items
    operation CalculateTotalValueOfSelectedItems_01_Reference (itemValues : Int[], register : Qubit[], total : Qubit[]) : Unit is Adj+Ctl {
        // Each qubit in xs determines whether the corresponding value is added.
        // This process is implemented with a control from the register.
        let totalLE = LittleEndian(total);
        for ((control, value) in Zip(register, itemValues)) {
            Controlled IncrementByInteger([control], (value, totalLE));
        }
    }


    // Task 1.4. Compare qubit array with integer (>)
    operation CompareQubitArrayGreaterThanInt_Reference (a : Qubit[], b : Int, target : Qubit) : Unit is Adj+Ctl {
        let D = Length(a);

        // Convert b into array of bits in little endian format
        let binaryB = IntAsBoolArray(b, D);

        // Iterates descending from the most significant digit, flipping the target qubit
        // upon finding i such that a[i] > binaryB[i], AND a[j] = binaryB[j] for all j > i.
        // The X gate flips a[i] to represent whether a[i] and binaryB[i] are equal, to
        // be used as controls for the Toffoli.
        // Thus, the Toffoli will only flip the target when a[i] = 1, binaryB[i] = 0, and  
        // a[j] = 1 for all j > i (meaning a and binaryB have the same digits above i).

        for(i in D-1..-1..0){
            if (not binaryB[i]) {
                // Checks if a has a greater bit than b at index i AND all bits above index i have equal values in a and b.
                Controlled X(a[i..D-1], target);
                // Flips the qubit if b's corresponding bit is 0.
                // This temporarily sets the qubit to 1 if the corresponding bits are equal.
                X(a[i]);
            }
        }

        // Uncompute
        ApplyPauliFromBitString(PauliX, false, binaryB, a);
    }


    // Task 1.5. Compare qubit array with integer (≤)
    operation CompareQubitArrayLeqThanInt_Reference (a : Qubit[], b : Int, target : Qubit) : Unit is Adj+Ctl {
        // This operation essentially calculates the opposite of the greater-than
        // comparator, so we can just call CompareQubitArrayGreaterThanInt, and then an X gate.
        CompareQubitArrayGreaterThanInt_Reference(a, b, target);
        X(target);
    }


    // Task 1.6. Verify that total weight doesn't exceed limit W
    operation VerifyWeight_01_Reference (W : Int, itemWeights : Int[], register : Qubit[], target : Qubit) : Unit is Adj+Ctl {
        let numQubitsTotalWeight = NumQubitsTotalValue_01_Reference(itemWeights);
        using (totalWeight = Qubit[numQubitsTotalWeight]) {
            within {
                CalculateTotalValueOfSelectedItems_01_Reference(itemWeights, register, totalWeight);
            } apply {
                CompareQubitArrayLeqThanInt_Reference(totalWeight, W, target);
            }
        }
    }


    // Task 1.7. Verify that the total profit exceeds threshold P
    operation VerifyProfit_01_Reference (P : Int, itemProfits : Int[], register : Qubit[], target : Qubit) : Unit is Adj+Ctl {
        let numQubitsTotalProfit = NumQubitsTotalValue_01_Reference(itemProfits);
        using (totalProfit = Qubit[numQubitsTotalProfit]) {
            within {
                CalculateTotalValueOfSelectedItems_01_Reference(itemProfits, register, totalProfit);
            } apply {
                CompareQubitArrayGreaterThanInt_Reference(totalProfit, P, target);
            }
        }
    }


    // Task 1.8. 0-1 knapsack problem validation oracle
    operation KnapsackValidationOracle_01_Reference (W : Int, P : Int, itemWeights : Int[], itemProfits : Int[], register : Qubit[], target : Qubit) : Unit is Adj+Ctl {
        using ((outputW, outputP) = (Qubit(), Qubit())) {
            within {
                VerifyWeight_01_Reference(W, itemWeights, register, outputW);
                VerifyProfit_01_Reference(P, itemProfits, register, outputP);
            } apply {
                CCNOT(outputW, outputP, target);
            }
        }
    }


    //////////////////////////////////////////////////////////////////
    // Part II. Bounded Knapsack Problem
    //////////////////////////////////////////////////////////////////
    

    // Task 2.1. Read combination from a jagged array of qubits
    operation MeasureCombination_Reference (xs : Qubit[][]) : Int[] {
        let n = Length(xs);
        mutable xsCombo = new Int[n];
        for (i in 0..n-1){
            set xsCombo w/= i <- ResultArrayAsInt(MultiM(xs[i]));
        }
        return xsCombo;
    }


    // Task 2.2. Convert qubit register into jagged qubit array
    function RegisterAsJaggedArray_Reference (n : Int, itemInstanceBounds : Int[], register : Qubit[]) : Qubit[][] {
        // Note: Declaring a new qubit array doesn't actually allocate new qubits; it allocates
        //       memory to store references to existing qubits.
        mutable xs = new Qubit[][n];
        mutable q = 0;
        for (i in 0..n-1) {
            set xs w/= i <- register[q..q+BitSizeI(itemInstanceBounds[i])-1];
            set q += BitSizeI(itemInstanceBounds[i]);
        }
        return xs;
    }


    // Task 2.3. Verification of bounds satisfaction
    operation VerifyBounds_Reference (n : Int, itemInstanceBounds : Int[], xs : Qubit[][], target : Qubit) : Unit is Adj+Ctl {
        using (satisfy = Qubit[n]) {
            within {
                for ((x, b, satisfyBit) in Zip3(xs, itemInstanceBounds, satisfy)) {
                    // Check that each individual xᵢ satisfies the bound.
                    // If the number represented by x is at most bᵢ, then the result will be 1, indicating satisfication.
                    CompareQubitArrayLeqThanInt_Reference(x, b, satisfyBit);
                }
            } apply {
                // If all are satisfied, then the combination xs passes bounds Verification.
                Controlled X(satisfy, target);
            }
        }
    }


    // Task 2.4. Increment qubit array by product of an integer and a different qubit array
    operation IncrementByProduct_Reference (x : Int, y : Qubit[], z : Qubit[]) : Unit is Adj+Ctl {
        let zLE = LittleEndian(z);

        // Calculates each partial product, y[i] · x · 2ⁱ
        // Thus, the following code adds each partial product to z, if the corresponding qubit in y is 1.
        // For more information, see https://en.wikipedia.org/wiki/Binary_multiplier#Unsigned_numbers
        for ((i, control) in Enumerated(y)) {
            Controlled IncrementByInteger([control], (x <<< i, zLE));
        }
    }

    
    // Task 2.5. Calculate the number of qubits necessary to hold the maximum total value
    function NumQubitsTotalValue_Reference (itemValues : Int[], itemInstanceBounds : Int[]) : Int {
        let n = Length(itemValues);
        mutable maxValue = 0;
        for (i in 0..n-1){
            set maxValue += itemValues[i] * itemInstanceBounds[i];
        }
        return BitSizeI(maxValue);
    }


    // Task 2.6. Calculate total value of selected items
    operation CalculateTotalValueOfSelectedItems_Reference (itemValues : Int[], xs : Qubit[][], total : Qubit[]) : Unit is Adj+Ctl {
        // The item type with index i contributes xᵢ instances to the knapsack, adding itemValues[i] per instance to the total.
        // Thus, for each item type, we increment the total by their product.
        for ((value, x) in Zip(itemValues, xs)) {
            IncrementByProduct_Reference(value, x, total);
        }
    }


    // Task 2.7. Verify that weight satisfies limit W
    operation VerifyWeight_Reference (W : Int, itemWeights : Int[], itemInstanceBounds : Int[], xs : Qubit[][], target : Qubit) : Unit is Adj+Ctl {
        let numQubitsTotalWeight = NumQubitsTotalValue_Reference(itemWeights, itemInstanceBounds);
        using (totalWeight = Qubit[numQubitsTotalWeight]) {
            within {
                // Calculate the total weight
                CalculateTotalValueOfSelectedItems_Reference(itemWeights, xs, totalWeight);
            } apply {
                CompareQubitArrayLeqThanInt_Reference(totalWeight, W, target);
            }
        }
    }


    // Task 2.8. Verify that the total profit exceeds threshold P
    operation VerifyProfit_Reference (P : Int, itemProfits : Int[], itemInstanceBounds : Int[], xs : Qubit[][], target : Qubit) : Unit is Adj+Ctl {
        let numQubitsTotalProfit = NumQubitsTotalValue_Reference(itemProfits, itemInstanceBounds);
        using (totalProfit = Qubit[numQubitsTotalProfit]) {
            within {
                // Calculate the total profit
                CalculateTotalValueOfSelectedItems_Reference(itemProfits, xs, totalProfit);
            } apply {
                CompareQubitArrayGreaterThanInt_Reference(totalProfit, P, target);
            }
        }
    }


    // Task 2.9. Bounded knapsack problem validation oracle
    operation KnapsackValidationOracle_Reference (n : Int, W : Int, P : Int, itemWeights : Int[], itemProfits : Int[], itemInstanceBounds : Int[], register : Qubit[], target : Qubit) : Unit is Adj+Ctl {
        let xs = RegisterAsJaggedArray_Reference(n, itemInstanceBounds, register);
        using ((outputB, outputW, outputP) = (Qubit(), Qubit(), Qubit())) {
            within {
                // Compute the result of each verification onto separate qubits
                VerifyBounds_Reference(n, itemInstanceBounds, xs, outputB);
                VerifyWeight_Reference(W, itemWeights, itemInstanceBounds, xs, outputW);
                VerifyProfit_Reference(P, itemProfits, itemInstanceBounds, xs, outputP);
            } apply {
                // Compute the final result, which is the AND operation of the three separate results
                // Accomplished by a triple-control Toffoli.
                Controlled X([outputB] + [outputW] + [outputP], target);
            }
        }
    }

    //////////////////////////////////////////////////////////////////
    // Part III. Knapsack Oracle and Grover Search
    //////////////////////////////////////////////////////////////////

    // Task 3.1. Using Grover search with bounded knapsack problem oracle to solve (a slightly modified version of the) knapsack decision problem
    operation GroversAlgorithm_Reference (n : Int, W : Int, P : Int, itemWeights : Int[], itemProfits : Int[], itemInstanceBounds : Int[]) : (Int[], Int) {
        
        mutable xs_found = new Int[n];
        mutable P_found = P;
        mutable correct = false;

        let Q = RegisterSize(n, itemInstanceBounds);

        // We will classically count M (the number of solutions), and calculate the optimal number of Grover Iterations.
        // In the future, this will be replaced by the quantum counting algorithm.
        let N = IntAsDouble(1 <<< Q);
        let m = IntAsDouble(NumberOfSolutions(n, W, P, itemWeights, itemProfits, itemInstanceBounds));
        if (m == 0.0){
            return (xs_found, P_found);
        }
        // Using the formula for the number of iterations, and rounding to the nearest integer
        mutable iter = Floor(PI() / 4.0 * Sqrt(N/m)+0.5);
        mutable attempts = 0;

        using (register = Qubit[Q]){
            
            repeat {
                // Note: The register is not converted into the jagged array before being used in the oracle, because
                //         the ApplyToEach operations in the GroverIterations can't directly be called on jagged arrays.
                GroversAlgorithm_Loop(register, KnapsackValidationOracle_Reference(n, W, P, itemWeights, itemProfits, itemInstanceBounds, _, _), iter);

                // Measure the combination that Grover's Algorithm finds.
                let xs = RegisterAsJaggedArray_Reference(n, itemInstanceBounds, register);
                for (i in 0..n-1){
                    let result = MultiM(xs[i]);
                    set xs_found w/= i <- ResultArrayAsInt(result);
                }

                // Check that the combination is a valid combination.
                using (output = Qubit()){
                    KnapsackValidationOracle_Reference(n, W, P, itemWeights, itemProfits, itemInstanceBounds, register, output);
                    set correct = IsResultOne(MResetZ(output));
                }

                // When the valid combination is found, calculate its profit
                if (correct){
                    let numQubitsTotalProfit = NumQubitsTotalValue_01_Reference(itemProfits);
                    using (profit = Qubit[numQubitsTotalProfit]){
                        CalculateTotalValueOfSelectedItems_Reference(itemProfits, xs, profit);
                        set P_found = ResultArrayAsInt(MultiM(profit));
                        ResetAll(profit);
                    }
                }
                ResetAll(register);
                set attempts += 1;
            } until(correct or attempts > 10);

        }

        return (xs_found, P_found);
        
    }

    internal function RegisterSize(n : Int, itemInstanceBounds : Int[]) : Int {
        // Calculate the total number of qubits for the register, given the bounds array. The item with index i can have 0 to bᵢ instances,
        // which requires log₂(bᵢ+1) qubits (rounded up). The auxiliary function BitSizeI is used to faciliate
        // this calculation. The total number of qubits, Q, is the sum of each individual number of qubits.
        mutable Q = 0;
        for (bound in itemInstanceBounds){
            set Q += BitSizeI(bound);
        }
        return Q;
    }

    // Grover loop implementation taken from SolveSATWithGrover kata.
    internal operation OracleConverterImpl (markingOracle : ((Qubit[], Qubit) => Unit is Adj), register : Qubit[]) : Unit is Adj {

        using (target = Qubit()) {
            within {
                // Put the target into the |-⟩ state
                X(target);
                H(target);
            } apply {
                // Apply the marking oracle; since the target is in the |-⟩ state,
                // flipping the target if the register satisfies the oracle condition will apply a -1 factor to the state
                markingOracle(register, target);
            }
        }
    }
    
    internal operation GroversAlgorithm_Loop (register : Qubit[], oracle : ((Qubit[], Qubit) => Unit is Adj), iterations : Int) : Unit {
        let phaseOracle = OracleConverterImpl(oracle, _);
        ApplyToEach(H, register);
            
        for (i in 1 .. iterations) {
            phaseOracle(register);
            within {
                ApplyToEachA(H, register);
                ApplyToEachA(X, register);
            } apply {
                Controlled Z(Most(register), Tail(register));
            }
        }
    }


    // A placeholder for the quantum counting algorithm, which will be implemented in a separate kata.
    // Calculate value M for the oracle (number of solutions), which is used in determining how many
    // Grover Iterations are necessary in Grover's Algorithm.
    internal function NumberOfSolutions (n : Int, W : Int, P : Int, itemWeights : Int[], itemProfits : Int[], itemInstanceBounds : Int[]) : Int {
        let Q = RegisterSize(n, itemInstanceBounds);
        mutable m = 0;
        for (combo in 0..(1 <<< Q) - 1){
            let binaryCombo = IntAsBoolArray(combo, Q);
            let xsCombo = BoolArrayAsIntArray(n, itemInstanceBounds, binaryCombo);

            // Determine if each combination is a solution.
            mutable ActualBounds = true;
            mutable ActualWeight = 0;
            mutable ActualProfit = 0;
            for (i in 0..n-1){
                // If any bound isn't satisfied, then Bounds Verification is not satisfied.
                if (xsCombo[i] > itemInstanceBounds[i]){
                    set ActualBounds = false;
                }
                // Add the weight and profit of all instances of this item type.
                set ActualWeight += itemWeights[i]*xsCombo[i];
                set ActualProfit += itemProfits[i]*xsCombo[i];
            }
            if (ActualBounds and ActualWeight <= W and ActualProfit > P) {
                set m += 1;
            }
        }
        return m;
    }


    internal function BoolArrayAsIntArray (n : Int, itemInstanceBounds : Int[], binaryCombo : Bool[]) : Int[]{
        mutable xsCombo = new Int[n];
        mutable q = 0;
        for ((i, b) in (Enumerated(itemInstanceBounds))){
            set xsCombo w/= i <- BoolArrayAsInt(binaryCombo[q..q+BitSizeI(b)-1]);
            set q += BitSizeI(b);
        }
        return xsCombo;
    }
    
    
    // Task 3.2 Solving the bounded knapsack optimization problem
    operation KnapsackOptimizationProblem_Reference (n : Int, W : Int, itemWeights : Int[], itemProfits : Int[], itemInstanceBounds : Int[]) : Int {
        // This implementation uses exponential search to search over profit thresholds and find the maximum possible profit.
        // The Grover Search using the Knapsack Oracle serves as the comparison function.
        // A description of exponential search is found at https://en.wikipedia.org/wiki/Exponential_search.

        // Determining an upper bound for a search range
        mutable P_high = 1;
        mutable upperBoundFound = false;
        repeat {
            let (xs_found, P_found) = GroversAlgorithm_Reference(n, W, P_high, itemWeights, itemProfits, itemInstanceBounds);
            if (P_found > P_high) {
                set P_high = P_high * 2;
            }
            else {
                set upperBoundFound = true;
            }
        } until (upperBoundFound);


        // Performing binary search in the determined search range
        mutable P_low = P_high / 2;
        repeat {
            let P_middle = (P_low + P_high) / 2;
            let (xs_found, P_found) = GroversAlgorithm_Reference(n, W, P_high, itemWeights, itemProfits, itemInstanceBounds);
            if (P_found > P_high){
                set P_low = P_middle;
            }
            else{
                set P_high = P_middle;
            }
        } until (P_high - P_low == 1);
        return P_high;
    }
}
