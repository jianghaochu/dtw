Some thoughts

+ Model $\beta$ in bsts to characterize the resulting pairs from td-dtw
  
  + Current options in BSTS
  
$$
\begin{array}{rl}
\text{static: }&\bold x_t^\text T\beta \\~\\

\text{dynamic: }&\bold x_t^\text T\beta_t =\sum_{j=1}^Jx_{j,t}\beta_{j,t}\\~\\
&\beta_{j, t+1}=\beta_{j,t}+\eta_{\beta,j,t}\text{ where }\eta_{\beta,j,t}\sim\cal N(0,\sigma^2_{\beta_j})
\end{array}
$$
  
  + Feature of resulting pairs from td-dtw
    
    + Similarity penalty increases as time point approaches to the present. In other words, the more recent, the more similar the paired sequences are.
  
  + Thoughts
    
    + static: Add weights as td-dtw to observations from different time periods in BSTS so the estimate of  $\beta$ would be affected more by recent data points rather than equally by all data points across time.
    
    + dynamic: Use a step function; for $t\in [0, t_0-n]$, $\beta_{j,t}$ follows a random walk as is, while for $t\in(t_0-n, t_0]$, $\beta_{j,t}$ is a constant, where $n$ is selected by data and $t_0$ is the last time point in the pre-period. It suggests recent relationship between test and control pairs are stable and provide more information for predicting the counterfactual of the treated. Also, this is in line with the feature of td-dtw pairs, the more recent, the more similar.
    
    + spike-slab-prior? 
      
      According to the paper, it is better to fix the number of control sequences (i.e., $x_t$'s) in BSTS. In our context, if using td-dtw, we can choose the best matches ahead, deciding the number of controls we need before BSTS. Based on my practice experience, the number of controls might not affect the performance very much. As a result, imposing spike-slab-prior for $\beta$ might not be necessary in our context. Instead, it is more important to estimate $\beta$ in a way reflecting the feature of pairs from td-dtw.

+ "The posterior predictive intervals in Figure 5(b) widen more slowly than in the
  illustrative example in Figure 1. This is because the large number of controls avail-
  able in this data set offers a much higher pre-campaign predictive strength than in
  the simulated data in Figure 1."
  
  + Takeaway: Since higher pre-campaign predictive strength can lead to a slowly increase in credible interval in the intervention period, it is important to enhance the pre-campaign predictive strength by providing more relevant $\bold x_t$, which are paired controls from td-dtw.

+ Thought of Parameter Identification
  
  + There are so many latent variables in BSTS. Can all latent parameters be identified? I feel there could exist several sets of latent parameters, achieving the same predictive strength and the fitness level for the data generating process in the pre-period.
  
  + Probably these sets of latent parameters might achieve the same in-sample RMSE but different out-of-sample RMSE? Thus, cross-validation is a must! 


