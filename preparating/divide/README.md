# divide_funs.R
The purpose of this document is only clarify develop details.

## divide_oneSplit 
### Description:
Divide input dataset into training dataset and validating dataset. Validation cases are chosen randomly, but can be also conditioned to have a minimum number of ingoing properties per case.
### Function variables:
* file_learningSet_In
* file_training_Out
* file_validating_Out
* path_files_trainValidate_Out
* n_cases_validating
* test1_10_25
* randomSeed
* isApproach1
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
### Input expected:
* learning dataset
### Output expected:
* training main dataset
* validating main dataset
* training and validating datasets, restricted to known types per level (only if !isApproach1). For instance, 'vl_l5' will be the reference to validating cases where only appear with types belonging to ontology level 5
* validating dataset file in ttl format, to calculate metrics in evaluation module

## divide_nSplit
### Description:
Divide input dataset in N folds to do a cross-validation process on modeling module. Validation cases are chosen randomly and each validation dataset size is input's size / N.
### Function variables:
* file_learningSet_In
* path_splits_Out
* file_training_Out
* file_validating_Out
* nSplits
* randomSeed
* isApproach1
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
### Input expected:
* learning dataset
## Output expected:
* N folds
* N training main dataset, one in each fold
* N validating main dataset, one in each fold
* N validating dataset file in ttl format, one in each fold. Similar to divide_oneSplit function

## divide_knownResources_Ln
### Description:
Auxiliary function. It helps to obtain datasets where only appear cases for a specific ontology level.
### Function variables:
* file_dataSet_In
* f_l2
* f_l3
* f_l4
* f_l5
* f_l6
### Input expected:
* dataset prepared for approaches 2 or 3 (approach 1 does not need do divisions per ontology level)
### Output expected:	
* 5 datasets, each one conditioned to known types belonging to each ontology level.

## getting_types_tottl
### Description:
Auxiliary function. It helps to obtain a file.ttl with types from a dataset with preparation process format. Its goal is help later in evaluation module.
### Function variables:
* file_dataSet_In
* file_Out
* isApproach1
### Input expected:
* dataset prepared for any approach (1, 2 or 3)
### Output expected
* type dataset with ttl extension


