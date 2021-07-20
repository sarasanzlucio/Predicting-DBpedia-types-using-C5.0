#!/usr/bin/env Rscript
#divide_funs.R


divide_oneSplit <- function(file_learningSet_In,
                            file_training_Out,
                            file_validating_Out,
                            path_files_trainValidate_Out,
                            n_cases_validating,
                            test1_10_25,
                            randomSeed,
                            isApproach1,
                            tr_l2, vl_l2, tr_l3, vl_l3, tr_l4, vl_l4, tr_l5, vl_l5, tr_l6, vl_l6, reserved){
  
  test1_10_25 <- as.numeric(test1_10_25)
  
  df_learningSet <- read.csv(file=file_learningSet_In,
                             header=FALSE, sep=",", encoding = "UTF-8", stringsAsFactors = FALSE)
  colnames(df_learningSet) <- df_learningSet[1,]
  df_learningSet <- df_learningSet[-1,]
  if(isApproach1){
    df_learningSet[,c(2:(ncol(df_learningSet)-1))] <- sapply(df_learningSet[,c(2:(ncol(df_learningSet)-1))], as.numeric)
    df_learningSet$auxCountIngoing <- rowSums(df_learningSet[,2:(ncol(df_learningSet)-1)])
  }else{
    df_learningSet[,c(2:(ncol(df_learningSet)-11))] <- sapply(df_learningSet[,c(2:(ncol(df_learningSet)-11))], as.numeric)
    df_learningSet$auxCountIngoing <- rowSums(df_learningSet[,2:(ncol(df_learningSet)-11)])
  }
  
  countingIngoing <- df_learningSet[,c(1,ncol(df_learningSet))]
  colnames(countingIngoing) <- c("s","numberOfIngoing")
  df_learningSet$auxCountIngoing <- NULL
  
  countingIngoing_test <- countingIngoing[countingIngoing$numberOfIngoing>=test1_10_25,]
  
  
  set.seed(as.numeric(randomSeed))
  countingIngoing_testSelection <- countingIngoing_test[sample(x = nrow(countingIngoing_test), size = n_cases_validating, replace = FALSE),]
  
  df_validating <- df_learningSet[df_learningSet$s %in% countingIngoing_testSelection$s,]
  df_training <- df_learningSet[!(df_learningSet$s %in% df_validating$s),]
  
  write.csv(df_training, file = paste(path_files_trainValidate_Out,file_training_Out,sep=""), fileEncoding = "UTF-8", row.names=FALSE)
  write.csv(df_validating, file = paste(path_files_trainValidate_Out,file_validating_Out,sep=""), fileEncoding = "UTF-8", row.names=FALSE)
  getting_types_tottl(file_dataSet_In = paste(path_files_trainValidate_Out,file_validating_Out,sep=""),
                      file_Out = paste(path_files_trainValidate_Out,reserved,sep=""),
                      isApproach1 = isApproach1)
  
  if(!isApproach1){
    divide_knownResources_Ln(file_dataSet_In = paste(path_files_trainValidate_Out,file_training_Out,sep=""),
                             f_l2 = paste(path_files_trainValidate_Out,tr_l2,sep=""),
                             f_l3 = paste(path_files_trainValidate_Out,tr_l3,sep=""),
                             f_l4 = paste(path_files_trainValidate_Out,tr_l4,sep=""),
                             f_l5 = paste(path_files_trainValidate_Out,tr_l5,sep=""),
                             f_l6 = paste(path_files_trainValidate_Out,tr_l6sep=""))
    divide_knownResources_Ln(file_dataSet_In = paste(path_files_trainValidate_Out,file_validating_Out,sep=""),
                             f_l2 = paste(path_files_trainValidate_Out,vl_l2,sep=""),
                             f_l3 = paste(path_files_trainValidate_Out,vl_l3,sep=""),
                             f_l4 = paste(path_files_trainValidate_Out,vl_l4,sep=""),
                             f_l5 = paste(path_files_trainValidate_Out,vl_l5,sep=""),
                             f_l6 = paste(path_files_trainValidate_Out,vl_l6,sep=""))
  }
  
  rm(list=ls())
  gc(verbose = TRUE)
  
  return(0)
}


