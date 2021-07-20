# Other functions and interesting process

This folder have related useful code.

# main_diff_datos.R

```
./utils/main_diff_datos.R --help
Usage: ./utils/main_diff_datos.R -l <first dataset path> -r <second dataset path> -o <output path>
Description:
                           This program calculates overlapping between two RDF datasets in turtle (.ttl). Only simple triples (<s> <p> <o> .) are allowed. See 2.1 section at https://www.w3.org/TR/turtle/
                           3 datasets are generated corresponding to 3 actions: 1) Inner join. 2) Left exclude join. 3) Right exclude join.
                           Standard output also returns a summary about results with next structure:
                            - conjunto: name's comparison done. It is composed by each input file name.
                            - nrow_left: amount of rows (triples) at firt dataset.
                            - nrow_right: amount of rows (triples) at second dataset.
                            - ratioInnerJoin_left: percentage of triples from first dataset which remain after inner join operation.
                            - ratioInnerJoin_right: percentage of triples from second dataset which remain after inner join operation.
                            - innerJoin: amount of rows (triples) found after inner join operation. It means that these triples only can be found in both input datasets.
                            - left_exclude_right: amount of rows (triples) found after left exclude operation. It means that these triples only can be found in first dataset.
                            - right_exclude_left: amount of rows (triples) found after right exclude operation. It means that these triples only can be found in second dataset.

Options:
        -l CHARACTER, --datasetLeft=CHARACTER
                path to first dataset. Datasets are called 'left' and 'right' to reference join actions

        -r CHARACTER, --datasetRight=CHARACTER
                path to second dataset.

        -o CHARACTER, --pathOut=CHARACTER
                path to output files. Directory should exist previously.

        -h, --help
                Show this help message and exit

Examples:
                           ./main_diff_datos.R -l myDatasets/dummyTypes1.ttl -r myDatasets/myOtherDummyTypes2.ttl -o myTests/lookingForDifferences/dummyTypes/

```

The purpose of next section is only clarify develop details.

## getDiff_dt 
### Dependencies
* [sqldf R library]( https://cran.r-project.org/web/packages/sqldf/sqldf.pdf )
### Description:
Calculates overlaping between two files in RDF turtle format (ttl). Use --help option two see details about main workflow which calls this function.
### Function variables:
* pathLeft
* pathRight
* pathOutput
### Input expected:
* First (Left) dataset to be compared
* Second (Right) dataset to be compared
### Output expected:
* Inner join dataset. Triples that are found in both datasets.
* Left excluding join dataset. Triples that are only found in first dataset.
* Right excluding join dataset. Triples that are only found in second dataset.
### Return value:
* Data frame with summary about data with next structure:
    * conjunto
	* nrow_left
	* nrow_right
	* ratioInnerJoin_left
	* ratioInnerJoin_right
	* nrow_innerJoin
	* nrow_left_exclude_right
	* nrow_right_exclude_left



# justModelC50.R
This main reuse functions from main workflow in order to fit a C5.0 model, without validation phase. The goal of this is get a final model ready to deployment. The functions used are in preparating/prepare/prepare_funs.R and preparating/prepare/divide_funs.R, which includes funcions prepare_properties, prepare_app2and3 and divide_knownResources_Ln. It also reuse code from funcion app2_C50, in modeling/approach2/approach2_multileve.R, but without validation operations.
```
./utils/justModelC50.R --help
Usage: ./utils/justModelC50.R <options>
Description:
                           This software provides a way to train models C5.0 using propeprties as predictors and DBpedia types as classes.


Options:
        -i CHARACTER, --instanceTypes=CHARACTER
                .ttl file with types and objects (resources) used as class to train the model..

        -m CHARACTER, --mappingbasedProperties=CHARACTER
                .ttl file with properties and objects (resources) used as predictors to train the model.

        -o CHARACTER, --outputPath=CHARACTER
                output which contains outputs as C5.0 models.

        -n CHARACTER, --nameModel=CHARACTER
                name for identify .RData file with saved models. Extension ('.RData') will be added automatically.

        -d CHARACTER, --domain=CHARACTER
                indicates if it is English or Spanish. It means, if URIs starts with '<http://dbpedia.org/resource/' or '<http://es.dbpedia.org/resource/'.

        -v CHARACTER, --versionOntology=CHARACTER
                DBpedia ontology version. <39 | 2014 | 201610>

        -h, --help
                Show this help message and exit


                                      Notes:
                           - Each directory used in arguments should end with slash ('/').
                           - All directories are relative, not absolute.
                           - Every path should points to a place into execution folder.

```

# predictC50.R
This main reuse functions from main workflow in order to make predictions from a fitted C5.0 model using a RDF file (in ttl format) with resources and properties. The goal of this is exploting fitted C5.0 models on several datasets without training phase. There are one function reused, prepare_properties from preparating/prepare/prepare_funs.R, because it is needed to pass data to the model. It also reuse code from funcion app2_C50, in modeling/approach2/approach2_multileve.R, but as difference from justModelC50.R, this time is focused on prediction operations.
```
./utils/predictC50.R --help
Usage: ./utils/predictC50.R <options>
Description:
                           This software provides a way to predict new types using trained models with C5.0 algorithm and a properties.ttl formtat as predictors.


Options:
        -i CHARACTER, --inputData=CHARACTER
                .ttl file with properties and objects that will be predicted.

        -m CHARACTER, --modelPath=CHARACTER
                .RData which contains C5.0 model

        -o CHARACTER, --outputData=CHARACTER
                path to indicate where predictions should be saved.

        -n CHARACTER, --nameFiles=CHARACTER
                name for identify output files. There will be two files, a csv file with all possible predictions (with binary decisions) and a ttl selecting types from csv file with positive binary decisions. Extensions ('.csv' and '.ttl') will be added automatically, so do not include that in -n option

        -d CHARACTER, --domain=CHARACTER
                indicates if it is English or Spanish. It means, if URIs starts with '<http://dbpedia.org/resource/' or '<http://es.dbpedia.org/resource/'.

        -h, --help
                Show this help message and exit


                                      Notes:
                           - Each directory used in arguments should end with slash ('/').
                           - All directories are relative, not absolute.
                           - Every path should points to a place into execution folder.

```
