Table 4.5: Page 211

```R
# type is a numeric argument with a range of integers from 1 to 7
# slope.weighting: string argument a,b,c,d
# smoothed: boolean TRUE or FALSE

plot(rabinerJuangStepPattern(type=1, slope.weighting="a", smoothed=FALSE))
```

Potential change to be made:

If the original norm is $N$, then the new norm will be given by

$$
\sum_{t=1}^Nw_t, \text{ where} \\
~\\
w_t=w_1 \forall t\in\{...\},w_2\forall t\in\{...\}...
$$

### Distance measure

Table 4.4: Page 195
Distortion measure (too difficult and too engineering)

TSdist: Distance Measures for Time Series Data
https://cran.r-project.org/web/packages/TSdist

https://journal.r-project.org/archive/2016/RJ-2016-058/RJ-2016-058.pdf

> A few of these R packages, such as dtw (Giorgino, 2009), pdc (Brandmaier, 2015), proxy (Meyer and Buchta, 2015), longitudinalData (Genolini, 2014) and TSclust (Montero and Vilar, 2014) provide implementations of some time series distance measures. However, many of the most popular distances reviewed by **Esling and Agon (2012)**; **Wang et al. (2012)** and **Bagnall et al. (2016)** are not available in these R packages.

#### Recent development

Moraffah et al._2021_Arxiv_Causal inference for time series analysis Problems, methods and evaluation.pdf

Gupta et al._2022_Arxiv_Similarity Learning based Few Shot Learning for ECG Time Series Classification.pdf

Zhao and Itti_2016_Arxiv_shapeDTW shape Dynamic Time Warping.pdf