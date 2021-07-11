// Copyright (c) Wenjun Hou.
// Licensed under the MIT license.

namespace Quantum.Kata.BoundedKnapsack
{
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Arithmetic;
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Measurement;

    //////////////////////////////////////////////////////////////////
    // Welcome!
    //////////////////////////////////////////////////////////////////
    
    // The "BoundedKnapsack" quantum kata is a series of exercises designed
    // to teach you to use Grover search to solve the knapsack problem.
    // The knapsack problem is a prominent computational problem, whose
    // description can be found at https://en.wikipedia.org/wiki/Knapsack_problem

    // The overall goal in this kata is to solve the knapsack optimization problem,
    // by running Grover's algorithm multiple times.

    // The kata covers the following topics:
    //  - writing operations to perform arithmetic tasks
    //  - writing oracles to implement constraints based on:
    //        - The 0-1 knapsack problem, a simple version of the knapsack problem.
    //        - The bounded knapsack problem
    //  - using the oracle with Grover's algorithm to solve the knapsack decision problem.
    //  - using Grover's algorithm repeatedly, to solve the knapsack optimization problem.

    // You may find this kata to be more challenging than other Grover search
    // katas, so you might want to try SolveSATWithGrover or GraphColoring first.
    // Hints for the more complicated tasks can be found in the Hints.qs file.

    // Each task is wrapped in one operation preceded by the description of the task.
    // Each task (except tasks in which you have to write a test) has a unit test associated with it,
    // which initially fails. Your goal is to fill in the blank (marked with // ... comment)
    // with some Q# code to make the failing test pass.


    //////////////////////////////////////////////////////////////////
    // Part I. 0-1 Knapsack Problem
    //////////////////////////////////////////////////////////////////

    // Introduction:
    // There exist n items, indexed 0 to n-1.
    // The item with index i has a weight of wᵢ and a profit of pᵢ.
    // In the original 0-1 knapsack decision problem, we wish to 
    // determine if we can put items in a knapsack to have a total profit
    // of at least than P, while not exceeding a maximum weight W.

    // However, we will slightly modify the problem for the following tasks:
    // the total profit must be strictly greater than P, rather than at least P.

    // The following tasks will write an oracle that evaluates whether a
    // particular register of n qubits, representing an item combination,
    // satisfies the described conditions.
    

    // Task 1.1. Read combination from a register
    // Input: An array of n qubits, which are guaranteed to be in one of the 2ⁿ basis states.
    // Output: The item combination that this state represents, expressed as a boolean array with length n.
    //           The operation should not change the state of the qubits.
    // Example: For n = 3 and qubit state |101⟩, return [true, false, true].
    operation MeasureCombination_01 (selectedItems : Qubit[]) : Bool[] {
        // ...
        return new Bool[0];
    }

    
    // Task 1.2. Calculate the number of qubits necessary to hold the maximum total value
    // Input: An array of n integers, describing either the weight of each item or the profit of each item.
    // Output: The number of qubits needed to store the value of the maximum total weight/profit of the items.
    // Example: For n = 4 and itemValues = [1,2,3,4], the maximum possible total weight is 10, which requires 4 qubits,
    //          so 4 is returned.
    function NumQubitsTotalValue_01 (itemValues : Int[]) : Int {
        // ...
        return 0;
    }



    // Task 1.3. Calculate total value of selected items
    // Inputs:
    //      1) An array of n integers, describing either the weight of each item or the profit of each item.
    //        2) An array of n qubits, which describe whether each item is put into the knapsack
    //        3) An array of qubits in the |0...0⟩ state. It is guaranteed there are enough qubits to hold the total.
    // Goal: Transform the total array to represent, in little-endian format, the sum of the values of the items that are put in the knapsack.
    //       The input qubits can be in superposition. Leave the qubits in selectedItems in the same state they started in.
    // Example: For n = 4 and itemValues = [1,2,3,4], input state |1001⟩|0000⟩ transforms to |1001⟩|1010⟩, since items 0 and 3 are put
    //          in the knapsack, and itemValues[0] + itemValues[3] = 1 + 4 = 5.
    operation CalculateTotalValueOfSelectedItems_01 (itemValues : Int[], selectedItems : Qubit[], total : Qubit[]) : Unit is Adj+Ctl{
        // ...
    }
    

