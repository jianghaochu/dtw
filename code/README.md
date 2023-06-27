## Causal Procedure
1. tune hyperparameters
   + $g$ in both relative and absolute weight functions
   + num_query: number of control seq's in causal prediction
2. how to leverage recent trend in $X_t$ when predicting $y_t$ in bsts
   (guess: td_shapedtw might outperform other algorithms when we use data at a low (e.g., zipcode) granularity.)

## Plan
- [ ] Complete prediction exercise (BSTS: Housing Market; ML: Stock Market) 
to verify TD-ShapeDTW results

- [ ] Complete R Package

- [ ] Complete two posts for BSTS and ML, respectively

## To-do List
- [X] Understanding of HOG1

- [ ] Comparison table presenting different descriptors

- [ ] Comparison table presenting different distance metrics (e.g., Euclidean, Chi-square)

- [ ] Do we need to follow some coding style rules (As opening scripts, 
I see a lot of squiggly underlines--coding suggestions--in VS Code)

## Q & A - 05/27/2023

- [X] Name of the new algorithm: Time-dependent Weighted Dynamic Time Warping (TD-WDTW)

- [ ] For self-defined window function, there are no path differences across different DTW algorithms but differences exist across varying window size. Is it what we expected? More details to be discussed.

- [ ] Require further test on different datasets

- [X] The distance calculation in ``dist.cpp`` is not aligned with ``dist2.R``

## Interesting Facts
- Default window type for dpcore_window is sakoeChibaWindow

## Update - 05/27/2023

+ Added [``WeightFunc.ipynb``](https://github.com/jianghaochu/dtw/blob/main/code/WeightFunc.ipynb)
+ Added [``WeightFunc.R``](https://github.com/jianghaochu/dtw/blob/main/code/WeightFunc.R)
+ Modified [``dpfast.R``](https://github.com/jianghaochu/dtw/blob/main/code/dpfast.R)
+ Modified [``dist2.R``](https://github.com/jianghaochu/dtw/blob/main/code/dist2.R)
+ Modified [``DataSimulation.ipynb``](https://github.com/jianghaochu/dtw/blob/main/code/DataSimulation.ipynb)
+ Modified [``CalculateDist``](https://github.com/jianghaochu/dtw/blob/main/code/CalculateDist.ipynb)


## Update - 05/28/2023

+ Added [``ValidateUtility.ipynb``](https://github.com/jianghaochu/dtw/blob/main/code/ValidateUtility.ipynb)
+ Added [``demo_shapeDTW.ipynb``](https://github.com/jianghaochu/dtw/blob/main/code/demo_shapeDTW.ipynb)
+ Added [``test_shapeDTW.ipynb``](https://github.com/jianghaochu/dtw/blob/main/code/test_shapeDTW.ipynb)
+ Added [``shapeDTW.R``](https://github.com/jianghaochu/dtw/blob/main/code/shapeDTW_translate/shapeDTW.R)
+ Added [``plotElasticMatching.R``](https://github.com/jianghaochu/dtw/blob/main/code/shapeDTW_translate/plotElasticMatching.R)
+ Added [``wpath2mat.R``](https://github.com/jianghaochu/dtw/blob/main/code/shapeDTW_translate/wpath2mat.R)
+ Added [``demo_shapeDTW.R``](https://github.com/jianghaochu/dtw/blob/main/code/shapeDTW_translate/demo_shapeDTW.R)
+ Added [``zNormalizeTS.R``](https://github.com/jianghaochu/dtw/blob/main/code/shapeDTW_translate/zNormalizeTS.R)
+ Modified [``DTWfast.R``](https://github.com/jianghaochu/dtw/blob/main/code/shapeDTW_translate/DTWfast.R)
+ Modified [``samplingSequencesIdx.R``](https://github.com/jianghaochu/dtw/blob/main/code/shapeDTW_translate/samplingSequencesIdx.R)
+ Modified [``descriptorHOG1D.R``](https://github.com/jianghaochu/dtw/blob/main/code/shapeDTW_translate/descriptorHOG1D.R)
+ Modified [``calcDescriptor.R``](https://github.com/jianghaochu/dtw/blob/main/code/shapeDTW_translate/calcDescriptor.R)
+ Modified [``hist_cost_2.R``](https://github.com/jianghaochu/dtw/blob/main/code/shapeDTW_translate/hist_cost_2.R)

## Update - 05/29/2023
+ Modified [``demo_shapeDTW.ipynb``](https://github.com/jianghaochu/dtw/blob/main/code/demo_shapeDTW.ipynb)
+ Modified [``test_shapeDTW.ipynb``](https://github.com/jianghaochu/dtw/blob/main/code/test_shapeDTW.ipynb)
+ Modified [``DataSimulation.ipynb``](https://github.com/jianghaochu/dtw/blob/main/code/DataSimulation.ipynb)
+ Modified [``shapeDTW.R``](https://github.com/jianghaochu/dtw/blob/main/code/shapeDTW_translate/shapeDTW.R)
+ Modified [``demo_shapeDTW.R``](https://github.com/jianghaochu/dtw/blob/main/code/shapeDTW_translate/demo_shapeDTW.R)
+ Modified [``PAA.R``](https://github.com/jianghaochu/dtw/blob/main/code/shapeDTW_translate/PAA.R)
+ Modified [``validatePAAparam.R``](https://github.com/jianghaochu/dtw/blob/main/code/shapeDTW_translate/validatePAAparam.R)
+ Modified [``validatePAAdescriptorparam.R``](https://github.com/jianghaochu/dtw/blob/main/code/shapeDTW_translate/validatePAAdescriptorparam.R)
