# Framework for implementing, sizing and testing fixed point algorithms


## Introduction
The contents of this folder provide a framework for working with fixed point algorithms.
The code exploits MATLAB's fixed point utilities to speed up the design and validation process.
If you want to use this API, you should note that its testing functionalities are still limited.
For the moment, the API is able to test algorithms on the following models:
- simulated linear model: the input sequence is white gaussian noise
- simulated nonlinear model: the input sequence is white gaussian noise and a polynomial instantaneous
  model is used
- linear model from measured data: uses data loaded from file
- linear model from measured data: uses data loaded from file and a volterra noncausal model is used

## Usage
#### Setup
To use this framework clone this repository, implement your algorithms as MATLAB functions and write a
testbench script and an acceleration script (if have fixed point code that you need to accelerate).
Both scripts should contain the line   
   
`addpath('savepath/cal_framework/api')`   
   
where `savepath` represents the path at which you have saved this repository. The testbench script
should define variables with the settings and a handle that points to the algorithm under test and
call the `testbench` function. The acceleration script should define a handle the points to the
algorithm to be accelerated and call the `gen_mex` function. Both `testbench` and `gen_mex` are
described in greater detail in the sections that follow. You can store your algorithms and your
testbench/acceleration scripts wherever you like, just make sure that the call to `addpath` inside the scripts makes your local copy of this repository visible.   
   
The algorithms to test should be MATLAB functions with the following requisites:
- The function can accept 2 or 3 input arguments. In the first case, it accepts
  a matrix X1 as its first argument and a column vector y as its second argument.
  X1 should has size *sequ_len x filt_len*, where sequ_len is the length of the
  input sequence for calibration and *filt_len* is the length of the linear filter.
  y should be of size *sequ_len x 1*. A function that only accepts two arguments
  will be automatically interpreted by the testbench as an algorithm that solves
  **linear** regression problems. In the second case, the function accepts X1,
  X2 and y as arguments. The sizes of X1 and X2 are, respectively, *sequ_len x lin_len*
  and *sequ_len x nonlin_len*, where *lin_len* is the length of the linear part of
  the filter and *nonlin_len* is the length of the nonlinear part. y has size *sequ_len x 1*
  like in the previous case. In both cases y is the target sequence, while X1 and X2
  are the design matrices which are built from the input sequence x. A function that
  accepts three input arguments will automatically intepreted by the testbench as
  an algorithm that solves **nonlinear** regression problems.
- The function should return a column vector ys that represents the estimated
  sequence (of size *sequ_len x 1*).

#### Settings files
Settings regarding data (e.g. filter length, sequence length, etc.) should be stored in a dedicated
folder whose path must be passed as an argument to `gen_mex` and `testbench`. This folder should
contain a .json file called `settings.json`. The file contains two fields:
- *lin_settings*: settings for linear regression algorithms.
- *nonlin_settings*: settings for nonlinear regression algorithms.
Both fields should contain subfields that specify information needed to generate the model's design
matrices and, when needed, the data.


## API description (`gen_mex` and `testbench`)
#### Organization
This framework provides an application programming interface (API) composed of 2 functions:
`gen_mex` and `testbench`. Both functions are inside the *api* folder. Inside *api* is
the *dependencies* folder, which contains the files on which `gen_mex` and `testbench` depend.

#### The `gen_mex` function
`gen_mex` generates mex instrumented code from a MATLAB function that employs fixed point
data types. The term "instrumented" refers to the fact that the generated mex function is
able to store information about its internal variable when it is run inside a testbench.

#### The `testbench` function
The testbench function is used to run tests on a MATLAB function that implements an algorithm.
`testbench` allows to run the algorithm under test on either simulated data or measured data.


## Description of the contents of the *dependencies* folder 
#### The *common* folder
This folder mainly contains functions that are shared among the other MATLAB files in the framework.

#### The *data* folder
This folder contains files in which measured data is stored. Measured data is used by the testbench.

#### The *test* folder
The *test* folder contains the dependencies for the `testbench` function