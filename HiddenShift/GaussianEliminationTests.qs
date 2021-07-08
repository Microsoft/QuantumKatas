namespace Quantum.Kata.HiddenShift.GaussianEliminationTests
{
    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Canon;
	open Quantum.Kata.HiddenShift;

    operation BasicTest () : Unit
    {
        let result = GaussianEliminationMod2([
			[1, 0],
			[1, 1]
		]);

		AssertIntMatrixEqual(result, [
			[1, 0],
			[0, 1]
		], "");
    }
	
	operation FirstColumnHasZerosTest() : Unit
    {		
		let result = GaussianEliminationMod2([
			[0, 1, 1],
			[0, 0, 1]
		]);

		AssertIntMatrixEqual(result, [
			[0, 1, 0],
			[0, 0, 1]
		], "");
    }
	
	operation MiddleColumnHasZerosTest() : Unit
    {		
		let result = GaussianEliminationMod2([
			[1, 0, 1],
			[0, 0, 1]
		]);

		AssertIntMatrixEqual(result, [
			[1, 0, 0],
			[0, 0, 1]
		], "");
    }
	
	operation TwoIdenticalRowsTest() : Unit
    {		
		let result = GaussianEliminationMod2([
			[1, 1, 0],
			[1, 1, 0],
			[0, 0, 0]
		]);

		AssertIntMatrixEqual(result, [
			[1, 1, 0],
			[0, 0, 0],
			[0, 0, 0]
		], "");
    }

	operation OnlyFlipIf1Test () : Unit
    {
		// In the second column, only one value is 1, so none of the rows should be modified
        let result = GaussianEliminationMod2([
			[1, 0, 1, 0],
			[0, 1, 1, 0],
			[0, 0, 0, 0]
		]);

		AssertIntMatrixEqual(result, [
			[1, 0, 1, 0],
			[0, 1, 1, 0],
			[0, 0, 0, 0]
		], "");
    }

	operation FlipIf1Test () : Unit
    {
		// In the second column, both the first and third rows and added with the second
        let result = GaussianEliminationMod2([
			[1, 1, 1, 0],
			[0, 1, 1, 0],
			[0, 1, 0, 0]
		]);

		AssertIntMatrixEqual(result, [
			[1, 0, 0, 0],
			[0, 1, 0, 0],
			[0, 0, 1, 0]
		], "");
    }

	operation DoSwapsTest() : Unit
    {
		// In the second column, both the first and third rows and added with the second
        let result = GaussianEliminationMod2([
			[0, 0, 1, 0],
			[0, 1, 0, 0],
			[1, 0, 0, 0]
		]);

		AssertIntMatrixEqual(result, [
			[1, 0, 0, 0],
			[0, 1, 0, 0],
			[0, 0, 1, 0]
		], "");
    }
	
	operation EliminateRowTest() : Unit
    {
        let result = GaussianEliminationMod2([
			[0, 0, 1, 0],
			[0, 1, 0, 0],
			[0, 1, 0, 0],
			[1, 0, 0, 0]
		]);

		AssertIntMatrixEqual(result, [
			[1, 0, 0, 0],
			[0, 1, 0, 0],
			[0, 0, 1, 0],
			[0, 0, 0, 0]
		], "");
    }

	operation BasicKernelTest() : Unit
    {
        let result = KernelMod2([
			[1, 0, 0, 0],
			[0, 1, 0, 0],
			[0, 0, 1, 0],
			[0, 0, 0, 0]
		]);

		AssertSubspaceEqual(result, [
			[0, 0, 0, 1]
		], "");
    }

	operation TrickyKernelTest() : Unit
    {
        let result = KernelMod2([
			[1, 0, 0, 1],
			[0, 1, 1, 1]
		]);
		
		AssertSubspaceEqual(result, [
			[1, 1, 0, 1],
			[0, 1, 1, 0]
		], "");
    }

	operation TwoIdenticalRowsKernelTest() : Unit
    {		
		let result = KernelMod2([
			[1, 1, 0],
			[1, 1, 0],
			[0, 0, 0]
		]);

		AssertSubspaceEqual(result, [
			[1, 1, 0],
			[0, 0, 1]
		], "");
    }

	operation NonPivotInMiddleTest() : Unit {
	
		let result = KernelMod2([
			[1,0,1,0,0],
			[0,1,0,0,0],
			[0,0,0,1,0],
			[0,0,0,0,1]
		]);

		AssertSubspaceEqual(result, [
			[1, 0, 1, 0, 0]
		], "");
	}
	
	operation MultipleNonPivotInMiddleTest() : Unit {
	
		let result = KernelMod2([
			[1,0,1,0,0],
			[0,1,0,0,0],
			[0,0,0,0,1]
		]);

		AssertSubspaceEqual(result, [
			[1, 0, 1, 0, 0],
			[0, 0, 0, 1, 0]
		], "");
	}

	function AssertIntMatrixEqual(actual: Int[][], expected: Int[][], message: String) : Unit {
		AssertIntEqual(Length(actual), Length(expected), message);
		for (i in 0..Length(actual)-1) {
			AssertBoolEqual(IntVectorEqual(actual[i], expected[i]), true, $"Expected: {expected} Actual: {actual}. {message}");
		}
	}

	function AssertSubspaceEqual(actualBasis: Int[][], expectedBasis: Int[][], message: String) : Unit {
		AssertIntEqual(Length(actualBasis), Length(expectedBasis), message);
		for (i in 0..Length(actualBasis)-1) {
			mutable foundMatch = false;
			for (j in 0..Length(expectedBasis) - 1) {
				set foundMatch = foundMatch || IntVectorEqual(actualBasis[i], expectedBasis[j]);
			}
			AssertBoolEqual(foundMatch, true, $"Expected: {expectedBasis} Actual: {actualBasis}. {message}");
		}
	}

	function IntVectorEqual(a: Int[], b: Int[]) : Bool {
		if (Length(a) != Length(b)) {
			return false;
		}

		mutable equal = true;
		for (i in 0..Length(a)-1) {
			set equal = equal && a[i] == b[i];
		}

		return equal;
	}
}
