# Other functions and interesting process

This folder have related useful code.


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
