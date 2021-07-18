#include <R.h>
#include <R_ext/Rdynload.h>
#include <R_ext/Print.h>
#include <Rinternals.h>
#include <Rdefines.h>
#include "redefine.h"
#include "rsample.h"
#include "rulebasedmodels.h"
#include "strbuf.h"
#include <stdio.h>
#include <stdlib.h>

extern void c50main();
extern void sample(double *outputv);
extern void FreeCases(void);

/*struct c50_return {
    char * treev;
    char * rulesv;
    char * outputv;
};*/


static char** c50(char *namesv, char *datav, char *costv, int subset,
                int rules, int utility, int trials, int winnow,
                double sample, int seed, int noGlobalPruning, double CF,
                int minCases, int fuzzyThreshold, int earlyStopping);
                
void my_predictions(char *casev, char *namesv, char *treev,
                        char *rulesv, char *costv,
                        int *predv, double *confidencev, int *trials, char *outputv);



SEXP call_C50(SEXP namesString, SEXP data_vec, SEXP datavec_len, SEXP costString, SEXP subset, SEXP rules, SEXP bands, SEXP trials, SEXP winnow, SEXP sample, 
SEXP seed, SEXP noGlobalPruning, SEXP CF, SEXP minCases, SEXP fuzzyThreshold, SEXP earlyStopping){

  char* string;
  char* concat;
  long n = 0;
  long size;
  int i;
  char* eptr;
  
  n = length(data_vec);
  
  char* size_str = malloc((strlen(CHAR(STRING_ELT(datavec_len, 0)))+1)*sizeof(char)); 
  strcpy(size_str, CHAR(STRING_ELT(datavec_len, 0)));
  
  size = strtol(size_str, &eptr, 10);
  
  string = malloc((size+1)*sizeof(char));
  
  strcpy(string, CHAR(STRING_ELT(data_vec, 0)));
  
  
  for (i = 1; i < n; i++) {
    strcat(string, CHAR(STRING_ELT(data_vec, i)));
  }
  
  
  char* namesv = malloc((strlen(CHAR(STRING_ELT(namesString, 0)))+1)*sizeof(char)); 
  strcpy(namesv, CHAR(STRING_ELT(namesString, 0)));
  
  char* costv = malloc((strlen(CHAR(STRING_ELT(costString, 0)))+1)*sizeof(char)); 
  strcpy(costv, CHAR(STRING_ELT(costString, 0)));
  
  char** c50_return = c50(namesv, string, costv, asLogical(subset), asLogical(rules), asInteger(bands), asInteger(trials), asLogical(winnow), asReal(sample), asInteger(seed), asInteger(noGlobalPruning), asReal(CF), asInteger(minCases), asLogical(fuzzyThreshold), asLogical(earlyStopping));
  
  free(string);
  free(namesv);
  free(costv);
  
  
  SEXP out = PROTECT(allocVector(STRSXP, 3));
  

  SET_STRING_ELT(out, 0, mkChar(c50_return[0]));
  
  SET_STRING_ELT(out, 1, mkChar(c50_return[1]));
  
  SET_STRING_ELT(out, 2, mkChar(c50_return[2]));

  UNPROTECT(1);

  return out;
}