divide_nSplit <- function(file_learningSet_In,
                          path_splits_Out,
                          file_training_Out,
                          file_validating_Out,
                          nSplits,
                          randomSeed,
                          isApproach1,
                          tr_l2, vl_l2, tr_l3, vl_l3, tr_l4, vl_l4, tr_l5, vl_l5, tr_l6, vl_l6, reserved){
  
  df_learningSet <- read.csv(file=file_learningSet_In,
                             header=FALSE, sep=",", encoding = "UTF-8", stringsAsFactors = FALSE)
  colnames(df_learningSet) <- df_learningSet[1,]
  df_learningSet <- df_learningSet[-1,]
  if(isApproach1){
    df_learningSet[,c(2:(ncol(df_learningSet)))] <- sapply(df_learningSet[,c(2:(ncol(df_learningSet)))], as.numeric)
  }else{
    df_learningSet[,c(2:(ncol(df_learningSet)-11))] <- sapply(df_learningSet[,c(2:(ncol(df_learningSet)-11))], as.numeric)
  }

  nSplits <- as.numeric(nSplits)  
  randomSeed <- as.numeric(randomSeed)

  nrow_fold <- nrow(df_learningSet)/nSplits
  nrow_fold <- round(nrow_fold,digits = 0)
  restante <- df_learningSet
  
  #last operation is slight different
  for(i in 1:(nSplits-1)){
    set.seed(randomSeed)
    fold <- restante[sample(x = nrow(restante), size = nrow_fold, replace = FALSE),]
    dt_training <- df_learningSet[!(df_learningSet$s %in% fold$s),]
    restante <- restante[!(restante$s %in% fold$s),]
    dir.create(paste(path_splits_Out,"fold",i,sep=""))
    write.csv(fold, file = paste(path_splits_Out,"fold",as.character(i),"/",file_validating_Out,sep=""),
              fileEncoding = "UTF-8", row.names=FALSE)
    divide_knownResources_Ln(file_dataSet_In = paste(path_splits_Out,"fold",i,"/",file_validating_Out,sep=""),
                             f_l2 = paste(path_splits_Out,"fold",i,"/",vl_l2,sep=""),
                             f_l3 = paste(path_splits_Out,"fold",i,"/",vl_l3,sep=""),
                             f_l4 = paste(path_splits_Out,"fold",i,"/",vl_l4,sep=""),
                             f_l5 = paste(path_splits_Out,"fold",i,"/",vl_l5,sep=""),
                             f_l6 = paste(path_splits_Out,"fold",i,"/",vl_l6,sep=""))
    getting_types_tottl(file_dataSet_In = paste(path_splits_Out,"fold",i,"/",file_validating_Out,sep=""),
                        file_Out = paste(path_splits_Out,"fold",i,"/",reserved,sep=""),
                        isApproach1 = isApproach1)
    write.csv(dt_training, file = paste(path_splits_Out,"fold",i,"/",file_training_Out,sep=""),
              fileEncoding = "UTF-8", row.names=FALSE)
    divide_knownResources_Ln(file_dataSet_In = paste(path_splits_Out,"fold",i,"/",file_training_Out,sep=""),
                             f_l2 = paste(path_splits_Out,"fold",i,"/",tr_l2,sep=""),
                             f_l3 = paste(path_splits_Out,"fold",i,"/",tr_l3,sep=""),
                             f_l4 = paste(path_splits_Out,"fold",i,"/",tr_l4,sep=""),
                             f_l5 = paste(path_splits_Out,"fold",i,"/",tr_l5,sep=""),
                             f_l6 = paste(path_splits_Out,"fold",i,"/",tr_l6,sep=""))
  }
  #last split
  fold <- restante
  dir.create(paste(path_splits_Out,"fold",nSplits,sep=""))
  write.csv(fold, file = paste(path_splits_Out,"fold",nSplits,"/",file_validating_Out,sep=""),
            fileEncoding = "UTF-8", row.names=FALSE)
  divide_knownResources_Ln(file_dataSet_In = paste(path_splits_Out,"fold",nSplits,"/",file_validating_Out,sep=""),
                           f_l2 = paste(path_splits_Out,"fold",nSplits,"/",vl_l2,sep=""),
                           f_l3 = paste(path_splits_Out,"fold",nSplits,"/",vl_l3,sep=""),
                           f_l4 = paste(path_splits_Out,"fold",nSplits,"/",vl_l4,sep=""),
                           f_l5 = paste(path_splits_Out,"fold",nSplits,"/",vl_l5,sep=""),
                           f_l6 = paste(path_splits_Out,"fold",nSplits,"/",vl_l6,sep=""))
  getting_types_tottl(file_dataSet_In = paste(path_splits_Out,"fold",nSplits,"/",file_validating_Out,sep=""),
                      file_Out = paste(path_splits_Out,"fold",nSplits,"/",reserved,sep=""),
                      isApproach1 = isApproach1)
  dt_training <- df_learningSet[!(df_learningSet$s %in% fold$s),]
  write.csv(dt_training, file = paste(path_splits_Out,"fold",nSplits,"/",file_training_Out,sep=""),
            fileEncoding = "UTF-8", row.names=FALSE)
  divide_knownResources_Ln(file_dataSet_In = paste(path_splits_Out,"fold",nSplits,"/",file_training_Out,sep=""),
                           f_l2 = paste(path_splits_Out,"fold",nSplits,"/",tr_l2,sep=""),
                           f_l3 = paste(path_splits_Out,"fold",nSplits,"/",tr_l3,sep=""),
                           f_l4 = paste(path_splits_Out,"fold",nSplits,"/",tr_l4,sep=""),
                           f_l5 = paste(path_splits_Out,"fold",nSplits,"/",tr_l5,sep=""),
                           f_l6 = paste(path_splits_Out,"fold",nSplits,"/",tr_l6,sep=""))
  
  rm(list=ls())
  gc(verbose = TRUE)
  
  return(0)
}



