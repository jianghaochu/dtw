#include<Rcpp.h>

using namespace Rcpp;

// [[Rcpp::export]]
List fwt1step(NumericVector s, NumericVector h, NumericVector g) {
	
	int mask, N, M;
    mask = s.length();
	N = mask / 2;
	M = h.length();

	NumericVector sout(N);
	NumericVector dout(N);
	
	int index = 0;
	for (int i = 0; i < N; i++) {
		sout(i) = 0;
		dout(i) = 0;
		for (int j = 0; j < M - 1; j++) {
			index = (j + 2 * i) % mask;
			sout(i) += h(j) * s(index);
			dout(i) += g(j) * s(index);
		}
	}

	List out;
	out["sout"] = sout;
	out["dout"] = dout;

	return out;
}
