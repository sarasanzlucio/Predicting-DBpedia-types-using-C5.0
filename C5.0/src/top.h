#ifndef _TOP_H_
#define _TOP_H_

static void c50(char **namesv, char **datav, char **costv, int *subset,
                int *rules, int *utility, int *trials, int *winnow,
                double *sample, int *seed, int *noGlobalPruning, double *CF,
                int *minCases, int *fuzzyThreshold, int *earlyStopping,
                char **treev, char **rulesv, char **outputv);
                
static void predictions(char **casev, char **namesv, char **treev,
                        char **rulesv, char **costv,
                        int *predv, /* XXX predictions are character */
                        double *confidencev, int *trials, char **outputv);
                        
 


#endif