SEXP call_predictions(SEXP caseString, SEXP case_len, SEXP names, SEXP tree, SEXP rules, SEXP cost, SEXP pred, SEXP confidence, SEXP trials){

  char* casev;
  char* outputv = "";
  char* eptr;
  
  char* size_str = malloc((strlen(CHAR(STRING_ELT(case_len, 0)))+1)*sizeof(char)); 
  strcpy(size_str, CHAR(STRING_ELT(case_len, 0)));
  
  long size = strtol(size_str, &eptr, 10);
  
  casev = malloc((size+1)*sizeof(char));
  strcpy(casev, CHAR(STRING_ELT(caseString, 0)));
  
  int n = length(caseString);
  
  for (int i = 1; i < n; i++) {
    strcat(casev, CHAR(STRING_ELT(caseString, i)));
  }

  
  char* namesv = malloc((strlen(CHAR(STRING_ELT(names, 0)))+1)*sizeof(char)); 
  strcpy(namesv, CHAR(STRING_ELT(names, 0)));
  
  char* treev = malloc((strlen(CHAR(STRING_ELT(tree, 0)))+1)*sizeof(char)); 
  strcpy(treev, CHAR(STRING_ELT(tree, 0)));
  
  char* rulesv = malloc((strlen(CHAR(STRING_ELT(rules, 0)))+1)*sizeof(char)); 
  strcpy(rulesv, CHAR(STRING_ELT(rules, 0)));
  
  char* costv = malloc((strlen(CHAR(STRING_ELT(cost, 0)))+1)*sizeof(char)); 
  strcpy(costv, CHAR(STRING_ELT(cost, 0)));
  
  int variable;
  int* predv = &variable;
  
  int npred = length(pred);
  predv = malloc((npred+1)*sizeof(int));
  
  for (int i = 0; i < npred; i++) {
    predv[i] = INTEGER(pred)[i];
  }
  
  
  double variable1;
  double* confidencev = &variable1;
  
  int nconf = length(confidence);
  confidencev = malloc((nconf+1)*sizeof(double));
  
  for (int i = 0; i < nconf; i++) {
    confidencev[i] = REAL(confidence)[i];
  }
  
  
  int* trialsv = &variable;
  *trialsv = asInteger(trials);
  
  int val; 

  // Announce ourselves for testing
  // Rprintf("predictions called\n");

  // Initialize the globals
  initglobals();

  // Handles the strbufv data structure
  rbm_removeall();

  // XXX Should this be controlled via an option?
  // Rprintf("Calling setOf\n");
  setOf();


  STRBUF *sb_cases = strbuf_create_full(casev, strlen(casev));
  if (rbm_register(sb_cases, "undefined.cases", 0) < 0) {
    error("undefined.cases already exists");
  }

  STRBUF *sb_names = strbuf_create_full(namesv, strlen(namesv));
  if (rbm_register(sb_names, "undefined.names", 0) < 0) {
    error("undefined.names already exists");
  }

  if (strlen(treev)) {
    STRBUF *sb_treev = strbuf_create_full(treev, strlen(treev));
    
    if (rbm_register(sb_treev, "undefined.tree", 0) < 0) {
      error("undefined.tree already exists");
    }
  } else if (strlen(rulesv)) {
    STRBUF *sb_rulesv = strbuf_create_full(rulesv, strlen(rulesv));
    
    if (rbm_register(sb_rulesv, "undefined.rules", 0) < 0) {
      error("undefined.rules already exists");
    }
    setrules(1);
  } else {
    error("either a tree or rules must be provided");
  }

  // Create a strbuf using *costv and register it as "undefined.costs"
  if (strlen(costv) > 0) {
    // Rprintf("registering cost matrix: %s", *costv);
    STRBUF *sb_costv = strbuf_create_full(costv, strlen(costv));
    // XXX should sb_costv be copied?
    if (rbm_register(sb_costv, "undefined.costs", 0) < 0) {
      error("undefined.cost already exists");
    }
  } else {
    // Rprintf("no cost matrix to register\n");
  }

  
  if ((val = setjmp(rbm_buf)) == 0) {
    // Real work is done here
    rpredictmain(trialsv, predv, confidencev);

    // Rprintf("predict finished\n\n");
  } else {
    // Rprintf("predict code called exit with value %d\n\n", val - JMP_OFFSET);
  }

  // Close file object "Of", and return its contents via argument outputv
  char *outputString = closeOf();
  char *output = R_alloc(strlen(outputString) + 1, 1);
  strcpy(output, outputString);
  //*outputv = output;

  // We reinitialize the globals on exit out of general paranoia
  initglobals();

  
  free(namesv);
  free(treev);
  free(rulesv);
  free(costv);
  
  SEXP predx = PROTECT(allocVector(INTSXP, npred));
  
  for (int i = 0; i < npred; i++) {
    INTEGER(predx)[i] = predv[i];
  }
  
  SEXP confidencex = PROTECT(allocVector(REALSXP, nconf));
  
  for (int i = 0; i < npred; i++) {
    REAL(confidencex)[i] = confidencev[i];
  }
  
  SEXP outputx = PROTECT(allocVector(STRSXP, 1));
  SET_STRING_ELT(outputx, 0, mkChar(output));

  SEXP vector = PROTECT(allocVector(VECSXP, 3));
  SET_VECTOR_ELT(vector, 0, predx);
  SET_VECTOR_ELT(vector, 1, confidencex);
  SET_VECTOR_ELT(vector, 2, outputx);

  UNPROTECT(4);
  
  free(predv);
  free(confidencev);
  
  return vector;
}


