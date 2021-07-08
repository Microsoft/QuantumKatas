namespace Quantum.Kata.HiddenShift
{
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Primitive;

    //////////////////////////////////////////////////////////////////
    // Welcome!
    //////////////////////////////////////////////////////////////////

    // "HiddenShiftKata" quantum kata is a series of exercises designed to
    // guide you in implementing algorithms to solve the Hidden Shift Problem
    // It covers the following topics:
    //  - bent boolean oracles,
    //  - a correlation based solution to the Hidden Shift Problem,
    //  - a Hidden Subgroup based solution to the Hidden Shift Problem.

    // Each task is wrapped in one operation preceded by the description of the task.
    // Each task (except tasks in which you have to write a test) has a unit test associated with it,
    // which initially fails. Your goal is to fill in the blank (marked with // ... comment)
    // with some Q# code to make the failing test pass.

    // None of the tasks in Part I require measurement.

    // NOTE: remember that addition on a Z_2 x Z_2 x ... is defined as a bitwise XOR.

    //////////////////////////////////////////////////////////////////
    // Part I. Bent Boolean Oracles
    //////////////////////////////////////////////////////////////////

    // Task 1.1: Inner Product Oracle f(x) = \sum_{x in 1..2..i-1} x_{i} x_{i+1}
    // The binary inner product is the most natural kind of bent function, and
    // has the property where the dual of the inner product oracle is itself.
    // Inputs:
    //      1) N qubits in arbitrary state |x> (input register) (N is even)
    //      2) a qubit in arbitrary state |target> (output qubit)
    // Goal: transform state |x>|target> into state |x>|target + f(x)> (+ is addition modulo 2).
    operation InnerProductOracle(x : Qubit[], target : Qubit) : Unit {
        body (...) {
            // ...
        }
        controlled adjoint auto;
        controlled auto;
        adjoint auto;
    }

    // Task 1.2: Quadratic Boolean Oracle f(x) = x Q x^T + L x^T
    // Quadratic boolean functions are bent when the symplectic B = Q + Q^T
    // has full rank. The dual of a quadratic bent function will then be
    // a quadratic bent function.
    // Inputs:
    //      1) N qubits in arbitrary state |x> (input register) (N is even)
    //      2) a qubit in arbitrary state |target> (output qubit)
    //      3) an upper triangular N by N matrix Q with 0s along the diagonal
    //      4) an N length vector L
    // Goal: transform state |x>|target> into state |x>|target + f(x)> (+ is addition modulo 2).
    operation QuadraticOracle(x : Qubit[], target : Qubit, Q : Int[][], L : Int[]) : Unit {
        body (...) {
            // ...
        }
        controlled adjoint auto;
        controlled auto;
        adjoint auto;
    }

    // Task 1.3: Shifted Oracles
    // Given a marking oracle f that takes |x>|y> to |x>|y + f(x)>
    // and a shift s, return a marking oracle that takes |x>|y> to |x>|y + g(x)>
    // where g(x) = f(x + s).
    //
    // This task is used as a setup to the Hidden Shift Problem, but is not part of
    // the quantum algorithm solution. With it, you should be able to implement
    // your own tests of your Hidden Shift Problem solutions.
    //
    // Inputs:
    //      1) a marking oracle f
    //      2) an Int array giving a bit string s in {0, 1}^n, where n is the dimension of the domain of f.
    // Goal: return an oracle that transforms state |x>|y> into state |x>|y + g(x)>
    function ShiftedOracle(f : ((Qubit[], Qubit) => Unit : Adjoint, Controlled), s : Int[]) : ((Qubit[], Qubit) => Unit : Adjoint, Controlled) {
        // ...
        // This task returns a NoOp so that it compiles. You'll likely
        // need to return your own operation in order to get this to work.
        return NoOp<(Qubit[], Qubit)>;
    }

    // Task 1.4: Phase Flip Oracles
    // Given a marking oracle f that takes |x>|y> to |x>|y + f(x)>,
    // return a phase flip oracle that takes |x> to (-1)^f(x) |x>
    // Inputs:
    //      1) a marking oracle f
    // Goal: return an oracle that transforms state |x> into state (-1)^f(x) |x>
    function PhaseFlipOracle(f : ((Qubit[], Qubit) => Unit : Adjoint, Controlled)) : ((Qubit[]) => Unit : Adjoint, Controlled) {
        // ...
        // This task returns a NoOp so that it compiles. You'll likely
        // need to return your own operation in order to get this to work.
        return NoOp<(Qubit[])>;
    }

    //////////////////////////////////////////////////////////////////
    // Part II. Deterministic Solution to the Hidden Shift Problem
    //////////////////////////////////////////////////////////////////

    // Task 2.1. Implement the Walsh-Hadamard Transform
    // Inputs:
    //      1) N qubits in arbitrary state |x>
    //
    // Goal: Transform the state according to the Walsh-Hadamard Transform.
    //       The matrix form of the Walsh-Hadamard transform is given by
    //
    //      (1/Sqrt(2^n)) Sum_{x, y in {0, 1}^n} (-1)^(x, y) |x><y|
    //
    //      where (x, y) is the binary inner product of bit strings.
    operation WalshHadamard (x : Qubit[]) : Unit {
        // Hint: how is the Walsh-Hadamard transform written as a tensor product?
        // ...
    }

    // Task 2.2. Implementing the deterministic quantum algorithm for the Hidden Shift Problem
    // Inputs:
    //      1) the number of qubits in the input register N for the functions f, fd, and g
    //      2) a quantum operation which implements the oracle |x⟩ -> (-1)^g(x)|x⟩, where
    //         x is N-qubit input register and g is a bent boolean function
    //         from N-bit strings into {0, 1}
    //      3) a quantum operation which implements the oracle |x⟩ -> (-1)^fd(x)|x⟩, where
    //         x is N-qubit input register and fd is the dual of f, which is a bent boolean
    //         function from N-bit strings into {0, 1}
    //
    // The function g is guaranteed to satisfy the following property:
    // there exists some N-bit string s such that for all N-bit strings x we have
    // g(x) = f(x+s)
    //
    // Examples of bent boolean functions are the functions from task 1.1 and 1.2;
    // In the case of the inner product function, it is its own dual function.
    //
    // Output:
    //      The bits string s.
    operation DeterministicHiddenShiftSolution (N : Int, Ug : ((Qubit[]) => Unit), Ufd : ((Qubit[]) => Unit)) : Int[] {
        
        // Declare an Int array in which the result will be stored;
        // the array has to be mutable to allow updating its elements.
        mutable s = new Int[N];
        
        // Hint: Produce a uniform superposition on all states;
        //       Apply Ug;
        //       Apply the Walsh transform;
        //       Apply Ufd;
        //       Apply the Walsh transform;
        //       Measure out s.
        // ...

        return s;
    }


    //////////////////////////////////////////////////////////////////
    // Part III. Hidden Subgroup Based Solution to the Hidden Shift Problem
    //////////////////////////////////////////////////////////////////

    // Task 3.1. Implementing the oracle for the hidden function in the Hidden Subgroup Problem solution to the Hidden Shift Problem
    // Inputs:
    //      1) a quantum operation which implements the oracle |x⟩ -> (-1)^f(x)|x⟩, where
    //         x is N-qubit input register and f is a bent boolean function
    //         from N-bit strings into {0, 1}
    //      2) a quantum operation which implements the oracle |x⟩ -> (-1)^g(x)|x⟩, where
    //         x is N-qubit input register and g is a bent boolean function
    //         from N-bit strings into {0, 1}
    //
    // The function g is guaranteed to satisfy the following property:
    // there exists some N-bit string s such that for all N-bit strings x we have
    // g(x) = f(x+s)
    //
    // Output:
    //      a quantum operation h on inputs (b : Qubit(), x : Qubit[N], target : Qubit[N]) which computes the following value:
    //      let function k(x) = f(x) if b = 0 or g(x) if b = 1, then we map:
    //      |b⟩|x⟩|0⟩ -> |b⟩|x⟩Sum{(-1)^k(x+y)|y⟩}, where the summation is an equal superposition of every y in Z_2^n
    function HidingFunctionOracle (Uf : ((Qubit[]) => Unit : Adjoint, Controlled), Ug : ((Qubit[]) => Unit : Adjoint, Controlled)) :
            ((Qubit, Qubit[], Qubit[]) => Unit : Adjoint, Controlled) {

        // Hint: remember that addition is an order 2 operation--the same circuit operation maps y -> x + y and x + y -> y
        
        // ...

        return NoOp<(Qubit, Qubit[], Qubit[])>;
    }

    // Task 3.2. Implementing a single iteration of the Hidden Subgroup Problem solution to the Hidden Shift Problem
    // Inputs:
    //      1) the number of qubits in the input register N for the functions f and g
    //      2) a quantum operation which implements the oracle |x⟩ -> (-1)^f(x)|x⟩, where
    //         x is N-qubit input register and f is a bent boolean function
    //         from N-bit strings into {0, 1}
    //      3) a quantum operation which implements the oracle |x⟩ -> (-1)^g(x)|x⟩, where
    //         x is N-qubit input register and g is a bent boolean function
    //         from N-bit strings into {0, 1}
    //
    // The function g is guaranteed to satisfy the following property:
    // there exists some N-bit string s such that for all N-bit strings x we have
    // g(x) = f(x+s)
    //
    // Output:
    //      an integer array of length N + 1 with entries in Z_2 that is orthogonal to (1, s)
    //      in Z_2^(N+1), i.e. its dot product with (1, s) is 0
    //
    // Note that the whole algorithm will reconstruct the bit string s itself, but the quantum part of the
    // algorithm will only find some vector orthogonal to the bit string s. The classical post-processing
    // part is already implemented, so once you implement the quantum part, the tests will pass.
    operation HiddenShiftIteration(N: Int, Uf : ((Qubit[]) => Unit : Adjoint, Controlled), Ug : ((Qubit[]) => Unit : Adjoint, Controlled)) : Int[] {
		mutable result = new Int[N+1];

        // Perform the general algorithm for a Hidden Subgroup Problem with hidden function h.
        // Simply create a equal superposition of all inputs to your hidden function, apply the oracle
        // for h, uncompute the superposition, then measure the input bits. Remember that the oracle
        // expects the target register in the |0⟩ in every input state.

        // ...

        // Hint: see the Simon's Algorithm Kata

        return result;
	}
}
