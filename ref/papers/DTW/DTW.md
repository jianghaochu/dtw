### 1. DTW
DTW a method to calculate the optimal matching between two sequences, which is useful in many domains such as speech recognition, data mining, financial markets, etc. It's commonly used in data mining to measure the distance between two time series.

Let's assume we have two sequences like the following:
$$X = x_1, x_2, \dots, x_i, \dots, x_n$$
$$Y = y_1, y_2, \dots, y_i, \dots, y_m$$

The sequences $X$ and $Y$ can be arranged to form an $n\times m$ grid, where each point $(i,j)$ is the alignment between $x_i$ and $y_j$. A warping path $W$ maps the elements of $X$ and $Y$ to minimize the distance between them. The warping path $W$ is a sequence of grid points $(i,j)$. The optimal path to $(i_k, j_k)$ can be computed by using recursive formula given by
$$D_{\min}(i_k, j_k) = d(i_k, j_k\mid i_{k-1}, j_{k-1}) + \min D_{\min}(i_{k-1}, j_{k-1})$$
where $d$ is the Euclidean distance. The overall path cost is $D = \sum_k d(i_k, j_k)$.

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

### 2. shapeDTW and WDTW

Both shapeDTW and weighted DTW focus on the local data patterns. They do not consider the temporal weight decay.

__WDTW__ penalizes the points according to the phase difference between a test point and a reference point to prevent minimum distance distortion by outliers. The key idea is that if the phase difference is low, smaller weight is imposed because neighboring points are important, otherwise larger wright is imposed:
$$d_w(a_i, b_j) = ||w_{|i-j|} (a_i - b_j)||_p$$

__[shapeDTW](https://github.com/jiapingz/shapeDTW/tree/master/shapeDTW)__: useful MATLAB code, which can be converted to R/Python code in ChatGPT.
- [shapeDTW function](https://github.com/jiapingz/shapeDTW/blob/master/shapeDTW/ElasticMeasure/shapeDTW/shapeDTW.m) with shape descriptors calculated within the function.
- [shapeDTW2 function] (https://github.com/jiapingz/shapeDTW/blob/master/shapeDTW/ElasticMeasure/shapeDTW/shapeDTW2.m) with shape descriptors being input parameters.
- [Demo shapeDTW](https://github.com/jiapingz/shapeDTW/blob/master/shapeDTW/demo_shapeDTW.m)
- [samplingSequencesIdx](https://github.com/jiapingz/shapeDTW/blob/master/shapeDTW/sampling/samplingSequencesIdx.m) used in shapeDTW
- [calcDescriptor](https://github.com/jiapingz/shapeDTW/blob/master/shapeDTW/sampling/samplingSequencesIdx.m) used in shapeDTW
- [dpfast](https://github.com/jiapingz/shapeDTW/blob/master/shapeDTW/ElasticMeasure/DanEllis/dpfast.m) used in shapeDTW
- 
### 3. Why not Synthetic Control

+ Think of simple synthetic control
  
  $$y_t^T=\beta_0+\beta_1y_t^{C_1}+\cdots+\beta_ny_t^{C_n}$$
  
  + Treatment is a linear combination of controls
  
  + Treatment and controls are from the same time phase
  
  + There is no compression and extension between treatment and control data points across time 
