#include<Rcpp.h>

using namespace Rcpp;

// [[Rcpp::export]]
List fwt1step(NumericVector s, NumericVector h, NumericVector g) {
	
	int mask = length(s);
	int N = mask / 2;
	int M = length(h);

	NumericVector sout(N);
	NumericVector dout(N);
	
	int index = 0;
	for (k = 0; k < N; k++) {
		sout[k] = 0;
		dout[k] = 0;
		for (int n = 0; n < M - 1; n++) {
			index = (n + 2 * k) % mask;
			sout[k] += h[n] * s[index];
			dout[k] += g[n] * s[index];
		}
	}

	out = List();
	out["sout"] = sout;
	out["dout"] = dout;

	return out;
}