    // Task 1.4. Compare qubit array with integer (>)
    // Inputs:
    //        1) An array of D qubits representing an integer in little-endian format
    //        2) An integer b (0 ≤ b ≤ 2ᴰ - 1)
    //      3) A qubit in an arbitrary state (target qubit)
    // Goal: Flip the state of the target qubit if the integer represented by qs is greater than b.
    //       The input qubits can be in superposition. Leave the qubits in qs in the same state they started in.
    // Example: For b = 11, the input state |1011⟩|0⟩ should return as |1011⟩|1⟩, since 1101₂ (13) > 11.
    operation CompareQubitArrayGreaterThanInt(qs : Qubit[], b : Int, target : Qubit) : Unit is Adj+Ctl{
        // ...
    }

    
    // Task 1.5. Compare qubit array with integer (≤)
    // Inputs:
    //        1) An array of D qubits that represent an integer in little-endian format
    //        2) An integer b (0 ≤ b ≤ 2ᴰ - 1)
    //      3) A qubit in an arbitrary state (target qubit)
    // Goal: Flip the state of the target qubit if the integer represented by qs is less than or equal to b.
    //       The input qubits can be in superposition. Leave the qubits in qs in the same state they started in.
    // Example: For b = 7, the input state |1010⟩|0⟩ should return as |1010⟩|1⟩, since 0101₂ (5) ≤ 7.
    operation CompareQubitArrayLeqThanInt (qs : Qubit[], b : Int, target : Qubit) : Unit is Adj+Ctl{
        // ...
    }


    // Task 1.6. Verify that total weight doesn't exceed limit W
    // Inputs:
    //        1) An integer W, the maximum weight the knapsack can hold
    //        2) An array of n integers, such that itemWeights[i] = wᵢ
    //        3) An array of n qubits, which describe whether each item is put into the knapsack
    //        4) A qubit in an arbitrary state (target qubit)
    // Goal: Flip the state of the target qubit if the total weight is less than or equal to W.
    //       The input qubits can be in superposition. Leave the qubits in selectedItems in the same state they started in.
    operation VerifyWeight_01 (W : Int, itemWeights : Int[], selectedItems : Qubit[], target : Qubit) : Unit is Adj+Ctl{
        // ...
    }


    // Task 1.7. Verify that the total profit exceeds threshold P
    // Inputs:
    //        1) An integer P, which the total profit must exceed
    //        2) An array of n integers, such that itemProfits[i] = pᵢ
    //        3) An array of n qubits, which describe whether each item is put into the knapsack
    //        4) A qubit in an arbitrary state (target qubit)
    // Goal: Flip the state of the target qubit if the total profit is greater than P.
    //       The input qubits can be in superposition. Leave the qubits in selectedItems in the same state they started in.
    operation VerifyProfit_01 (P : Int, itemProfits : Int[], selectedItems : Qubit[], target : Qubit) : Unit is Adj+Ctl{
        // ...
    }

    // Task 1.8. 0-1 knapsack problem validation oracle
    // Inputs:
    //        1) An integer W, the maximum weight the knapsack can hold
    //        2) An integer P, which the total profit must exceed
    //        3) An array of n integers, such that itemWeights[i] = wᵢ
    //        4) An array of n integers, such that itemProfits[i] = pᵢ
    //        5) An array of n qubits, which describe whether each item is put into the knapsack
    //        6) A qubit in an arbitrary state (target qubit)
    // Goal: Flip the state of the target qubit if the weight and profit both satisfy their respective constraints.
    //       The input qubits can be in superposition. Leave the qubits in selectedItems in the same state they started in.
    operation KnapsackValidationOracle_01 (W : Int, P : Int, itemWeights : Int[], itemProfits : Int[], selectedItems : Qubit[], target : Qubit) : Unit is Adj+Ctl{
        // ...
    }


    //////////////////////////////////////////////////////////////////
    // Part II. Bounded Knapsack Problem
    //////////////////////////////////////////////////////////////////

    // Introduction:
    // Unlike in the 0-1 knapsack problem, each type of item in the bounded
    // knapsack problem can have more than one instance. Specifically,
    // for the item type with index i, between 0 and bᵢ instances (inclusive) can be put into the knapsack.
    // Let xᵢ represent the number of instances of index i that are put into the knapsack, so 0 ≤ xᵢ ≤ bᵢ for all i.
    // Thus, we seek a combination xs = [x₀, x₁, ..., xₙ₋₁] that satisfies the bounds,
    // has total weight at most W, and has total profit that is at least P.

    // Again, we slightly modify the problem, such that the total profit must
    // be strictly greater than P, rather than at least P.

    // The comparators from Part I can be reused, but the operations for
    // weight and profit calculation will need to be rewritten.


