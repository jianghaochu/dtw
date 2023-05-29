### Q & A - 05/27/2023

+ Name of the new algorithm: Time-dependent Weighted Dynamic Time Warping (TD-WDTW)

+ For self-defined window function, there are no path differences across different DTW algorithms but differences exist across varying window size. Is it what we expected? More details to be discussed.

+ Default window type for dpcore_window is sakoeChibaWindow

+ Require further test on different datasets

+ The distance calculation in ``dist.cpp`` is not aligned with ``dist2.R``

### Update - 05/27/2023

+ Add [``WeightFunc.ipynb``](https://github.com/jianghaochu/dtw/blob/main/code/WeightFunc.ipynb)
+ Add [``WeightFunc.R``](https://github.com/jianghaochu/dtw/blob/main/code/WeightFunc.R)
+ Modified [``dpfast.R``](https://github.com/jianghaochu/dtw/blob/main/code/dpfast.R)
+ Modified [``dist2.R``](https://github.com/jianghaochu/dtw/blob/main/code/dist2.R)
+ Modified [``DataSimulation.ipynb``](https://github.com/jianghaochu/dtw/blob/main/code/DataSimulation.ipynb)
+ Modified [``CalculateDist``](https://github.com/jianghaochu/dtw/blob/main/code/CalculateDist.ipynb)


### Update - 05/28/2023

+ Add [``ValidateUtility.ipynb``](https://github.com/jianghaochu/dtw/blob/main/code/ValidateUtility.ipynb)
+ Add [``demo_shapeDTW.ipynb``](https://github.com/jianghaochu/dtw/blob/main/code/demo_shapeDTW.ipynb)
+ Add [``test_shapeDTW.ipynb``](https://github.com/jianghaochu/dtw/blob/main/code/test_shapeDTW.ipynb)
+ Add [``shapeDTW.R``](https://github.com/jianghaochu/dtw/blob/main/code/shapeDTW_translate/shapeDTW.R)
+ Add [``plotElasticMatching.R``](https://github.com/jianghaochu/dtw/blob/main/code/shapeDTW_translate/plotElasticMatching.R)
+ Add [``wpath2mat.R``](https://github.com/jianghaochu/dtw/blob/main/code/shapeDTW_translate/wpath2mat.R)
+ Add [``demo_shapeDTW.R``](https://github.com/jianghaochu/dtw/blob/main/code/shapeDTW_translate/demo_shapeDTW.R)
+ Add [``zNormalizeTS.R``](https://github.com/jianghaochu/dtw/blob/main/code/shapeDTW_translate/zNormalizeTS.R)
+ Modified [``DTWfast.R``](https://github.com/jianghaochu/dtw/blob/main/code/shapeDTW_translate/DTWfast.R)
+ Modified [``samplingSequencesIdx.R``](https://github.com/jianghaochu/dtw/blob/main/code/shapeDTW_translate/samplingSequencesIdx.R)
+ Modified [``descriptorHOG1D.R``](https://github.com/jianghaochu/dtw/blob/main/code/shapeDTW_translate/descriptorHOG1D.R)
+ Modified [``calcDescriptor.R``](https://github.com/jianghaochu/dtw/blob/main/code/shapeDTW_translate/calcDescriptor.R)
+ Modified [``hist_cost_2.R``](https://github.com/jianghaochu/dtw/blob/main/code/shapeDTW_translate/hist_cost_2.R)
