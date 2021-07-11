// Copyright (c) Wenjun Hou.
// Licensed under the MIT license.

//////////////////////////////////////////////////////////////////////
// This file contains testing harness for all tasks.
// You should not modify anything in this file.
// The tasks themselves can be found in Tasks.qs file.
//////////////////////////////////////////////////////////////////////

namespace Quantum.Kata.BoundedKnapsack
{
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Measurement;
    open Quantum.Kata.Utils;


    // Hardcoded sets of 0-1 knapsack problem parameters, for testing the operations
    // The function returns an array of tuples, each representing a set of parameters.
    // The contents of each tuple include: n, W, P, itemWeights, itemProfits (in that order).
    function ExampleSets_01 () : (Int, Int, Int, Int[], Int[])[] {
        return [(2, 6, 3, [2,5], [1,3]),
                (3, 12, 15, [2,3,10], [2,3,15]),
                (3, 9, 5, [6,3,1], [5,2,1]),
                (4, 4, 9, [1,2,3,1], [2,4,9,2]),
                (5, 16, 16, [7,7,2,3,3], [3,2,9,6,5])];
    }


    operation T11_MeasureCombination_01_Test() : Unit {
        for (n in 1..4){
            // Iterate through all possible combinations.
            for (combo in 0 .. (1 <<< n) - 1){
                using (selectedItems = Qubit[n]){
                    // Prepare the register so that it contains the integer a in little-endian format.
                    let binaryCombo = IntAsBoolArray(combo, n);
                    ApplyPauliFromBitString(PauliX, true, binaryCombo, selectedItems);
                    let measuredCombo = MeasureCombination_01(selectedItems);
                    Fact(BoolArrayAsInt(measuredCombo) == combo, $"Unexpected result for combination {binaryCombo} : {measuredCombo}");
                }
            }
        }
    }


    operation T12_NumQubitsTotalValue_01_Test () : Unit {
        for ((n, W, P, itemWeights, itemProfits) in ExampleSets_01()){
            let numQubitsTotalWeight = NumQubitsTotalValue_01(itemWeights);
            Fact(numQubitsTotalWeight == NumQubitsTotalValue_01_Reference(itemWeights), $"Unexpected result for itemWeights = {itemWeights} : {numQubitsTotalWeight}");
            
            let numQubitsTotalProfit = NumQubitsTotalValue_01(itemProfits);
            Fact(numQubitsTotalProfit == NumQubitsTotalValue_01_Reference(itemProfits), $"Unexpected result for itemProfits = {itemProfits} : {numQubitsTotalProfit}");
        }
    }


    operation T13_CalculateTotalValueOfSelectedItems_01_Test () : Unit {
        for ((n, W, P, itemWeights, itemProfits) in ExampleSets_01()){
            let numQubitsTotalWeight = NumQubitsTotalValue_01_Reference(itemWeights);
            using ((selectedItems, totalWeight) = (Qubit[n], Qubit[numQubitsTotalWeight])){
                // Iterate through all possible combinations of items.
                for (combo in 0..(1 <<< n) - 1){
                    // Prepare the register so that it represents the combination.
                    let binaryCombo = IntAsBoolArray(combo, n);
                    ApplyPauliFromBitString(PauliX, true, binaryCombo, selectedItems);

                    // Reset the counter of measurements done
                    ResetOracleCallsCount();

                    // Calculate and measure the weight with qubits
                    CalculateTotalValueOfSelectedItems_01(itemWeights, selectedItems, totalWeight);
                    
                    // Make sure the solution didn't use any measurements
                    Fact(GetOracleCallsCount(M) == 0, "You are not allowed to use measurements in this task");
                    Fact(GetOracleCallsCount(Measure) == 0, "You are not allowed to use measurements in this task");

                    mutable MeasuredWeight = ResultArrayAsInt(MultiM(totalWeight));

                    // Calculate the weight classically
                    mutable actualWeight = 0;
                    for (i in 0..n-1){
                        if (binaryCombo[i]){
                            set actualWeight += itemWeights[i];
                        }
                    }

                    // Assert that both methods yield the same result
                    Fact(actualWeight == MeasuredWeight, $"Unexpected result for selectedItems = {binaryCombo}, itemWeights = {itemWeights} : {MeasuredWeight}");
                    ResetAll(selectedItems);
                    ResetAll(totalWeight);
                }
            }
        }
    }


