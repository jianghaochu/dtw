### shapeDTW and WDTW

Both shapeDTW and weighted DTW focus on the local data patterns. They do not consider the temporal weight decay.

__WDTW__ penalizes the points according to the phase difference between a test point and a reference point to prevent minimum distance distortion by outliers. The key idea is that if the phase difference is low, smaller weight is imposed because neighboring points are important, otherwise larger wright is imposed:
$$d_w(a_i, b_j) = ||w_{|i-j|} (a_i - b_j)||_p$$


### Why not Synthetic Control

+ Think of simple synthetic control
  
  $$
  y_t^T=\beta_0+\beta_1y_t^{C_1}+\cdots+\beta_ny_t^{C_n}
  $$
  
  + Treatment is a linear combination of controls
  
  + Treatment and controls are from the same time phase
  
  + There is no compression and extension between treatment and control data points across time 
