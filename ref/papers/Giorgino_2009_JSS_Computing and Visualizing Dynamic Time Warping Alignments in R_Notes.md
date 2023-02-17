## Computing and Visualizing Dynamic Time Warping Alignments in R: The dtw Package

### 2. Definition of the algorithm

+ two time series
  
  + $X=(x_1,\dots,x_N)$ indexed by $i$
  
  + $Y=(y_1,\dots,y_M)$ indexed by $j$

+ Distance: $d(i,j)=f(x_i,y_j)\ge 0$ 
  
  + $f$ is a non-negative, local dissimilarity function
  
  + While the most common choice is to assume the Euclidean distance, different definitions (e.g., those provided by the proxy package, Meyer and Buchta 2009)
    
    > YH: Euclidean distance can be replaced

+ Wraping curve $\phi(k)$, $k=1,\dots,T$
  
  + $\phi(k)=\left(\phi_x(k),\phi_y(k)\right)$ 
    
    + $\phi_x(k)\in\{1,\dots,N\}$ and $\phi_y(k)\in\{1,\dots,M\}$ remap the time indices of $X$ and $Y$
  
  + Given $\phi$, we compute the average accumulated distortion between $X$ and $Y$
    
    $$
    d_\phi(X,Y)=\sum_{k=1}^T \frac{d\left(\phi_x(k),\phi_y(k)\right)m_\phi(k)}{M_\phi}
    $$
    
    + $m_\phi(k)$ is a per-step weighting coefficient 
      
      > YH: Our contribution is to find a reasonable weighting function, that $m(k)$ changes by $k$, the time index.
    
    + $M_\phi$ is the corresponding normalization constant, which ensures that the accumulated distortions are comparable along different paths.
  
  + Monotonicity
    
    + $\phi_x(k+1)\ge\phi_x(k)$
    
    + $\phi_y(k+1)\ge\phi_y(k)$

+ Goal: Find the optimal alignment $\phi$ such that
  
  $$
  D(X,Y)=\min_\phi d_\phi(X,Y)
  $$

+ Outputs
  
  + The value of $D(X,Y)$, the minimum global dissimilarity or DTW distance
    
    + This distance has a straightforward application in hierarchical clustering and classification (e.g., k-NN classifiers)
  
  + The shape of the wraping curve $\phi$
    
    + $\phi$ provides information about the pairwise correspondences of time points, allowing us to inspect post-hoc aligned signals or measure time distortions

### 3. Computing alignments

#### Default

+ Global alignment: Head to head and tail to tail
  
  $$
  \phi_x(1) = \phi_y(1) = 1;\\
\phi_x(T) = N;\space\phi_y(T) = M
  $$

+ Symmetric local continuity
  
  $$
  \left|\phi_x(k+1)-\phi_x(k)\right|\le 1, \\ 
  \left|\phi_y(k+1)-\phi_y(k)\right|\le 1
  $$
  
  > Given the returns of $\phi(k)$ are integers, the symmetric local continuity says at any time $k$, the next following data point can either be assigned to the same remapped index, $\phi(k)$ or the following index, $\phi(k)+1$. 
  > 
  > Given monotonicity and the definition of function returns, we can rewrite
  > 
  > $$
  > \phi_x(k+1)-\phi_x(k)\in \{0, 1\}, \\
\phi_y(k+1)-\phi_y(k)\in \{0, 1\}
  > $$