    operation T14_CompareQubitArrayGreaterThanInt_Test () : Unit {
        for (D in 1..4){
            // Iterate through all possible left operands a.
            for (a in 0 .. (1 <<< D) - 1){
                using ((selectedItems, target) = (Qubit[D], Qubit())){
                    // Prepare the register so that it contains the integer a in little-endian format.
                    let binaryA = IntAsBoolArray(a, D);
                    ApplyPauliFromBitString(PauliX, true, binaryA, selectedItems);
                                    
                    // Make sure the solution didn't use any measurements
                    Fact(GetOracleCallsCount(M) == 0, "You are not allowed to use measurements in this task");
                    Fact(GetOracleCallsCount(Measure) == 0, "You are not allowed to use measurements in this task");

                    // Iterate through all possible right operands b.
                    for (b in 0 .. (1 <<< D) - 1){
                        // Reset the counter of measurements done
                        ResetOracleCallsCount();

                        CompareQubitArrayGreaterThanInt(selectedItems, b, target);
                    
                        // Make sure the solution didn't use any measurements
                        Fact(GetOracleCallsCount(M) == 0, "You are not allowed to use measurements in this task");
                        Fact(GetOracleCallsCount(Measure) == 0, "You are not allowed to use measurements in this task");

                        let output = (M(target)==One);
                        Fact(not XOR(a > b, output), $"Unexpected result for a = {a}, b = {b} : {output}");
                        Reset(target);
                    }
                    ResetAll(selectedItems);
                }
            }
        }
    }


    operation T15_CompareQubitArrayLeqThanInt_Test () : Unit {
        for (D in 1..4){
            // Iterate through all possible left operands a.
            for (a in 0 .. (1 <<< D) - 1){
                using ((selectedItems, target) = (Qubit[D], Qubit())){
                    // Prepare the register so that it contains the integer a in little-endian format.
                    let binaryA = IntAsBoolArray(a, D);
                    ApplyPauliFromBitString(PauliX, true, binaryA, selectedItems);

                    // Iterate through all possible right operands b.
                    for (b in 0 .. (1 <<< D) - 1){
                        // Reset the counter of measurements done
                        ResetOracleCallsCount();

                        CompareQubitArrayLeqThanInt(selectedItems, b, target);
                    
                        // Make sure the solution didn't use any measurements
                        Fact(GetOracleCallsCount(M) == 0, "You are not allowed to use measurements in this task");
                        Fact(GetOracleCallsCount(Measure) == 0, "You are not allowed to use measurements in this task");

                        let output = (M(target)==One);
                        Fact(not XOR(a <= b, output), $"Unexpected result for a = {a}, b = {b} : {output}");
                        Reset(target);
                    }
                    ResetAll(selectedItems);
                }
            }
        }
    }


    operation T16_VerifyWeight_01_Test () : Unit {
        for ((n, W, P, itemWeights, itemProfits) in ExampleSets_01()){
            using ((selectedItems, target) = (Qubit[n], Qubit())){
                // Iterate through all possible combinations of items.
                for (combo in 0..(1 <<< n) - 1){
                    // Prepare the register so that it represents the combination.
                    let binaryCombo = IntAsBoolArray(combo, n);
                    ApplyPauliFromBitString(PauliX, true, binaryCombo, selectedItems);
                    
                    // Reset the counter of measurements done
                    ResetOracleCallsCount();

                    // Verify the weight with qubits
                    VerifyWeight_01(W, itemWeights, selectedItems, target);
                    
                    // Make sure the solution didn't use any measurements
                    Fact(GetOracleCallsCount(M) == 0, "You are not allowed to use measurements in this task");
                    Fact(GetOracleCallsCount(Measure) == 0, "You are not allowed to use measurements in this task");

                    let output = (M(target) == One);

                    // Verify the weight classically
                    mutable actualWeight = 0;
                    for (i in 0..n-1){
                        if (binaryCombo[i]){
                            set actualWeight += itemWeights[i];
                        }
                    }

                    // Assert that both methods yield the same result
                    Fact(not XOR(actualWeight <= W, output), $"Unexpected result for selectedItems = {binaryCombo}, itemWeights = {itemWeights}, W = {W} : {output}");
                    ResetAll(selectedItems);
                    Reset(target);
                }
            }
        }
    }


