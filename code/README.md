### Q & A - 05/27/2023

+ Name of the new algorithm: Time-dependent Weighted Dynamic Time Warping (TD-WDTW)

+ For self-defined window function, there are no path differences across different DTW algorithms but differences exist across varying window size. Is it what we expected? More details to be discussed.

+ Default window type for dpcore_window is sakoeChibaWindow

+ Require further test on different datasets

+ The distance calculation in ``dist.cpp`` is not aligned with ``dist2.R``

### Update - 05/27/2023

+ Add [``WeightFunc.ipynb``][https://github.com/jianghaochu/dtw/blob/main/code/WeightFunc.ipynb]
+ Add [``WeightFunc.R``][https://github.com/jianghaochu/dtw/blob/main/code/WeightFunc.R]
+ Modified [``dpfast.R``][https://github.com/jianghaochu/dtw/blob/main/code/dpfast.R]
+ Modified [``dist2.R``][https://github.com/jianghaochu/dtw/blob/main/code/dist2.R]
+ Modified [``DataSimulation.ipynb``][https://github.com/jianghaochu/dtw/blob/main/code/DataSimulation.ipynb]
+ Modified [``CalculateDist``][https://github.com/jianghaochu/dtw/blob/main/code/CalculateDist.ipynb]


### Update - 05/28/2023

+ Add [``ValidateUtility.ipynb``][https://github.com/jianghaochu/dtw/blob/main/code/ValidateUtility.ipynb]
+ Add ``demo_shapeDTW.ipynb``
+ Add ``test_shapeDTW.ipynb``
+ Add ``shapeDTW.R``
+ Add ``plotElasticMatching.R``
+ Add ``wpath2mat.R``
+ Add ``demo_shapeDTW.R``
+ Add ``zNormalizeTS.R``
+ Modified ``DTWfast.R``
+ Modified ``samplingSequencesIdx.R``
+ Modified ``descriptorHOG1D.R``
+ Modified ``calcDescriptor.R``
+ Modified ``hist_cost_2.R``