static char** c50(char *namesv, char *datav, char *costv, int subset,
                int rules, int utility, int trials, int winnow,
                double sample, int seed, int noGlobalPruning, double CF,
                int minCases, int fuzzyThreshold, int earlyStopping) {
  int val; /* Used by setjmp/longjmp for implementing rbm_exit */
  
  char ** c50_return = malloc(3 * sizeof(char*));


  // Announce ourselves for testing
  // Rprintf("c50 called\n");

  // Initialize the globals to the values that the c50
  // program would have at the start of execution
  initglobals();
  

  // Set globals based on the arguments.  This is analogous
  // to parsing the command line in the c50 program.
  setglobals(subset, rules, utility, trials, winnow, sample, seed,
             noGlobalPruning, CF, minCases, fuzzyThreshold, earlyStopping,
             costv);
             

  // Handles the strbufv data structure
  rbm_removeall();

  // Deallocates memory allocated by NewCase.
  // Not necessary since it's also called at the end of this function,
  // but it doesn't hurt, and I'm feeling paranoid.
  FreeCases();
  

  // XXX Should this be controlled via an option?
  // Rprintf("Calling setOf\n");
  setOf();

  // Create a strbuf using *namesv as the buffer.
  // Note that this is a readonly strbuf since we can't
  // extend *namesv.
  STRBUF *sb_names = strbuf_create_full(namesv, strlen(namesv));
  

  // Register this strbuf using the name "undefined.names"
  if (rbm_register(sb_names, "undefined.names", 0) < 0) {
    error("undefined.names already exists");
  }



  // Create a strbuf using *datav and register it as "undefined.data"
  STRBUF *sb_datav = strbuf_create_full(datav, strlen(datav));
  // XXX why is sb_datav copied? was that part of my debugging?
  // XXX or is this the cause of the leak?
  if (rbm_register(strbuf_copy(sb_datav), "undefined.data", 0) < 0) {
    error("undefined data already exists");
  }
  

  // Create a strbuf using *costv and register it as "undefined.costs"
  if (strlen(costv) > 0) {
    // Rprintf("registering cost matrix: %s", *costv);
    STRBUF *sb_costv = strbuf_create_full(costv, strlen(costv));
    // XXX should sb_costv be copied?
    if (rbm_register(sb_costv, "undefined.costs", 0) < 0) {
      error("undefined.cost already exists");
    }
  } else {
    // Rprintf("no cost matrix to register\n");
  }

  /*
   * We need to initialize rbm_buf before calling any code that
   * might call exit/rbm_exit.
   */
  if ((val = setjmp(rbm_buf)) == 0) {

    // Real work is done here

    c50main();


    if (rules == 0) {
      // Get the contents of the the tree file
      STRBUF *treebuf = rbm_lookup("undefined.tree");
      if (treebuf != NULL) {
        char *treeString = strbuf_getall(treebuf);
        //char *treeObj = R_alloc(strlen(treeString) + 1, 1);
        //strcpy(treeObj, treeString);
        c50_return[0] = R_alloc(strlen(treeString) + 1, 1);
        strcpy(c50_return[0], treeString);
        
        c50_return[1] = "";
        // I think the previous value of *treev will be garbage collected
        //Rprintf("VALOR DE treev \n");
        //Rprintf("%s", c50_return[0]);
        //treev = treeObj;
        
      } else {
        // XXX Should *treev be assigned something in this case?
        // XXX Throw an error?
      }
    } else {
      // Get the contents of the the rules file
      STRBUF *rulesbuf = rbm_lookup("undefined.rules");
      if (rulesbuf != NULL) {
        char *rulesString = strbuf_getall(rulesbuf);
        //char *rulesObj = R_alloc(strlen(rulesString) + 1, 1);
        //strcpy(rulesObj, rulesString);
        c50_return[1] = R_alloc(strlen(rulesString) + 1, 1);
        strcpy(c50_return[1], rulesString);
        
        c50_return[0] = "";
        
        //Rprintf("VALOR DE RULESV \n");
        //Rprintf("%s", c50_return[1]);

        // I think the previous value of *rulesv will be garbage collected
        //*rulesv = rulesObj;
        
      } else {
        // XXX Should *rulesv be assigned something in this case?
        // XXX Throw an error?
      }
    }
  } else {
    Rprintf("c50 code called exit with value %d\n", val - JMP_OFFSET);
  }

  // Close file object "Of", and return its contents via argument outputv
  char *outputString = closeOf();
  //char *output = R_alloc(strlen(outputString) + 1, 1);
  //strcpy(output, outputString);
  c50_return[2] = R_alloc(strlen(outputString) + 1, 1);
  strcpy(c50_return[2], outputString);
  //Rprintf("VALOR DE OUTPUTV \n");
  //Rprintf("%s", c50_return[2]);
  //*outputv = output;

  // Deallocates memory allocated by NewCase
  FreeCases();

  // We reinitialize the globals on exit out of general paranoia
  initglobals();
  
  return c50_return;
  
}