    operation T17_VerifyProfit_01_Test () : Unit {
        for ((n, W, P, itemWeights, itemProfits) in ExampleSets_01()){
            using ((selectedItems, target) = (Qubit[n], Qubit())){
                // Iterate through all possible combinations of items.
                for (combo in 0..(1 <<< n) - 1){
                    // Prepare the register so that it represents the combination.
                    let binaryCombo = IntAsBoolArray(combo, n);
                    ApplyPauliFromBitString(PauliX, true, binaryCombo, selectedItems);
                    
                    // Reset the counter of measurements done
                    ResetOracleCallsCount();

                    // Verify the profit with qubits
                    VerifyProfit_01(P, itemProfits, selectedItems, target);
                    
                    // Make sure the solution didn't use any measurements
                    Fact(GetOracleCallsCount(M) == 0, "You are not allowed to use measurements in this task");
                    Fact(GetOracleCallsCount(Measure) == 0, "You are not allowed to use measurements in this task");

                    let output = (M(target) == One);

                    // Verify the profit classically
                    mutable actualProfit = 0;
                    for (i in 0..n-1){
                        if (binaryCombo[i]){
                            set actualProfit += itemProfits[i];
                        }
                    }

                    // Assert that both methods yield the same result
                    Fact(not XOR(actualProfit > P, output), $"Unexpected result for selectedItems = {binaryCombo}, itemProfits = {itemProfits}, P = {P} : {output}");
                    ResetAll(selectedItems);
                    Reset(target);
                }
            }
        }
    }


    operation T18_KnapsackValidationOracle_01_Test () : Unit {
        for ((n, W, P, itemWeights, itemProfits) in ExampleSets_01()){
            using ((selectedItems, target) = (Qubit[n], Qubit())){
                // Iterate through all possible combinations of items.
                for (combo in 0..(1 <<< n) - 1){
                    // Prepare the register so that it represents the combination.
                    let binaryCombo = IntAsBoolArray(combo, n);
                    ApplyPauliFromBitString(PauliX, true, binaryCombo, selectedItems);
                    
                    // Reset the counter of measurements done
                    ResetOracleCallsCount();

                    // Verify the combination with qubits
                    KnapsackValidationOracle_01(W, P, itemWeights, itemProfits, selectedItems, target);
                    
                    // Make sure the solution didn't use any measurements
                    Fact(GetOracleCallsCount(M) == 0, "You are not allowed to use measurements in this task");
                    Fact(GetOracleCallsCount(Measure) == 0, "You are not allowed to use measurements in this task");

                    let output = (M(target) == One);

                    // Verify the combination classically
                    mutable actualWeight = 0;
                    mutable actualProfit = 0;
                    for (i in 0..n-1){
                        if (binaryCombo[i]){
                            set actualWeight += itemWeights[i];
                            set actualProfit += itemProfits[i];
                        }
                    }

                    // Assert that both methods yield the same result
                    Fact(not XOR(actualWeight <= W and actualProfit > P, output), $"Unexpected result for selectedItems = {binaryCombo}, itemWeights = {itemWeights}, itemProfits = {itemProfits}, P = {P} : {output}");
                    ResetAll(selectedItems);
                    Reset(target);
                }
            }
        }
    }


    //////////////////////////////////////////////////////////////////
    // Part II. Bounded Knapsack Problem
    //////////////////////////////////////////////////////////////////
    
    // Hardcoded sets of knapsack problem parameters, for testing the operations
    // The function returns an array of tuples, each representing a set of parameters.
    // The contents of each tuple include: n, W, P, itemWeights, itemProfits, P_max (in that order).
    // Note: For each set, P is a sample profit threshold for testing that set in the
    //       knapsack decision problem. P_max is the maximum profit achievable within the
    //       given bounds and weight constraints of that set (i.e. the solution to the
    //       knapsack optimization problem). P and P_max will never actually be used in the
    //       same test.
    function ExampleSets () : (Int, Int, Int, Int[], Int[], Int[], Int)[] {
        return [(2, 30, 10, [2,5], [1,3], [7,5], 17),
                (3, 24, 16, [2,3,10], [2,3,15], [6,5,2], 24),
                (3, 16, 5, [6,3,1], [5,2,1], [4,7,2], 13),
                (4, 14, 24, [1,2,3,1], [2,4,9,2], [4,3,2,3], 34)];
    }


