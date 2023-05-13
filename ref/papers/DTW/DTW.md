### 1. DTW
DTW a method to calculate the optimal matching between two sequences, which is useful in many domains such as speech recognition, data mining, financial markets, etc. It's commonly used in data mining to measure the distance between two time series.

Let's assume we have two sequences like the following:
$$X = x_1, x_2, \dots, x_i, \dots, x_n$$
$$Y = y_1, y_2, \dots, y_i, \dots, y_m$$

The sequences $X$ and $Y$ can be arranged to form an $n\times m$ grid, where each point $(i,j)$ is the alignment between $x_i$ and $y_j$. A warping path $W$ maps the elements of $X$ and $Y$ to minimize the distance between them. The warping path $W$ is a sequence of grid points $(i,j)$. The optimal path to $(i, j)$ can be computed by using recursive formula given by
$$\text{DTW}(X, Y) = \sqrt {\gamma(i, j)}$$
$$\gamma(i, j) = d(x_i, y_j) + \min (\gamma(i-1, j-1), \gamma(i, j-1), \gamma(i-1, j))$$
where $d$ is the Euclidean distance. 

For efficiency purposes, it’s important to limit the number of possible warping paths:
- Boundary Condition: This constraint ensures that the warping path begins with the start points of both signals and terminates with their endpoints.
$$i_1 = 1, i_k = n \text{ and } j_1 = 1, j_k = m$$
- Monotonicity condition: This constraint preserves the time-order of points (not going back in time).
$$i_{t-1} < i_t \text{ and } j_{t-1} < j_t$$
- Continuity (step size) condition: This constraint limits the path transitions to adjacent points in time (not jumping in time).
$$i_t - i_{t-1} \leq 1 \text{ and } j_t - j_{t-1}$$

In addition to the above three constraints, there are other less frequent conditions for an allowable warping path:

- Warping window condition: Allowable points can be restricted to fall within a given warping window of width $\omega$ (a positive integer).
$$i_t - j_t \leq \omega$$
- Slope condition: The warping path can be constrained by restricting the slope, and consequently avoiding extreme movements in one direction.

An acceptable warping path has combinations of chess king moves that are:
- Horizontal moves: $(i,j) \rightarrow (i, j+1)$
- Vertical moves: $(i,j) \rightarrow (i+1, j)$
- Diagonal  moves: $(i,j) \rightarrow (i+1, j+1)$

### 2. WDTW

Both shapeDTW and weighted DTW focus on the local data patterns. They do not consider the temporal weight decay.

__WDTW__ penalizes the points according to the phase difference between a test point and a reference point to prevent minimum distance distortion by outliers. The key idea is that if the phase difference is low, smaller weight is imposed because neighboring points are important, otherwise larger wright is imposed:
$$d_w(a_i, b_j) = ||w_{|i-j|} (a_i - b_j)||_p$$


Jeong et al. 2011. Pattern Recognition. Weighted dynamic time warping for time series classification

Notions

+ Sequences: $A\;(= a_1, a_2, \dots, a_m)$ is a sequence with length $m$ and $B\;(= b_1, b_2, \dots, b_n)$ a sequence with length $n$.

+ $I_p$ Norm: $||\cdot||_p$

+ $m$-by-$n$ Distance Matrix: Distance between $a_i$ and $b_j$

    $$d_w(a_i, b_j) = ||w_{|i-j|} (a_i - b_j)||_p$$

    where $w_{|i-j|}$ is the positive weight between two points. 

    + The weight value will be determined based on the phase difference $|i-j|$. In other words, if the two points are near, smaller weights can be imposed.

+ Weighted DTW

    $${\rm WDTW}_p=\sqrt[p]{\gamma^\ast(i,j)}$$

    where 
    
    $$\gamma^\ast(i,j)=||w_{|i-j|}(a_i-b_j)||_p+\min(\gamma^\ast(i-1,j-1),\gamma^\ast(i-1,j),\gamma^\ast(i,j-1)).$$

+ Modified Logistic Weight Function: Assign weights as a
function of the phase difference between two points systematically
    
    $$w_{(i)}=\frac{w_{\max}}{1+\exp\left[-g\times(i-m_c)\right]}$$
    
    where $i=1,\dots,m$, $m$ is the length of a sequence, $m_c$ is the midpoint, and $w_{\max}$ is the upper bound for the weight parameter.
    
    + For simplicity, let $w_{\max}=1$.
    
    + $g$ is an empirical constant, controlling for the curvature (slope) of the function, reflecting the level of penalization for a larger phase difference.

+ Weighted Derivative DTW
    
    + Because DTW may try to explain variability in the Y-axis by warping the X-axis, this may lead to the unexpected *singularities*, which are alignments between a point of a series with multiple points of the other series, and unintuitive alignments.
    
    + To overcome those weaknesses of DTW, DDTW transforms the original points into the higher level features, which contain the shape information of a sequence. Let $m$ be the length of sequence $A$. The point $a_i$ in $A$ is given by
    
    $$ D_A(d_i^a)=\frac{(a_i-a_{i-1})+(a_{i+1}-a_{i-1})/2}{2}, \: 1 < i < m.$$
    
    + $D_A(d_i^a)$ describes the "slope" of a line passing through $a_i$, where $(a_i - a_{i-1}) + (a_{i+1}-a_{i-1})/2$ probably approximate $(a_{i+1}-a_{i-1})$ and denomiator is $2 = (i+1) - (i-1)$.
    
    + Apply WDTW to the transformed points, $d_i^a$. 




