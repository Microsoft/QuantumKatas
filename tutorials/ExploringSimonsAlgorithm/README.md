# Welcome!

This tutorial covers Simon's algorithm. This algorithm solves Simon's problem - an oracle problem of finding a hidden bit vector. This problem is an example of an oracle problem that can be solved exponentially faster by a quantum algorithm than any known classical algorithm.

Simon's algorithm consists of two parts - a quantum circuit and a classical post-processing routine which calls the quantum circuit repeatedly and extracts the answer from the results of the runs. This tutorial includes two companion notebooks: a Q# notebook for the quantum part, and a Python notebook for the classical part.

You can run the tutorials online here:


Alternatively, you can install Jupyter and Q# on your machine, as described [here](https://docs.microsoft.com/quantum/install-guide#develop-with-jupyter-notebooks), and run the tutorial locally by navigating to this folder and starting the notebook from the command line using the following command:

    jupyter notebook MultiQubitGates.ipynb