    operation T21_MeasureCombination_Test () : Unit {
        for ((n, W, P, itemWeights, itemProfits, itemInstanceBounds, P_max) in ExampleSets()){

            // Calculate the total number of qubits
            let Q = RegisterSize(n, itemInstanceBounds);
            using (register = Qubit[Q]){
                // It will be too time-intensive to iterate through all possible combinations of items,
                // so a random selection of combinations will be used for testing.
                mutable combos = new Int[4*Q];
                for (c in 0..4*Q-1){
                    set combos w/= c <- RandomIntPow2(Q);
                }
                
                // Iterate through the selected combinations.
                for (combo in combos){
                    // Prepare the register so that it represents the combination.
                    let binaryCombo = IntAsBoolArray(combo, Q);
                    ApplyPauliFromBitString(PauliX, true, binaryCombo, register);
                    
                    // Reset the counter of measurements done
                    ResetOracleCallsCount();

                    // Convert the quantum register.
                    let xs = RegisterAsJaggedArray_Reference(n, itemInstanceBounds, register);
                    
                    // Make sure the solution didn't use any measurements
                    Fact(GetOracleCallsCount(M) == 0, "You are not allowed to use measurements in this task");
                    Fact(GetOracleCallsCount(Measure) == 0, "You are not allowed to use measurements in this task");

                    // Measure the combination.
                    let measuredXsCombo = MeasureCombination(xs);

                    // Assert that both methods yield the same result
                    let xsCombo = BoolArrayAsIntArray(n, itemInstanceBounds, binaryCombo);
                    Fact(Length(measuredXsCombo) == n, $"Unexpected result for combination {xsCombo} : Output array has length {Length(measuredXsCombo)}, should have {n}.");
                    for (i in 0..n-1){
                        Fact(measuredXsCombo[i] == xsCombo[i], $"Unexpected result for combination {xsCombo} : At index {i}, the output has integer {measuredXsCombo[i]}, should be {xsCombo[i]}.");
                    }
                    ResetAll(register);
                }
            }
        }
    }


    operation T22_RegisterAsJaggedArray_Test () : Unit {
        for ((n, W, P, itemWeights, itemProfits, itemInstanceBounds, P_max) in ExampleSets()){

            // Calculate the total number of qubits
            let Q = RegisterSize(n, itemInstanceBounds);

            using (register = Qubit[Q]){
                // It will be too time-intensive to iterate through all possible combinations of items,
                // so a random selection of combinations will be used for testing.
                mutable combos = new Int[2*Q];
                for (c in 0..2*Q-1){
                    set combos w/= c <- RandomIntPow2(Q);
                }

                // Iterate through the selected combinations.
                for (combo in combos){
                    // Prepare the register so that it represents the combination.
                    let binaryCombo = IntAsBoolArray(combo, Q);
                    ApplyPauliFromBitString(PauliX, true, binaryCombo, register);

                    // Reset the counter of measurements done
                    ResetOracleCallsCount();

                    // Convert the quantum register.
                    let xs = RegisterAsJaggedArray(n, itemInstanceBounds, register);
                    
                    // Make sure the solution didn't use any measurements
                    Fact(GetOracleCallsCount(M) == 0, "You are not allowed to use measurements in this task");
                    Fact(GetOracleCallsCount(Measure) == 0, "You are not allowed to use measurements in this task");

                    // Convert the register classically as an Int array.
                    let xsCombo = BoolArrayAsIntArray(n, itemInstanceBounds, binaryCombo);

                    // Assert that both methods yield the same result
                    Fact(Length(xs) == n, $"Unexpected result for combination {xsCombo} : Output jagged array has length {Length(xs)}, should have {n}.");
                    for (i in 0..n-1){
                        Fact(Length(xs[i]) == BitSizeI(itemInstanceBounds[i]), $"Unexpected result for combination {xsCombo} : The array at index {i} in the output jagged array has length {Length(xs[i])}, should have {BitSizeI(itemInstanceBounds[i])}.");
                        let outputInt = ResultArrayAsInt(MultiM(xs[i]));
                        Fact(outputInt == xsCombo[i], $"Unexpected result for combination {xsCombo} : At index {i}, the output has integer {outputInt}, should be {xsCombo[i]}.");
                    }
                    ResetAll(register);
                }
            }
        }
    }
    