    // Task 2.1. Read combination from a jagged array of qubits
    // Inputs:
    //        1) A jagged array of qubits, with length n. Array xs[i] represents xᵢ in little-endian format.
    // Output: An integer array of length n, containing the combination that this jagged array represents.
    //         The integer at index i in the output array should have value xᵢ.
    //         The input qubits can be in superposition, and the state of the each qubit should not change.
    // Example: For state xs = [|101⟩, |1110⟩, |0100⟩], return [5, 7, 2].
    operation MeasureCombination (xs : Qubit[][]) : Int[] {
        // ...
        return new Int[0];
    }


    // Task 2.2. Convert qubit register into jagged qubit array

    // To facilitate access to the register's qubits within the oracle, the register is reorganized
    // into qubit groups, that represent, in little-endian format, the number of instances of each item type.
    // Inputs:
    //        1) An integer n, the number of items
    //        2) An array of Q qubits
    //        3) An array of n integers, such that itemInstanceBounds[i] = bᵢ.
    // Output: A jagged array of n arrays of qubits. Small array i should have enough
    //         qubits to represent any integer from 0 to bᵢ in little-endian format. Q is defined
    //         such that there are exactly enough total qubits to perform this transformation.
    //         The input qubits can be in superposition, and the state of the each qubit should not change.
    // Example: For n = 3, itemInstanceBounds = [6, 15, 13], and register in state |10111100100⟩, return [|101⟩, |1110⟩, |0100⟩].
    function RegisterAsJaggedArray (n : Int, itemInstanceBounds : Int[], register : Qubit[]) : Qubit[][]{
        // ...
        return new Qubit[][0];
    }


    // Task 2.3. Verification of bounds satisfaction
    // Inputs:
    //        1) An integer n, the number of items
    //        2) An array of n integers, such that itemInstanceBounds[i] = bᵢ.
    //        3) A jagged array of qubits, with length n. Array xs[i] represents xᵢ in little-endian format.
    //        4) A qubit in an arbitrary state (target qubit)
    // Goal: Flip the state of the target qubit if xᵢ ≤ bᵢ for all i.
    //       The input qubits can be in superposition. Leave the qubits in xs in the same state they started in.
    operation VerifyBounds (n : Int, itemInstanceBounds : Int[], xs : Qubit[][], target : Qubit) : Unit is Adj+Ctl{
        // ...
    }

    
    // Task 2.4. Increment qubit array by product of an integer and a different qubit array
    // Inputs:
    //        1) An integer x
    //        2) An array of D qubits, representing an arbitrary integer
    //        3) An second array of D qubits, representing an arbitrary integer
    // Goal: Increment z by the product of x and y.
    //       The input qubits can be in superposition. Leave the qubits in y in the same state they started in.
    operation IncrementByProduct (x : Int, y : Qubit[], z : Qubit[]) : Unit is Adj+Ctl{
        // ...
    }

    
    // Task 2.5. Calculate the number of qubits necessary to hold the maximum total value
    // Inputs:
    //      1) An array of n integers, describing either the weight of each item or the profit of each item.
    //      2) An array of n integers, such that itemInstanceBounds[i] = bᵢ.
    // Goal: The number of qubits needed to store the value of the maximum total weight/profit of the items.
    // Example: For n = 4, itemValues = [1,2,3,4] and itemInstanceBounds = [2,5,4,3], the maximum possible total weight is
    //          1*2 + 2*5 + 3*4 + 4*3 = 36, which requires 6 qubits, so 6 is returned.
    function NumQubitsTotalValue (itemValues : Int[], itemInstanceBounds : Int[]) : Int {
        // ...
        return 0;
    }


    // Task 2.6. Calculate total value of selected items
    // Inputs:
    //        1) An array of n integers, describing either the weight of each item or the profit of each item.
    //        2) A jagged array of qubits, with length n. Array xs[i] represents xᵢ in little-endian format.
    //        3) An array of qubits in the |0...0⟩ state. It is guaranteed there are enough qubits to hold the total.
    // Goal: Transform the total array to represent, in little-endian format, the sum of the values of all the instances that are put in the knapsack.
    //       The input qubits can be in superposition. Leave the qubits in xs in the same state they started in.
    operation CalculateTotalValueOfSelectedItems (itemValues : Int[], xs : Qubit[][], total : Qubit[]) : Unit is Adj+Ctl{
        // ...
    }


    // Task 2.7. Verify that weight satisfies limit W
    // Inputs:
    //        1) An integer W, the maximum weight the knapsack can hold
    //        2) An array of n integers, such that itemWeights[i] = wᵢ
    //        3) A jagged array of qubits, with length n. Array xs[i] represents xᵢ in little-endian format.
    //        4) A qubit in an arbitrary state (target qubit)
    // Goal: Flip the state of the target qubit if the total weight is less than or equal to W.
    //       The input qubits can be in superposition. Leave the qubits in xs in the same state they started in.
    operation VerifyWeight (W : Int, itemWeights : Int[], xs : Qubit[][], target : Qubit) : Unit is Adj+Ctl{
        // ...
    }