### 3. shapeDTW

- [shapeDTW function](https://github.com/jiapingz/shapeDTW/blob/master/shapeDTW/ElasticMeasure/shapeDTW/shapeDTW.m) with shape descriptors calculated within the function.

    - [``validateHOG1Dparam``](https://github.com/jiapingz/shapeDTW/blob/master/shapeDTW/descriptors/validateHOG1DDSPparam.m): This function validates and returns a set of default parameters for the HOG1D descriptor. It takes no input arguments and  returns a struct containing the following fields:
       - ``cellSize``: a scalar representing the size of the HOG cell.
       - ``overlap``: a scalar representing the amount of overlap between neighboring cells.
       - ``xscale``: a scalar representing the scaling factor for the gradient values.
       - ``nbins``: a scalar representing the number of histogram bins.
       - ``signed``: a logical scalar indicating whether or not to use signed gradient values.
       - ``lbp``: a logical scalar indicating whether or not to use the LBP descriptor.

    - [``validatePAAdescriptorparam``](https://github.com/jiapingz/shapeDTW/blob/master/shapeDTW/descriptors/validatePAAdescriptorparam.m): This function validates and returns a set of default parameters for the PAA descriptor. It takes no input arguments and returns a struct containing the following fields:
       - ``segNum``: a scalar representing the number of segments to divide the time series into.
       - ``priority``: a string indicating the method to prioritize segment selection.

    - [``validateDWTdescriptorparam``](https://github.com/jiapingz/shapeDTW/blob/master/shapeDTW/descriptors/validateDWTdescriptorparam.m): This function validates and returns a set of default parameters for the DWT descriptor. It takes no input arguments and returns a struct containing the following fields:
       - ``numLevels``: a scalar representing the number of decomposition levels to use.
       - ``wavelet``: a string indicating the type of wavelet to use.

    - [``calcDescriptor``](https://github.com/jiapingz/shapeDTW/blob/master/shapeDTW/descriptors/calcDescriptor.m): This function computes the descriptor of a given time series based on the specified method and parameters. The function returns a vector representing the computed descriptor. It takes three input arguments:
       - ``seq``: a vector representing the time series to compute the descriptor for.
       - ``method``: a string indicating the descriptor method to use.
       - ``param``: a struct containing the parameters for the descriptor method. 
       
     - [``samplingSequencesIdx``](https://github.com/jiapingz/shapeDTW/blob/master/shapeDTW/sampling/samplingSequencesIdx.m): This function samples the given time series at specified indices and returns a cell array of the resulting sub-sequences. It takes three input arguments:
         - ``seq``: a vector representing the time series to sample.
         - ``seqlen``: a scalar representing the length of each sub-sequence.
         - ``indices``: a vector representing the indices at which to sample the time series.

     - [``dist2``](https://github.com/jiapingz/shapeDTW/blob/master/shapeDTW/descriptors/shape-context/dist2.m): This function computes the pairwise Euclidean distance between two sets of vectors. The function returns an n-by-m matrix of pairwise distances. It takes two input arguments:
         - ``X``: an n-by-p matrix representing the first set of vectors.
         - ``Y``: an m-by-p matrix representing the second set of vectors.

     - [``hist_cost_2``](https://github.com/jiapingz/shapeDTW/blob/master/shapeDTW/descriptors/shape-context/hist_cost_2.m): This function computes the pairwise chi-square distance between two sets of histograms. The function returns an n-by-m matrix of pairwise distances. It takes two input arguments:
         - ``H1``: an n-by-k matrix representing the first set of histograms.
         - ``H2``: an m-by-k matrix representing the second set of histograms.

     - [``dpfast``](https://github.com/jiapingz/shapeDTW/blob/master/shapeDTW/ElasticMeasure/DanEllis/dpfast.m): This function computes the dynamic time warping (DTW) between two time series using a fast implementation. It takes one input argument:
         - ``distmat``: an n-by-m matrix of pairwise distances between the two time series.
         - ``idxp``: a vector representing the indices of the optimal path in the first time series.
         - ``idxq``: a vector representing the indices of the optimal path in the second time series.
         - ``cD``: a scalar representing the cost of the optimal path.
         - ``pc``: a vector representing the partial
         
- [shapeDTW2 function](https://github.com/jiapingz/shapeDTW/blob/master/shapeDTW/ElasticMeasure/shapeDTW/shapeDTW2.m) with shape descriptors being input parameters.
- [Demo shapeDTW](https://github.com/jiapingz/shapeDTW/blob/master/shapeDTW/demo_shapeDTW.m)


### 4. Why not Synthetic Control

+ Think of simple synthetic control
  
  $$y_t^T=\beta_0+\beta_1y_t^{C_1}+\cdots+\beta_ny_t^{C_n}$$
  
  + Treatment is a linear combination of controls
  
  + Treatment and controls are from the same time phase
  
  + There is no compression and extension between treatment and control data points across time 