    operation T23_VerifyBounds_Test () : Unit {
        for ((n, W, P, itemWeights, itemProfits, itemInstanceBounds, P_max) in ExampleSets()){

            // Calculate the total number of qubits
            let Q = RegisterSize(n, itemInstanceBounds);

            using ((register, target) = (Qubit[Q], Qubit())){
                // It will be too time-intensive to iterate through all possible combinations of items,
                // so a random selection of combinations will be used for testing.
                mutable combos = new Int[2*Q];
                for (c in 0..2*Q-1){
                    set combos w/= c <- RandomIntPow2(Q);
                }

                // Iterate through the selected combinations.
                for (combo in combos){
                    // Prepare the register so that it represents the combination.
                    let binaryCombo = IntAsBoolArray(combo, Q);
                    ApplyPauliFromBitString(PauliX, true, binaryCombo, register);
                    
                    // Reset the counter of measurements done
                    ResetOracleCallsCount();

                    // Verify the bounds with qubits
                    let xs = RegisterAsJaggedArray_Reference(n, itemInstanceBounds, register);
                    VerifyBounds(n, itemInstanceBounds, xs, target);
                    
                    // Make sure the solution didn't use any measurements
                    Fact(GetOracleCallsCount(M) == 0, "You are not allowed to use measurements in this task");
                    Fact(GetOracleCallsCount(Measure) == 0, "You are not allowed to use measurements in this task");

                    let output = (M(target) == One);

                    // Verify the bounds classically
                    let xsCombo = BoolArrayAsIntArray(n, itemInstanceBounds, binaryCombo);
                    mutable actualBounds = true;
                    for (i in 0..n-1){
                        // If any bound isn't satisfied, the operation should return 0.
                        if (xsCombo[i] > itemInstanceBounds[i]){
                            set actualBounds = false;
                        }
                    }

                    // Assert that both methods yield the same result
                    Fact(not XOR(actualBounds, output), $"Unexpected result for xs = {xsCombo}, itemInstanceBounds = {itemInstanceBounds} : {output}");
                    ResetAll(register);
                    Reset(target);
                }
            }
        }
    }

    operation T24_IncrementByProduct_Test () : Unit {
        for (D in 1..3){
            using ((qy, qz) = (Qubit[D], Qubit[D])){

                // Iterate through all possible left operands a.
                for (x in 0 .. (1 <<< D) - 1){

                    // Iterate through all possible right operands y.
                    for (y in 0 .. (1 <<< D) - 1){
                        // Prepare the register so that it contains the integer y in little-endian format.
                        let binaryY = IntAsBoolArray(y, D);
                        ApplyPauliFromBitString(PauliX, true, binaryY, qy);

                        // Iterate through all initial values of z.
                        for (z in 0 .. (1 <<< D) - 1){
                            // Prepare the register so that it contains the integer z in little-endian format.
                            let binaryZ = IntAsBoolArray(z, D);
                            ApplyPauliFromBitString(PauliX, true, binaryZ, qz);
                            
                            // Reset the counter of measurements done
                            ResetOracleCallsCount();

                            IncrementByProduct(x, qy, qz);
                    
                            // Make sure the solution didn't use any measurements
                            Fact(GetOracleCallsCount(M) == 0, "You are not allowed to use measurements in this task");
                            Fact(GetOracleCallsCount(Measure) == 0, "You are not allowed to use measurements in this task");

                            let measuredZ = ResultArrayAsInt(MultiM(qz));
                            Fact(measuredZ == (z + x*y) % (1 <<< D), $"Unexpected result for x = {x}, y = {y}, z = {z} : {measuredZ}");
                            ResetAll(qz);
                        }
                        ResetAll(qy);
                    }
                }
            }
        }
    }