    // Task 2.8. Verify that the total profit exceeds threshold P
    // Inputs:
    //        1) An integer P, which the total profit must exceed
    //        2) An array of n integers, such that itemProfits[i] = pᵢ
    //        3) A jagged array of qubits, with length n. Array xs[i] represents xᵢ in little-endian format.
    //        4) A qubit in an arbitrary state (target qubit)
    // Goal: Flip the state of the target qubit if the total profit is greater than P.
    //       The input qubits can be in superposition. Leave the qubits in xs in the same state they started in.
    operation VerifyProfit (P : Int, itemProfits : Int[], xs : Qubit[][], target : Qubit) : Unit is Adj+Ctl{
        // ...
    }


    // Task 2.9. Bounded knapsack problem validation oracle
    // Inputs:
    //        1) An integer n, the number of items
    //        2) An integer W, the maximum weight the knapsack can hold
    //        3) An integer P, which the total profit must exceed
    //        4) An array of n integers, such that itemWeights[i] = wᵢ
    //        5) An array of n integers, such that itemProfits[i] = pᵢ
    //        6) An array of n integers, such that itemInstanceBounds[i] = bᵢ.
    //        7) An array of Q qubits. Q is the minimum number of qubits necessary to store the xs values.
    //        8) A qubit in an arbitrary state (target qubit)
    // Goal: Flip the state of the target qubit if the conditions for the bounds, weight, and profit are all satisfied.
    //       The input qubits can be in superposition. Leave the qubits in register in the same state they started in.
    operation KnapsackValidationOracle (n : Int, W : Int, P : Int, itemWeights : Int[], itemProfits : Int[], itemInstanceBounds : Int[], register : Qubit[], target : Qubit) : Unit is Adj+Ctl{
        // ...
    }


    //////////////////////////////////////////////////////////////////
    // Part III. Grover Search and Knapsack optimization problem
    //////////////////////////////////////////////////////////////////

    // Task 3.1. Using Grover search with bounded knapsack problem oracle to solve (a slightly modified version of the) knapsack decision problem
    // Inputs:
    //        1) An integer n, the number of items
    //        2) An integer W, the maximum weight the knapsack can hold
    //        3) An integer P, which the total profit must exceed
    //        4) An array of n integers, such that itemWeights[i] = wᵢ
    //        5) An array of n integers, such that itemProfits[i] = pᵢ
    //        6) An array of n integers, such that itemInstanceBounds[i] = bᵢ.
    // Output: If a combination [x₀, x₁, ..., xₙ₋₁] can be found that satisfies the bounds, has total weight at most W,
    //         and has total profit more than P, return a tuple containing that combination and its total profit.
    //         Otherwise, return a tuple containing an array of zeroes with length n and the input P value.
    operation GroversAlgorithm (n : Int, W : Int, P : Int, itemWeights : Int[], itemProfits : Int[], itemInstanceBounds : Int[]) : (Int[], Int) {
        // ...
        return (new Int[0], 0);
    }
    

    // Knapsack optimization problem:
    // The above tasks, when implemented, solve the bounded knapsack decision problem, which
    // asks: "Is there a valid combination that has more than P profit?"

    // The more common, applicable, and complex knapsack optimization problem, by contrast,
    // asks "Which valid combination yields the most profit?", or "What's the highest
    // achievable profit?", and can be solved by repeatedly answering the knapsack decision problem.

    // Thus, we will solve the optimization problem by setting a profit threshold P, repeatedly calling
    // Grover search with P, and increasing P every time Grover search concludes there exists a combination
    // more profitable than P. When Grover search determines that there exist no combinations that are
    // more profitable than P, we will have found the highest achievable profit and thus answered the
    // knapsack optimization problem.
     
    
    // Task 3.2. Solving the bounded knapsack optimization problem
    // Inputs:
    //        1) An integer n, the number of items
    //        2) An integer W, the maximum weight the knapsack can hold
    //        3) An array of n integers, such that itemWeights[i] = wᵢ
    //        4) An array of n integers, such that itemProfits[i] = pᵢ
    //        5) An array of n integers, such that itemInstanceBounds[i] = bᵢ.
    // Output: An integer, the value of the highest achievable profit among all combinations that satisfy
    //         both the instance bounds and weight constraint.
    
    operation KnapsackOptimizationProblem (n : Int, W : Int, itemWeights : Int[], itemProfits : Int[], itemInstanceBounds : Int[]) : Int {
        // ...
        return 0;
    }
}
