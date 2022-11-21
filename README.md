# Framework for implementing, sizing and testing fixed point algorithms

## Introduction
The contents of this folder provide a framework for working with fixed point algorithms.
The code exploits MATLAB's fixed point utilities to speed up the design and validation process.


## API description (`gen_mex` and `testbench`)
#### Organization
This framework provides an application programming interface (API) composed of 2 functions:
`gen_mex` and `testbench`. Both functions are inside the *api* folder. Inside *api* is
the *dependencies* folder, which contains the files on which `gen_mex`and `testbench` depend.

#### The `gen_mex` function
`gen_mex` generates mex instrumented code from a MATLAB function that employs fixed point
data types. The term "Instrumented" refers to the fact that the generated mex function is
able to store information about its internal variable when it is run inside a testbench.

#### The `testbench` function
The testbench function is used to run tests on a MATLAB function that implements an algorithm.
`testbench` allows to run the algorithm under test on either simulated data or measured data.
 

## Description of the contents of the *dependencies* folder 
#### The *common* folder
This folder mainly contains functions that are shared among the other MATLAB files in the framework.

#### The *data* folder
This folder contains files in which measured data is stored. Measured data can be used by the testbench.

#### The *settings* folder
This folder contains .json files that are used to store settings used by the testbench and the 
`gen_mex` function to generate inputs for the algorithm. It is important that these settings are
shared between `gen_mex` and `testbench` because `buildInstrumentedMex` uses examples
to infer the size and data type of the input arguments of the functions it converts.
The *settings* folder should contain two .json files:
- joint_settings.json this file contains settings for a joint algorithm. The expression "joint
  algorithm" is used here to indicate an algorithm that accepts a single input data matrix X, which
  can contain a linear and a nonlinear part. A joint algorithm does not need to know how the matrix
  is organized (i.e. which part is the linear one and which part is the nonlinear one).
- split_settings.json: this file contains settings for a spli algorithm. The expression "split
  algorithm" is used here to indicate an algorithm that needs 2 separate input data matrices X1 and X2,
  X1 being the linear part and X2 being the nonlinear part of the overall input matrix.