    operation T25_NumQubitsTotalValue_Reference_Test () : Unit {
        for ((n, W, P, itemWeights, itemProfits, itemInstanceBounds, P_max) in ExampleSets()){
            let numQubitsTotalWeight = NumQubitsTotalValue(itemWeights, itemInstanceBounds);
            Fact(numQubitsTotalWeight == NumQubitsTotalValue_Reference(itemWeights, itemInstanceBounds), $"Unexpected result for itemWeights = {itemWeights}, itemInstanceBounds = {itemInstanceBounds} : {numQubitsTotalWeight}");
            
            let numQubitsTotalProfit = NumQubitsTotalValue(itemProfits, itemInstanceBounds);
            Fact(numQubitsTotalProfit == NumQubitsTotalValue_Reference(itemProfits, itemInstanceBounds), $"Unexpected result for itemProfits = {itemProfits}, itemInstanceBounds = {itemInstanceBounds} : {numQubitsTotalProfit}");
        }
    }


    operation T26_CalculateTotalValueOfSelectedItems_Test () : Unit {
        for ((n, W, P, itemWeights, itemProfits, itemInstanceBounds, P_max) in ExampleSets()){

            // Calculate the total number of qubits
            let Q = RegisterSize(n, itemInstanceBounds);

            let numQubitsTotalWeight = NumQubitsTotalValue_Reference(itemWeights, itemInstanceBounds);
            let numQubitsTotalProfit = NumQubitsTotalValue_Reference(itemProfits, itemInstanceBounds);

            using ((register, totalWeight, totalProfit) = (Qubit[Q], Qubit[numQubitsTotalWeight], Qubit[numQubitsTotalProfit])){
                // It will be too time-intensive to iterate through all possible combinations of items,
                // so a random selection of combinations will be used for testing.
                mutable combos = new Int[2*Q];
                for (c in 0..2*Q-1){
                    set combos w/= c <- RandomIntPow2(Q);
                }

                // Iterate through the selected combinations.
                for (combo in combos){
                    // Prepare the register so that it represents the combination.
                    let binaryCombo = IntAsBoolArray(combo, Q);
                    ApplyPauliFromBitString(PauliX, true, binaryCombo, register);

                    // Reset the counter of measurements done
                    ResetOracleCallsCount();

                    // Calculate and measure the total weight and profit with qubits
                    let xs = RegisterAsJaggedArray_Reference(n, itemInstanceBounds, register);
                    CalculateTotalValueOfSelectedItems(itemWeights, xs, totalWeight);
                    CalculateTotalValueOfSelectedItems(itemProfits, xs, totalProfit);
                    
                    // Make sure the solution didn't use any measurements
                    Fact(GetOracleCallsCount(M) == 0, "You are not allowed to use measurements in this task");
                    Fact(GetOracleCallsCount(Measure) == 0, "You are not allowed to use measurements in this task");

                    mutable MeasuredWeight = ResultArrayAsInt(MultiM(totalWeight));
                    mutable MeasuredProfit = ResultArrayAsInt(MultiM(totalProfit));

                    // Calculate the weight and profit classically
                    let xsCombo = BoolArrayAsIntArray(n, itemInstanceBounds, binaryCombo);
                    mutable actualWeight = 0;
                    mutable actualProfit = 0;
                    for (i in 0..n-1){
                        // Add the weight of all instances of this item type.
                        set actualWeight += itemWeights[i]*xsCombo[i];
                        set actualProfit += itemProfits[i]*xsCombo[i];
                    }

                    // Assert that both methods yield the same result
                    Fact(actualWeight == MeasuredWeight and actualProfit == MeasuredProfit, $"Unexpected result for xs = {xsCombo}, itemWeights = {itemWeights}, itemProfits = {itemProfits}: total weight {MeasuredWeight} and profit {MeasuredProfit}");
                    ResetAll(register);
                    ResetAll(totalWeight);
                    ResetAll(totalProfit);
                }
            }
        }
    }


