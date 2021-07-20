#!/usr/bin/env Rscript
#module_preparating.R


#revisar referencias a la hora de cargar el código y utilizar getwd()
source(paste(getwd(),"/preparating/divide/divide_funs.R",sep=""))
source(paste(getwd(),"/preparating/prepare/prepare_funs.R",sep=""))
source(paste(getwd(),"/monitoring/monitor_funs.R",sep=""))

preprocessing <- function(file_mapping_based_properties_In,
                          file_instance_types_In,
                          domain_resources,
                          path_levels,
                          isCrossValidation,
                          isApproach1,
                          path_splits_Out,
                          path_files_trainValidate_Out,
                          file_training_Out,
                          file_validating_Out,
                          randomSeed,
                          nSplits,
                          n_cases_validating,
                          test1_10_25,
                          tr_l2, vl_l2, tr_l3, vl_l3, tr_l4, vl_l4, tr_l5, vl_l5, tr_l6, vl_l6,
                          reserved){
  print("starting preparating module")
  
  file_object_propertiesMatrix_Intermediate <- paste(path_files_trainValidate_Out,"objects_properties_Matrix.csv",sep="")
  file_learningSet_Intermediate <- paste(path_files_trainValidate_Out,"learningSet.csv",sep="")
  # path_splits_Intermediate <-paste(getwd(),"/intermediateData/crossValidation/",sep="")
  
  get_memoryStats(currentPid = Sys.getpid(), currentFunctionPoint = "prepare_properties",isAfter = FALSE)
  if(!file.exists(file_object_propertiesMatrix_Intermediate)){
    prepare_properties(file_properties_In = file_mapping_based_properties_In,
                       file_object_propertiesMatrix_Out = file_object_propertiesMatrix_Intermediate,
                       domain_resourcesURI = domain_resources)
  }else{
    print("found objects_properties_Matrix.csv, skipping prepare_properties function")
  }

  
  get_memoryStats(currentPid = Sys.getpid(), currentFunctionPoint = "prepare_properties", isAfter = TRUE)
  gc()
  get_memoryStats(currentPid = Sys.getpid(), currentFunctionPoint = "prepare_types_approaches",isAfter = FALSE)
  
  
  # a ser posible, unir en una sola función, añadir parámetro isApproach1
  
  if(!file.exists(file_learningSet_Intermediate)){
    if(isApproach1){
      prepare_app1(file_object_propertiesMatrix_In = file_object_propertiesMatrix_Intermediate,
                   file_instance_types_In = file_instance_types_In,
                   file_learningSet_Out = file_learningSet_Intermediate,
                   path_levels = path_levels,
                   domain_resourcesURI = domain_resources)
    }else{
      prepare_app2and3(file_object_propertiesMatrix_In = file_object_propertiesMatrix_Intermediate,
                       file_instance_types_In = file_instance_types_In,
                       file_learningSet_Out = file_learningSet_Intermediate,
                       path_levels = path_levels,
                       domain_resourcesURI = domain_resources)
    }
  }else{
    print("found learningSet.csv, skipping prepare types approaches functions")
  }

  
  get_memoryStats(currentPid = Sys.getpid(), currentFunctionPoint = "prepare_types_approaches",isAfter = TRUE)
  
  gc()
  
  get_memoryStats(currentPid = Sys.getpid(), currentFunctionPoint = "training/validating divisions",isAfter = FALSE)
  
  if(isCrossValidation){
    divide_nSplit(file_learningSet_In = file_learningSet_Intermediate,
                  path_splits_Out = path_splits_Out,
                  file_training_Out = file_training_Out,
                  file_validating_Out = file_validating_Out,
                  nSplits = nSplits,
                  randomSeed = randomSeed,
                  isApproach1 = isApproach1,
                  tr_l2 = tr_l2,
                  vl_l2 = vl_l2,
                  tr_l3 = tr_l3,
                  vl_l3 = vl_l3,
                  tr_l4 = tr_l4,
                  vl_l4 = vl_l4,
                  tr_l5 = tr_l5,
                  vl_l5 = vl_l5,
                  tr_l6 = tr_l6,
                  vl_l6 = vl_l6,
                  reserved = reserved)
  }else{
    divide_oneSplit(file_learningSet_In = file_learningSet_Intermediate,
                    file_training_Out = file_training_Out,
                    file_validating_Out = file_validating_Out,
                    path_files_trainValidate_Out = path_files_trainValidate_Out,
                    n_cases_validating = n_cases_validating,
                    test1_10_25 = test1_10_25,
                    randomSeed = randomSeed,
                    isApproach1 = isApproach1,
                    tr_l2 = tr_l2,
                    vl_l2 = vl_l2,
                    tr_l3 = tr_l3,
                    vl_l3 = vl_l3,
                    tr_l4 = tr_l4,
                    vl_l4 = vl_l4,
                    tr_l5 = tr_l5,
                    vl_l5 = vl_l5,
                    tr_l6 = tr_l6,
                    vl_l6 = vl_l6,
                    reserved = reserved)
  }

  get_memoryStats(currentPid = Sys.getpid(), currentFunctionPoint = "training/validating divisions",isAfter = TRUE)
  gc()
  print("ending preparating module")
}



