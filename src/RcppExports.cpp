// Generated by using Rcpp::compileAttributes() -> do not edit by hand
// Generator token: 10BE3573-1514-4C36-9D1C-5A225CD40393

#include <Rcpp.h>

using namespace Rcpp;

// readNMDxmlCpp
Rcpp::List readNMDxmlCpp(Rcpp::CharacterVector inputFile, Rcpp::CharacterVector root, Rcpp::List treeStruct, Rcpp::List tableHeaders, Rcpp::NumericVector prefixLens, Rcpp::NumericVector levelDims);
RcppExport SEXP _RNMDAPI_readNMDxmlCpp(SEXP inputFileSEXP, SEXP rootSEXP, SEXP treeStructSEXP, SEXP tableHeadersSEXP, SEXP prefixLensSEXP, SEXP levelDimsSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< Rcpp::CharacterVector >::type inputFile(inputFileSEXP);
    Rcpp::traits::input_parameter< Rcpp::CharacterVector >::type root(rootSEXP);
    Rcpp::traits::input_parameter< Rcpp::List >::type treeStruct(treeStructSEXP);
    Rcpp::traits::input_parameter< Rcpp::List >::type tableHeaders(tableHeadersSEXP);
    Rcpp::traits::input_parameter< Rcpp::NumericVector >::type prefixLens(prefixLensSEXP);
    Rcpp::traits::input_parameter< Rcpp::NumericVector >::type levelDims(levelDimsSEXP);
    rcpp_result_gen = Rcpp::wrap(readNMDxmlCpp(inputFile, root, treeStruct, tableHeaders, prefixLens, levelDims));
    return rcpp_result_gen;
END_RCPP
}

static const R_CallMethodDef CallEntries[] = {
    {"_RNMDAPI_readNMDxmlCpp", (DL_FUNC) &_RNMDAPI_readNMDxmlCpp, 6},
    {NULL, NULL, 0}
};

RcppExport void R_init_RNMDAPI(DllInfo *dll) {
    R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
    R_useDynamicSymbols(dll, FALSE);
}
