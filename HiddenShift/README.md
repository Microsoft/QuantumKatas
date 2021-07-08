# Welcome!

This kata covers the Hidden Shift Problem, which concerns determining a hidden shift s for
boolean bent functions f and g such that g(x) = f(x + s). This is another example of a
problem that can be solved exponentially faster by a quantum algorithm than any classical
algorithms.

This Kata consists of three parts. Task 1 concerns implementing bent boolean functions for
which problem relies upon. Task 2 concerns implementing a deterministic solution to the
Hidden Shift Problem that makes O(1) oracle calls. Finally, Task 3 concerns implementing
a reduction of the Hidden Shift Problem to Simon's Algorithm and similar instances of the
Hidden Subgroup Problem, solving the Hidden Shift Problem in O(n) oracle calls with a
guaranteed probability of success. Just as in Simon's Algorithm Kata, the classical portion
of the generalized Hidden Shift Problem Algorithm is already implemented for you. However,
unlike the Simon's Algorithm Kata, we have included a Gaussian Elimination library in Q#
along with the Kata, with which users are free to make their own tests. A dedicated test
suite is provided to validate the Gaussian Elimination functions.

#### Hidden Shift Problem
* We recommend completing the [Simon's Algorithm Kata](https://github.com/Microsoft/QuantumKatas/tree/master/SimonsAlgorithm)
before starting on this Kata.
* We recommend reading [our paper](Hidden_Shift_Problem.pdf), which goes over all the theory
and algorithms needed for completing the Hidden Shift Problem Kata.
* For more details on the Hidden Shift Problem, read [Quantum algorithms for highly non-linear Boolean functions](https://arxiv.org/abs/0811.3208) by Martin Roetteler, on which our paper is based on.
