#include <limits>
#include <Rcpp.h>

using namespace Rcpp;

// [[Rcpp::export]]
List dpcore(NumericMatrix M, NumericMatrix C)
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

	/* do dp */
	NumericMatrix pD(rows, cols), pP(rows, cols);
	double d1, d2;
	int k;
	double v = M(0, 0);
	double tb = 0;	/* value to use for 0, 0 */
	for (j = 0; j < cols; ++j) {
	    for (i = 0; i < rows; ++i) {
			d1 = M(i, j);
			for (k = 0; k < ncosts; ++k) {
				if (i >= steps[2*k] && j >= steps[2*k+1]) {
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