divide_knownResources_Ln <- function(file_dataSet_In,
                                     f_l2, f_l3, f_l4, f_l5, f_l6){#this time, without file extension
  
  df_dataSet <- read.csv(file=file_dataSet_In,
                             header=FALSE, sep=",", encoding = "UTF-8", stringsAsFactors = FALSE)
  colnames(df_dataSet) <- df_dataSet[1,]
  df_dataSet <- df_dataSet[-1,]
  df_dataSet[,c(2:(ncol(df_dataSet)-11))] <- sapply(df_dataSet[,c(2:(ncol(df_dataSet)-11))], as.numeric)
  
  dt <- df_dataSet
  training_test_sinDesc_N2 <- dt[dt$Class2_Bin != 'desconocido',]
  training_test_sinDesc_N3 <- dt[dt$Class3_Bin != 'desconocido',]
  training_test_sinDesc_N4 <- dt[dt$Class4_Bin != 'desconocido',]
  training_test_sinDesc_N5 <- dt[dt$Class5_Bin != 'desconocido',]
  training_test_sinDesc_N6 <- dt[dt$Class6_Bin != 'desconocido',]
  write.csv(training_test_sinDesc_N2, file = f_l2, fileEncoding = "UTF-8", row.names=FALSE)
  write.csv(training_test_sinDesc_N3, file = f_l3, fileEncoding = "UTF-8", row.names=FALSE)
  write.csv(training_test_sinDesc_N4, file = f_l4, fileEncoding = "UTF-8", row.names=FALSE)
  write.csv(training_test_sinDesc_N5, file = f_l5, fileEncoding = "UTF-8", row.names=FALSE)
  write.csv(training_test_sinDesc_N6, file = f_l6, fileEncoding = "UTF-8", row.names=FALSE)
  
  return(0)
}

getting_types_tottl <- function(file_dataSet_In,
                                file_Out,
                                isApproach1){
  
  df_dataSet <- read.csv(file=file_dataSet_In,
                         header=FALSE, sep=",", encoding = "UTF-8", stringsAsFactors = FALSE)
  colnames(df_dataSet) <- df_dataSet[1,]
  df_dataSet <- df_dataSet[-1,]
  if(isApproach1){
    df_dataSet[,c(2:(ncol(df_dataSet)-1))] <- sapply(df_dataSet[,c(2:(ncol(df_dataSet)-1))], as.numeric)
    test <- df_dataSet
    salida_test_n1 <- test[,c(1,ncol(test))]#getting class column
    salida_test <- salida_test_n1 
  }else{
    df_dataSet[,c(2:(ncol(df_dataSet)-11))] <- sapply(df_dataSet[,c(2:(ncol(df_dataSet)-11))], as.numeric)  
    test <- df_dataSet
    salida_test_n1 <- test[,c(1,ncol(test)-10)]#getting class_L1 column
    
    colnames(salida_test_n1) <- c("s","o")
    salida_test_n2 <- test[test$Class2_Bin!="desconocido",c(1,ncol(test)-9)]
    colnames(salida_test_n2) <- c("s","o")
    salida_test_n3 <- test[test$Class3_Bin!="desconocido",c(1,ncol(test)-7)]
    colnames(salida_test_n3) <- c("s","o")
    salida_test_n4 <- test[test$Class4_Bin!="desconocido",c(1,ncol(test)-5)]
    colnames(salida_test_n4) <- c("s","o")
    salida_test_n5 <- test[test$Class5_Bin!="desconocido",c(1,ncol(test)-3)]
    colnames(salida_test_n5) <- c("s","o")
    
    salida_test <- rbind(salida_test_n1,
                         salida_test_n2,
                         salida_test_n3,
                         salida_test_n4,
                         salida_test_n5)
  }
  salida_test$p <- "<http://www.w3.org/1999/02/22-rdf-syntax-ns#type>"
  salida_test[,c(1,2,3)] <- salida_test[,c(1,3,2)]
  colnames(salida_test) <- c("s","p","o")
  salida_test$punto <- "."
  write.table(salida_test, file = file_Out,
              fileEncoding = "UTF-8", row.names=FALSE,col.names = FALSE, quote = FALSE, sep=" ")
  
  rm(list=ls())
  gc(verbose = TRUE)
  
  return(0)
}



