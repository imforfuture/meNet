// Generated by using Rcpp::compileAttributes() -> do not edit by hand
// Generator token: 10BE3573-1514-4C36-9D1C-5A225CD40393

#include <RcppArmadillo.h>
#include <Rcpp.h>

using namespace Rcpp;

// rcpparma_hello_world
arma::mat rcpparma_hello_world();
RcppExport SEXP _meNet_rcpparma_hello_world() {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    rcpp_result_gen = Rcpp::wrap(rcpparma_hello_world());
    return rcpp_result_gen;
END_RCPP
}
// rcpparma_outerproduct
arma::mat rcpparma_outerproduct(const arma::colvec& x);
RcppExport SEXP _meNet_rcpparma_outerproduct(SEXP xSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< const arma::colvec& >::type x(xSEXP);
    rcpp_result_gen = Rcpp::wrap(rcpparma_outerproduct(x));
    return rcpp_result_gen;
END_RCPP
}
// rcpparma_innerproduct
double rcpparma_innerproduct(const arma::colvec& x);
RcppExport SEXP _meNet_rcpparma_innerproduct(SEXP xSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< const arma::colvec& >::type x(xSEXP);
    rcpp_result_gen = Rcpp::wrap(rcpparma_innerproduct(x));
    return rcpp_result_gen;
END_RCPP
}
// rcpparma_bothproducts
Rcpp::List rcpparma_bothproducts(const arma::colvec& x);
RcppExport SEXP _meNet_rcpparma_bothproducts(SEXP xSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< const arma::colvec& >::type x(xSEXP);
    rcpp_result_gen = Rcpp::wrap(rcpparma_bothproducts(x));
    return rcpp_result_gen;
END_RCPP
}
// cor_meanSd
NumericMatrix cor_meanSd(NumericMatrix data, int size, bool replace, int n_repetitions, double zero_precision);
RcppExport SEXP _meNet_cor_meanSd(SEXP dataSEXP, SEXP sizeSEXP, SEXP replaceSEXP, SEXP n_repetitionsSEXP, SEXP zero_precisionSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< NumericMatrix >::type data(dataSEXP);
    Rcpp::traits::input_parameter< int >::type size(sizeSEXP);
    Rcpp::traits::input_parameter< bool >::type replace(replaceSEXP);
    Rcpp::traits::input_parameter< int >::type n_repetitions(n_repetitionsSEXP);
    Rcpp::traits::input_parameter< double >::type zero_precision(zero_precisionSEXP);
    rcpp_result_gen = Rcpp::wrap(cor_meanSd(data, size, replace, n_repetitions, zero_precision));
    return rcpp_result_gen;
END_RCPP
}
// cor_prTest
NumericVector cor_prTest(NumericMatrix data, int n_repetitions, String alternative, double zero_precision);
RcppExport SEXP _meNet_cor_prTest(SEXP dataSEXP, SEXP n_repetitionsSEXP, SEXP alternativeSEXP, SEXP zero_precisionSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< NumericMatrix >::type data(dataSEXP);
    Rcpp::traits::input_parameter< int >::type n_repetitions(n_repetitionsSEXP);
    Rcpp::traits::input_parameter< String >::type alternative(alternativeSEXP);
    Rcpp::traits::input_parameter< double >::type zero_precision(zero_precisionSEXP);
    rcpp_result_gen = Rcpp::wrap(cor_prTest(data, n_repetitions, alternative, zero_precision));
    return rcpp_result_gen;
END_RCPP
}

static const R_CallMethodDef CallEntries[] = {
    {"_meNet_rcpparma_hello_world", (DL_FUNC) &_meNet_rcpparma_hello_world, 0},
    {"_meNet_rcpparma_outerproduct", (DL_FUNC) &_meNet_rcpparma_outerproduct, 1},
    {"_meNet_rcpparma_innerproduct", (DL_FUNC) &_meNet_rcpparma_innerproduct, 1},
    {"_meNet_rcpparma_bothproducts", (DL_FUNC) &_meNet_rcpparma_bothproducts, 1},
    {"_meNet_cor_meanSd", (DL_FUNC) &_meNet_cor_meanSd, 5},
    {"_meNet_cor_prTest", (DL_FUNC) &_meNet_cor_prTest, 4},
    {NULL, NULL, 0}
};

RcppExport void R_init_meNet(DllInfo *dll) {
    R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
    R_useDynamicSymbols(dll, FALSE);
}