void my_predictions(char *casev, char *namesv, char *treev,
                        char *rulesv, char *costv,
                        int *predv, /* XXX predictions are character */
                        double *confidencev, int *trials, char *outputv) {
  int val; /* Used by setjmp/longjmp for implementing rbm_exit */
  

  // Announce ourselves for testing
   Rprintf("predictions called\n");

  // Initialize the globals
  initglobals();

  // Handles the strbufv data structure
  rbm_removeall();

  // XXX Should this be controlled via an option?
  // Rprintf("Calling setOf\n");
  setOf();


  STRBUF *sb_cases = strbuf_create_full(casev, strlen(casev));
  if (rbm_register(sb_cases, "undefined.cases", 0) < 0) {
    error("undefined.cases already exists");
  }
  
  //free(casev_mio);

  STRBUF *sb_names = strbuf_create_full(namesv, strlen(namesv));
  if (rbm_register(sb_names, "undefined.names", 0) < 0) {
    error("undefined.names already exists");
  }

  if (strlen(treev)) {
    STRBUF *sb_treev = strbuf_create_full(treev, strlen(treev));
    /* XXX should sb_treev be copied? */
    if (rbm_register(sb_treev, "undefined.tree", 0) < 0) {
      error("undefined.tree already exists");
    }
  } else if (strlen(rulesv)) {
    STRBUF *sb_rulesv = strbuf_create_full(rulesv, strlen(rulesv));
    /* XXX should sb_rulesv be copied? */
    if (rbm_register(sb_rulesv, "undefined.rules", 0) < 0) {
      error("undefined.rules already exists");
    }
    setrules(1);
  } else {
    error("either a tree or rules must be provided");
  }

  // Create a strbuf using *costv and register it as "undefined.costs"
  if (strlen(costv) > 0) {
    // Rprintf("registering cost matrix: %s", *costv);
    STRBUF *sb_costv = strbuf_create_full(costv, strlen(costv));
    // XXX should sb_costv be copied?
    if (rbm_register(sb_costv, "undefined.costs", 0) < 0) {
      error("undefined.cost already exists");
    }
  } else {
    // Rprintf("no cost matrix to register\n");
  }

  /*
   * We need to initialize rbm_buf before calling any code that
   * might call exit/rbm_exit.
   */
  if ((val = setjmp(rbm_buf)) == 0) {
    // Real work is done here
    // Rprintf("\n\nCalling rpredictmain\n");
    rpredictmain(trials, predv, confidencev);

    Rprintf("predict finished\n\n");
  } else {
    // Rprintf("predict code called exit with value %d\n\n", val - JMP_OFFSET);
  }

  // Close file object "Of", and return its contents via argument outputv
  char *outputString = closeOf();
  char *output = R_alloc(strlen(outputString) + 1, 1);
  strcpy(output, outputString);
  *outputv = output;

  // We reinitialize the globals on exit out of general paranoia
  initglobals();
  
  FILE *ft = fopen("output_predictions.txt", "w");
  if (ft != NULL){
    fputs(output, ft);
    fclose(ft);
  }
}

// Declare the type of each of the arguments to the c50 function
/*static R_NativePrimitiveArgType c50_t[] = {
    STRSXP,  // namesv
    STRSXP,  // datav
    STRSXP,  // costv
    LGLSXP,  // subset
    LGLSXP,  // rules
    INTSXP,  // utility
    INTSXP,  // trials
    LGLSXP,  // winnow
    REALSXP, // sample
    INTSXP,  // seed
    INTSXP,  // noGlobalPruning
    REALSXP, // CF
    INTSXP,  // minCases
    LGLSXP,  // fuzzyThreshold
    LGLSXP,  // early stopping
    STRSXP,  // treev
    STRSXP,  // rulesv
    STRSXP   // outputv
};

// Declare the type of each of the arguments to the predictions function
static R_NativePrimitiveArgType predictions_t[] = {
    STRSXP,  // casev
    STRSXP,  // namesv
    STRSXP,  // treev
    STRSXP,  // rulesv
    STRSXP,  // costv
    INTSXP,  // predv
    REALSXP, // confidencev
    INTSXP,  // trials
    STRSXP   // outputv
};*/


// Declare the c50 and predictions functions
/*static const R_CMethodDef cEntries[] = {
    {"C50", (DL_FUNC)&c50, 18, c50_t},
    {"predictions", (DL_FUNC)&predictions, 9, predictions_t},
    {NULL, NULL, 0}};

// Initialization function for this shared object
void R_init_C50(DllInfo *dll) {
  // Announce ourselves for testing
  // Rprintf("R_init_C50 called\n");

  // Register the functions "c50" and "predictions"
  R_registerRoutines(dll, cEntries, NULL, NU*/