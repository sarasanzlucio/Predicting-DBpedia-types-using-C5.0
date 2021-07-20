# prepare_funs.R
The purpose of this document is only clarify develop details.

## prepare_properties 
### Description:
Transform properties dataset into a matrix, where resources found as objects are rows and properties found are columns. Each cell counts how many triples are same for each resource and column
### Function variables:
* file_properties_In 
* file_object_propertiesMatrix_Out 
* domain_resourcesURI 
### Input expected:
* properties dataset
### Output expected:
* object properties matrix

## prepare_app2and3
### Description:
Add types to object properties matrix ready for use in approaches 2 and 3.
### Function variables:
* file_object_propertiesMatrix_In
* file_instance_types_In
* file_learningSet_Out
* path_levels
* domain_resourcesURI
### Input expected:
* object properties matrix
### Output expected: 
* learning dataset for approaches 2 and 3

## prepare_app1
### Description:
Add types to object properties matrix ready for use in approach 1
### function variables:
* file_object_propertiesMatrix_In
* file_instance_types_In
* file_learningSet_Out
* path_levels
* domain_resourcesURI
### Input expected:
* object properties matrix
### Output expected:
* learning dataset for approach 1

