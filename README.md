# Improvements for type prediction in DBpedia

In this project we provide the code for the solution of the memory limitation of the package [C50](https://github.com/topepo/C5.0) presented in this [issue](https://github.com/topepo/C5.0/issues/15).

This solution is explained in detail in this [stackOverflow post](https://stackoverflow.com/questions/68123447/c5-0-package-error-in-pasteapplyx-1-paste-collapse-collapse-n).

## How to use

In order to use the C5.0 package modified code you will need to clone this repository and include the files ```C5.0.R``` and ```predict.C5.0.R``` in your R code:

```
source(paste(getwd(),"/C5.0/R/C5.0.R",sep=""))
source(paste(getwd(),"/C5.0/R/predict.C5.0.R",sep=""))
```

## How to modify the code

In case you want to modify anything in the C code you will need to create the shared library again (file ```top.so```) by running this command:

```
R CMD SHLIB C5.0/src/top.c C5.0/src/redefine.c C5.0/src/strbuf.c C5.0/src/rulebasedmodels.cC5.0/src/rsample.c C5.0/src/global.c C5.0/src/attwinnow.c C5.0/src/classify.c C5.0/src/confmat.c C5.0/src/construct.c C5.0/src/contin.c C5.0/src/discr.c C5.0/src/formrules.c C5.0/src/formtree.c C5.0/src/getdata.c C5.0/src/getnames.c C5.0/src/hash.c C5.0/src/hooks.cC5.0/src/implicitatt.c C5.0/src/info.c C5.0/src/mcost.c C5.0/src/modelfiles.c C5.0/src/p-thresh.c C5.0/src/prune.c C5.0/src/rc50.c C5.0/src/rules.c C5.0/src/ruletree.c C5.0/src/siftrules.c C5.0/src/sort.c C5.0/src/subset.c C5.0/src/trees.c C5.0/src/update.c C5.0/src/utility.c C5.0/src/xval.c
```

This object is loaded into the R code by using the function ```dyn.load("C5.0/src/top.so")``` in the files ```C5.0.R``` and ```predict.C5.0.R```.




