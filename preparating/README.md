# Module 1: Preparing

This first module uses the properties dataset (mapping_based_properties) and types dataset (instance_types) in order to prepare the information to be used in the next stage (mdoelling).

It is composed by two phases: prepare and divide. First is generates a matrix with ingoing properties and resources. Then the related types are added. Second phase divides data to obtain train and test datasets.

Validation options available are train/validate split or cross validation.

First option, split, allows to choose the number of cases for the validation set and the minimum ingoing degree condition. That is, how many properties a resource should have to be selected.

Second option allows, cross validation, allows to divide the main dataset in N folds, so N times the approach selected will be executed.

To see full description and options, go to main README and help section.

## preprocessing
### Description:
This function transforms input properties and types files. The goal is that intermediate data generated here can be used by Machine Learning algorithms at the next module for modeling.

### Function variables:
* file_mapping_based_properties_In
* file_instance_types_In
* domain_resources
* path_levels
* isCrossValidation
* isApproach1
* path_splits_Out
* path_files_trainValidate_Out
* file_training_Out
* file_validating_Out
* randomSeed
* nSplits
* n_cases_validating
* test1_10_25
* tr_l2
* vl_l2
* tr_l3
* vl_l3
* tr_l4
* vl_l4
* tr_l5
* vl_l5
* tr_l6
* vl_l6
* reserved
### Input:
* Properties file in turtle format. Commonly mapping_based_properties or mapping_based_objects in DBpedia
* Types file in turtle format. Commonly instance_types in DBpedia
## Output:
* Object propeties matrix in csv format
* Learning dataset in csv format
* Training and validating datasets in csv format. Depending on type of validation (simple or cross-validation) different number of files would be generated.


