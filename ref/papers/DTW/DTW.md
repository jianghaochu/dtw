### shapeDTW and WDTW

Both shape- and weighted DTW focus on the local data patterns. They do not consider the temporal weight decay.

### Why not Synthetic Control

+ Think of simple synthetic control
  
  $$
  y_t^T=\beta_0+\beta_1y_t^{C_1}+\cdots+\beta_ny_t^{C_n}
  $$
  
  + Treatment is a linear combination of controls
  
  + Treatment and controls are from the same time phase
  
  + There is no compression and extension between treatment and control data points across time 