    operation T27_VerifyWeight_Test () : Unit {
        for ((n, W, P, itemWeights, itemProfits, itemInstanceBounds, P_max) in ExampleSets()){

            // Calculate the total number of qubits
            let Q = RegisterSize(n, itemInstanceBounds);

            using ((register, target) = (Qubit[Q], Qubit())){
                // It will be too time-intensive to iterate through all possible combinations of items,
                // so a random selection of combinations will be used for testing.
                mutable combos = new Int[2*Q];
                for (c in 0..2*Q-1){
                    set combos w/= c <- RandomIntPow2(Q);
                }

                // Iterate through the selected combinations.
                for (combo in combos){
                    // Prepare the register so that it represents the combination.
                    let binaryCombo = IntAsBoolArray(combo, Q);
                    ApplyPauliFromBitString(PauliX, true, binaryCombo, register);

                    // Reset the counter of measurements done
                    ResetOracleCallsCount();

                    // Verify the weight with qubits
                    let xs = RegisterAsJaggedArray_Reference(n, itemInstanceBounds, register);
                    VerifyWeight(W, itemWeights, xs, target);
                    
                    // Make sure the solution didn't use any measurements
                    Fact(GetOracleCallsCount(M) == 0, "You are not allowed to use measurements in this task");
                    Fact(GetOracleCallsCount(Measure) == 0, "You are not allowed to use measurements in this task");

                    let output = (M(target) == One);

                    // Verify the weight classically
                    let xsCombo = BoolArrayAsIntArray(n, itemInstanceBounds, binaryCombo);
                    mutable actualWeight = 0;
                    for (i in 0..n-1){
                        // Add the weight of all instances of this item type.
                        set actualWeight += itemWeights[i]*xsCombo[i];
                    }

                    // Assert that both methods yield the same result
                    Fact(not XOR(actualWeight <= W, output), $"Unexpected result for xs = {xsCombo}, itemWeights = {itemWeights}, W = {W} : {output}");
                    ResetAll(register);
                    Reset(target);
                }
            }
        }
    }


    operation T28_VerifyProfit_Test () : Unit {
        for ((n, W, P, itemWeights, itemProfits, itemInstanceBounds, P_max) in ExampleSets()){

            // Calculate the total number of qubits
            let Q = RegisterSize(n, itemInstanceBounds);

            using ((register, target) = (Qubit[Q], Qubit())){
                // It will be too time-intensive to iterate through all possible combinations of items,
                // so a random selection of combinations will be used for testing.
                mutable combos = new Int[2*Q];
                for (c in 0..2*Q-1){
                    set combos w/= c <- RandomIntPow2(Q);
                }

                // Iterate through the selected combinations.
                for (combo in combos){
                    // Prepare the register so that it represents the combination.
                    let binaryCombo = IntAsBoolArray(combo, Q);
                    ApplyPauliFromBitString(PauliX, true, binaryCombo, register);

                    // Reset the counter of measurements done
                    ResetOracleCallsCount();

                    // Verify the profit with qubits
                    let xs = RegisterAsJaggedArray_Reference(n, itemInstanceBounds, register);
                    VerifyProfit(P, itemProfits, xs, target);
                    
                    // Make sure the solution didn't use any measurements
                    Fact(GetOracleCallsCount(M) == 0, "You are not allowed to use measurements in this task");
                    Fact(GetOracleCallsCount(Measure) == 0, "You are not allowed to use measurements in this task");

                    let output = (M(target) == One);

                    // Verify the profit classically
                    let xsCombo = BoolArrayAsIntArray(n, itemInstanceBounds, binaryCombo);
                    mutable actualProfit = 0;
                    for (i in 0..n-1){
                        // Add the profit of all instances of this item type.
                        set actualProfit += itemProfits[i]*xsCombo[i];
                    }

                    // Assert that both methods yield the same result
                    Fact(not XOR(actualProfit > P, output), $"Unexpected result for xs = {xsCombo}, itemProfits = {itemProfits}, P = {P} : {output}");
                    ResetAll(register);
                    Reset(target);
                }
            }
        }
    }


