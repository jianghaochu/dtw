#include <limits>
#include <Rcpp.h>
#include <cstdlib>

using namespace Rcpp;

// [[Rcpp::export]]
List dpcore_window(NumericMatrix M, NumericMatrix C, Nullable<NumericVector> ws = R_NilValue) // <<< --- Modified
{
    int i, j, ncosts, cols, rows;
	double* costs;
	int* steps;

	/* setup costs */
	int ii, crows;
	crows = C.nrow();
	ncosts = crows;
	costs = (double *)malloc(ncosts*sizeof(double));
	steps = (int *)malloc(ncosts*2*sizeof(int));
	for (ii = 0; ii < ncosts; ++ii) {
		steps[2*ii] = (int)(C(ii, 0));
		steps[2*ii+1] = (int)(C(ii, 1));
		costs[ii] = C(ii, 2);
	}

	cols = M.ncol();
	rows = M.nrow();
    
    NumericVector tmp;
    int wss;
	if (ws.isNotNull()) {
        tmp = (NumericVector)ws;
		wss = (int)tmp(0);
	} else {
        wss = std::max(cols, rows) + 1;
    }

	/* do dp */
	NumericMatrix pD(rows, cols), pP(rows, cols);
	double d1, d2;
	int k;
	double v = M(0, 0);
	double tb = 0;	/* value to use for 0, 0 */

	/*Modified*/
	int i_start = 0;
	int i_end = rows;

	for (j = 0; j < cols; ++j) {
		
		/*Modified*/
		if (ws.isNotNull()) {
			i_start = std::max(0, j-wss);
			i_end = std::min(rows, j+wss+1);
		}

		/*Modified*/
	    for (i = i_start; i < i_end; ++i) { // <<< --- Modified
			d1 = M(i, j);
			for (k = 0; k < ncosts; ++k) {
				if (i >= steps[2*k] && j >= steps[2*k+1] && std::abs((i-steps[2*k]) - (j-steps[2*k+1])) <= wss) {
					d2 = costs[k]*d1 + pD((i-steps[2*k]), (j-steps[2*k+1]));
					if (d2 < v) {
						v = d2;
						tb = k+1;
					}
				}
			}

			pD(i, j) = v;
			pP(i, j) = (double)tb;
			v = std::numeric_limits<double>::max();
	    }


	}

	free((void *)costs);
	free((void *)steps);

	List ret;
	ret["D"] = pD;
	ret["phi"] = pP;
	return ret;
}