    operation T29_KnapsackValidationOracle_Test () : Unit {
        for ((n, W, P, itemWeights, itemProfits, itemInstanceBounds, P_max) in ExampleSets()){

            // Calculate the total number of qubits
            let Q = RegisterSize(n, itemInstanceBounds);

            using ((register, target) = (Qubit[Q], Qubit())){
                // It will be too time-intensive to iterate through all possible combinations of items,
                // so a random selection of combinations will be used for testing.
                mutable combos = new Int[2*Q];
                for (c in 0..2*Q-1){
                    set combos w/= c <- RandomIntPow2(Q);
                }

                // Iterate through the selected combinations.
                for (combo in combos){
                    // Prepare the register so that it represents the combination.
                    let binaryCombo = IntAsBoolArray(combo, Q);
                    ApplyPauliFromBitString(PauliX, true, binaryCombo, register);
                    
                    // Reset the counter of measurements done
                    ResetOracleCallsCount();

                    // Verify the combination with qubits
                    let xs = RegisterAsJaggedArray_Reference(n, itemInstanceBounds, register);
                    KnapsackValidationOracle(n, W, P, itemWeights, itemProfits, itemInstanceBounds, register, target);
                    
                    // Make sure the solution didn't use any measurements
                    Fact(GetOracleCallsCount(M) == 0, "You are not allowed to use measurements in this task");
                    Fact(GetOracleCallsCount(Measure) == 0, "You are not allowed to use measurements in this task");

                    let output = (M(target) == One);

                    // Verify the combination classically
                    let xsCombo = BoolArrayAsIntArray(n, itemInstanceBounds, binaryCombo);
                    mutable actualBounds = true;
                    mutable actualWeight = 0;
                    mutable actualProfit = 0;
                    for (i in 0..n-1){
                        // If any bound isn't satisfied, the operation should return 0.
                        if (xsCombo[i] > itemInstanceBounds[i]){
                            set actualBounds = false;
                        }
                        // Add the weight and profit of all instances of this item type.
                        set actualWeight += itemWeights[i]*xsCombo[i];
                        set actualProfit += itemProfits[i]*xsCombo[i];
                    }

                    // Assert that both methods yield the same result
                    Fact(not XOR(actualBounds and actualWeight <= W and actualProfit > P, output), $"Unexpected result for xs = {xsCombo}, itemWeights = {itemWeights}, itemProfits = {itemProfits}, itemInstanceBounds = {itemInstanceBounds}, P = {P} : {output}");
                    ResetAll(register);
                    Reset(target);
                }
            }
        }
    }


    //////////////////////////////////////////////////////////////////
    // Part III. Grover Search and Knapsack Optimization Problem
    //////////////////////////////////////////////////////////////////


    operation T31_GroversAlgorithm_Test () : Unit {
        let testSets = ExampleSets();
        let (n, W, P, itemWeights, itemProfits, itemInstanceBounds, P_max) = testSets[0];

        // Calculate the total number of qubits
        let Q = RegisterSize(n, itemInstanceBounds);

        using ((register, target) = (Qubit[Q], Qubit())){

            let (xs_found, P_found) = GroversAlgorithm(n, W, P, itemWeights, itemProfits, itemInstanceBounds);

            // Verify the found combination classically (should be valid if P < P_max)
            mutable actualBounds = true;
            mutable actualWeight = 0;
            mutable actualProfit = 0;
            for (i in 0..n-1){
                // If any bound isn't satisfied, the operation should return 0.
                if (xs_found[i] > itemInstanceBounds[i]){
                    set actualBounds = false;
                }
                // Add the weight and profit of all instances of this item type.
                set actualWeight += itemWeights[i]*xs_found[i];
                set actualProfit += itemProfits[i]*xs_found[i];
            }
            let valid = actualBounds and actualWeight <= W and actualProfit > P;

            // Assert that the output from Grover's algorithm is correct.
            Fact(not XOR(valid, P < P_max), $"Unexpected result for W = {W}, P = {P}, itemWeights = {itemWeights}, itemProfits = {itemProfits}, itemInstanceBounds = {itemInstanceBounds} : {xs_found}");
            ResetAll(register);
            Reset(target);
        }
    }

    operation T32_KnapsackOptimizationProblem_Test() : Unit {
        let testSets = ExampleSets();
        let (n, W, P, itemWeights, itemProfits, itemInstanceBounds, P_max) = testSets[0];

        let P_max_found = KnapsackOptimizationProblem(n, W, itemWeights, itemProfits, itemInstanceBounds);
        Fact(P_max_found == P_max, $"Unexpected result for W = {W}, P = {P}, itemWeights = {itemWeights}, itemProfits = {itemProfits}, itemInstanceBounds = {itemInstanceBounds} : {P_max_found}, should be {P_max}");
    }

}
