#!/usr/bin/env Rscript
#justModelC50.R

#Input parameters
# -i --instanceTypes           : .ttl file with types and objects (resources) used as class to train the model.
# -m --mappingbasedProperties  : .ttl file with properties and objects (resources) used as predictors to train the model.
# -o --outputPath              : output which contains outputs as C5.0 models.
# -n --nameModel               : name for identify .RData file with saved models.
# -d --domain                  : indicates if it is English or Spanish. It means, if URIs starts with '<http://dbpedia.org/resource/' or '<http://es.dbpedia.org/resource/'.

library("optparse")
source(paste(getwd(),"/preparating/module_preparating.R",sep=""))
#source(paste(getwd(),"/modeling/module_modeling.R",sep=""))
#source(paste(getwd(),"/monitoring/monitor_funs.R",sep=""))
source(paste(getwd(),"/C5.0/R/C5.0.R",sep=""))
#library(C50)


option_list <- list(
  make_option(c("-i","--instanceTypes", type="character", default = NULL),
              help=".ttl file with types and objects (resources) used as class to train the model..",
              metavar="character"),
  make_option(c("-m","--mappingbasedProperties", type="character", default = NULL),
              help=".ttl file with properties and objects (resources) used as predictors to train the model.",
              metavar="character"),
  make_option(c("-o","--outputPath", type="character", default = NULL),
              help="output which contains outputs as C5.0 models.",
              metavar="character"),
  make_option(c("-n","--nameModel", type="character", default = NULL),
              help="name for identify .RData file with saved models. Extension ('.RData') will be added automatically.",
              metavar="character"),
  make_option(c("-d","--domain", type="character", default = NULL),
              help="indicates if it is English or Spanish. It means, if URIs starts with '<http://dbpedia.org/resource/' or '<http://es.dbpedia.org/resource/'.",
              metavar="character"),
  make_option(c("-v","--versionOntology", type="character", default = NULL),
              help="DBpedia ontology version. <39 | 2014 | 201610>",
              metavar="character")
)

opt_parser <- OptionParser(usage = "Usage: %prog <options>",
                           description = "Description:
                           This software provides a way to train models C5.0 using propeprties as predictors and DBpedia types as classes.
                           ",
                           epilogue = "
                                      Notes:
                           - Each directory used in arguments should end with slash ('/').
                           - All directories are relative, not absolute.
                           - Every path should points to a place into execution folder.",
                           option_list=option_list)

opt <- parse_args(opt_parser)


dominio <- '^<http://dbpedia.org/resource/' #de momento, ingles por defecto
if(opt$domain %in% c("ES")){
  dominio <- '^<http://es.dbpedia.org/resource/'
}else if(opt$domain %in% c("EN")){
  dominio <- '^<http://dbpedia.org/resource/'
} else{
  print("error, mejorar aviso, aunque nunca deberia llegar a este punto")
}

ontologia <- "39"
ontologia_owl <- "dbpedia_3.9.owl"
if(opt$versionOntology %in% c("39")){
  ontologia <- "39"
  ontologia_owl <- "dbpedia_3.9.owl"
}else if(opt$versionOntology %in% c("2014")){
  ontologia <- "2014"
  ontologia_owl <- "dbpedia_2014.owl"
}else if(opt$versionOntology %in% c("201610")){
  ontologia <- "201610"
  ontologia_owl <- "dbpedia_2016-10.owl"
}else{
  print("error, improve this message")
}

print("lugar de destino de la matriz de propiedades: ")
print(paste(getwd(),"/",opt$outputPath,"objects_properties_Matrix.csv",sep=""))

print(opt$outputPath)
if(file.exists(paste(getwd(),"/",opt$outputPath,"objects_properties_Matrix.csv",sep=""))){
  print("Existe properties")
}else{
  print("No existe properties")
}

prepare_properties(file_properties_In = opt$mappingbasedProperties, 
                   file_object_propertiesMatrix_Out = paste(getwd(),"/",opt$outputPath,"objects_properties_Matrix.csv",sep=""),
                   domain_resourcesURI = dominio)


prepare_app2and3(file_object_propertiesMatrix_In = paste(getwd(),"/",opt$outputPath,"objects_properties_Matrix.csv",sep=""),
                 file_instance_types_In = opt$instanceTypes,
                 file_learningSet_Out = paste(getwd(),"/",opt$outputPath,"learningSet.csv",sep=""),
                 path_levels = paste(getwd(),"/levels_ontology/",ontologia,"/",sep=""),
                 domain_resourcesURI = dominio)
system(paste("cp",
             paste(getwd(),"/",opt$outputPath,"learningSet.csv",sep=""),
             paste(getwd(),"/",opt$outputPath,"trainingTest.csv",sep=""),
             sep=" "))


divide_knownResources_Ln(file_dataSet_In = paste(getwd(),"/",opt$outputPath,"trainingTest.csv",sep=""),
                         f_l2 = paste(getwd(),"/",opt$outputPath,"trainingTest_knownResources_L2.csv",sep=""),
                         f_l3 = paste(getwd(),"/",opt$outputPath,"trainingTest_knownResources_L3.csv",sep=""),
                         f_l4 = paste(getwd(),"/",opt$outputPath,"trainingTest_knownResources_L4.csv",sep=""),
                         f_l5 = paste(getwd(),"/",opt$outputPath,"trainingTest_knownResources_L5.csv",sep=""),
                         f_l6 = paste(getwd(),"/",opt$outputPath,"trainingTest_knownResources_L6.csv",sep=""))



df_training <- read.csv(file=paste(getwd(),"/",opt$outputPath,"trainingTest.csv",sep=""), header=FALSE, sep=",", encoding = "UTF-8", stringsAsFactors = FALSE)
                        
                        
colnames(df_training) <- df_training[1,]

df_training <- df_training[-1,]


df_training[,c(2:(ncol(df_training)-11))] <- sapply(df_training[,c(2:(ncol(df_training)-11))], as.numeric)


#paso a factores
df_training[,ncol(df_training)-10] <- as.factor(df_training[,ncol(df_training)-10])
df_training[,ncol(df_training)-9] <- as.factor(df_training[,ncol(df_training)-9])
df_training[,ncol(df_training)-8] <- as.factor(df_training[,ncol(df_training)-8])
df_training[,ncol(df_training)-7] <- as.factor(df_training[,ncol(df_training)-7])
df_training[,ncol(df_training)-6] <- as.factor(df_training[,ncol(df_training)-6])
df_training[,ncol(df_training)-5] <- as.factor(df_training[,ncol(df_training)-5])
df_training[,ncol(df_training)-4] <- as.factor(df_training[,ncol(df_training)-4])
df_training[,ncol(df_training)-3] <- as.factor(df_training[,ncol(df_training)-3])
df_training[,ncol(df_training)-2] <- as.factor(df_training[,ncol(df_training)-2])
df_training[,ncol(df_training)-1] <- as.factor(df_training[,ncol(df_training)-1])
df_training[,ncol(df_training)] <- as.factor(df_training[,ncol(df_training)])



c50_nivel1_v3 <- C5.0( df_training[,c(2:(ncol(df_training)-11))], df_training[,ncol(df_training)-10] )

save(c50_nivel1_v3, file = paste(getwd(),"/",opt$outputPath,"TrainingTest_nivel1",".RData",sep=""))


#get_memoryStats(currentPid = Sys.getpid(), currentFunctionPoint = "app2_C5.0 level 1",isAfter = TRUE)

load(file = paste(getwd(),"/",opt$outputPath,"TrainingTest_nivel1",".RData",sep=""))

#nivel 2
c50_n2_m1 <- C5.0( df_training[,c(2:(ncol(df_training)-11))], df_training[,ncol(df_training)-8] )

save(c50_n2_m1, file = paste(getwd(),"/",opt$outputPath,"trainingTest_knownResources_L2_c50_n2_m1",".RData",sep=""))

#nivel 3
c50_n3_m1 <- C5.0( df_training[,c(2:(ncol(df_training)-11))], df_training[,ncol(df_training)-6] )

save(c50_n3_m1, file = paste(getwd(),"/",opt$outputPath,"trainingTest_knownResources_L3_c50_n3_m1",".RData",sep=""))

#nivel 4
c50_n4_m1 <- C5.0( df_training[,c(2:(ncol(df_training)-11))], df_training[,ncol(df_training)-4] )

save(c50_n4_m1, file = paste(getwd(),"/",opt$outputPath,"trainingTest_knownResources_L4_c50_n4_m1",".RData",sep=""))

#nivel 5
c50_n5_m1 <- C5.0( df_training[,c(2:(ncol(df_training)-11))], df_training[,ncol(df_training)-2] )

save(c50_n5_m1, file = paste(getwd(),"/",opt$outputPath,"trainingTest_knownResources_L5_c50_n5_m1",".RData",sep=""))

gc()
rm(df_training)


df_training_sinDesc_N2 <- read.csv(file=paste(getwd(),"/",opt$outputPath,"trainingTest_knownResources_L2.csv",sep=""),
                                   header=FALSE, sep=",", encoding = "UTF-8", stringsAsFactors = FALSE)
                                                                    
                                   
colnames(df_training_sinDesc_N2) <- df_training_sinDesc_N2[1,]


df_training_sinDesc_N2 <- df_training_sinDesc_N2[-1,]


df_training_sinDesc_N2[,c(2:(ncol(df_training_sinDesc_N2)-11))] <- sapply(df_training_sinDesc_N2[,c(2:(ncol(df_training_sinDesc_N2)-11))], as.numeric)
 

df_training_sinDesc_N2[,ncol(df_training_sinDesc_N2)-10] <- as.factor(df_training_sinDesc_N2[,ncol(df_training_sinDesc_N2)-10])
df_training_sinDesc_N2[,ncol(df_training_sinDesc_N2)-9] <- as.factor(df_training_sinDesc_N2[,ncol(df_training_sinDesc_N2)-9])
df_training_sinDesc_N2[,ncol(df_training_sinDesc_N2)-8] <- as.factor(df_training_sinDesc_N2[,ncol(df_training_sinDesc_N2)-8])
df_training_sinDesc_N2[,ncol(df_training_sinDesc_N2)-7] <- as.factor(df_training_sinDesc_N2[,ncol(df_training_sinDesc_N2)-7])
df_training_sinDesc_N2[,ncol(df_training_sinDesc_N2)-6] <- as.factor(df_training_sinDesc_N2[,ncol(df_training_sinDesc_N2)-6])
df_training_sinDesc_N2[,ncol(df_training_sinDesc_N2)-5] <- as.factor(df_training_sinDesc_N2[,ncol(df_training_sinDesc_N2)-5])
df_training_sinDesc_N2[,ncol(df_training_sinDesc_N2)-4] <- as.factor(df_training_sinDesc_N2[,ncol(df_training_sinDesc_N2)-4])
df_training_sinDesc_N2[,ncol(df_training_sinDesc_N2)-3] <- as.factor(df_training_sinDesc_N2[,ncol(df_training_sinDesc_N2)-3])
df_training_sinDesc_N2[,ncol(df_training_sinDesc_N2)-2] <- as.factor(df_training_sinDesc_N2[,ncol(df_training_sinDesc_N2)-2])
df_training_sinDesc_N2[,ncol(df_training_sinDesc_N2)-1] <- as.factor(df_training_sinDesc_N2[,ncol(df_training_sinDesc_N2)-1])
df_training_sinDesc_N2[,ncol(df_training_sinDesc_N2)] <- as.factor(df_training_sinDesc_N2[,ncol(df_training_sinDesc_N2)]) 



c50_n2_m3 <- C5.0( df_training_sinDesc_N2[,c(2:(ncol(df_training_sinDesc_N2)-11))], df_training_sinDesc_N2[,ncol(df_training_sinDesc_N2)-9] )

save(c50_n2_m3, file = paste(getwd(),"/",opt$outputPath,"trainingTest_knownResources_L2_c50_n2_m3",".RData",sep=""))

#get_memoryStats(currentPid = Sys.getpid(), currentFunctionPoint = "app2_C5.0 level 2",isAfter = TRUE)


gc()
rm(df_training_sinDesc_N2)


df_training_sinDesc_N3 <- read.csv(file=paste(getwd(),"/",opt$outputPath,"trainingTest_knownResources_L3.csv",sep=""),
                                   header=FALSE, sep=",", encoding = "UTF-8", stringsAsFactors = FALSE)
colnames(df_training_sinDesc_N3) <- df_training_sinDesc_N3[1,]
df_training_sinDesc_N3 <- df_training_sinDesc_N3[-1,]
df_training_sinDesc_N3[,c(2:(ncol(df_training_sinDesc_N3)-11))] <- sapply(df_training_sinDesc_N3[,c(2:(ncol(df_training_sinDesc_N3)-11))], as.numeric)


df_training_sinDesc_N3[,ncol(df_training_sinDesc_N3)-10] <- as.factor(df_training_sinDesc_N3[,ncol(df_training_sinDesc_N3)-10])
df_training_sinDesc_N3[,ncol(df_training_sinDesc_N3)-9] <- as.factor(df_training_sinDesc_N3[,ncol(df_training_sinDesc_N3)-9])
df_training_sinDesc_N3[,ncol(df_training_sinDesc_N3)-8] <- as.factor(df_training_sinDesc_N3[,ncol(df_training_sinDesc_N3)-8])
df_training_sinDesc_N3[,ncol(df_training_sinDesc_N3)-7] <- as.factor(df_training_sinDesc_N3[,ncol(df_training_sinDesc_N3)-7])
df_training_sinDesc_N3[,ncol(df_training_sinDesc_N3)-6] <- as.factor(df_training_sinDesc_N3[,ncol(df_training_sinDesc_N3)-6])
df_training_sinDesc_N3[,ncol(df_training_sinDesc_N3)-5] <- as.factor(df_training_sinDesc_N3[,ncol(df_training_sinDesc_N3)-5])
df_training_sinDesc_N3[,ncol(df_training_sinDesc_N3)-4] <- as.factor(df_training_sinDesc_N3[,ncol(df_training_sinDesc_N3)-4])
df_training_sinDesc_N3[,ncol(df_training_sinDesc_N3)-3] <- as.factor(df_training_sinDesc_N3[,ncol(df_training_sinDesc_N3)-3])
df_training_sinDesc_N3[,ncol(df_training_sinDesc_N3)-2] <- as.factor(df_training_sinDesc_N3[,ncol(df_training_sinDesc_N3)-2])
df_training_sinDesc_N3[,ncol(df_training_sinDesc_N3)-1] <- as.factor(df_training_sinDesc_N3[,ncol(df_training_sinDesc_N3)-1])
df_training_sinDesc_N3[,ncol(df_training_sinDesc_N3)] <- as.factor(df_training_sinDesc_N3[,ncol(df_training_sinDesc_N3)])


c50_n3_m3 <- C5.0( df_training_sinDesc_N3[,c(2:(ncol(df_training_sinDesc_N3)-11))], df_training_sinDesc_N3[,ncol(df_training_sinDesc_N3)-7] )

save(c50_n3_m3, file = paste(getwd(),"/",opt$outputPath,"trainingTest_knownResources_L3_c50_n3_m3",".RData",sep=""))

#get_memoryStats(currentPid = Sys.getpid(), currentFunctionPoint = "app2_C5.0 level 3",isAfter = TRUE)


gc()
rm(df_training_sinDesc_N3)



df_training_sinDesc_N4 <- read.csv(file=paste(getwd(),"/",opt$outputPath,"trainingTest_knownResources_L4.csv",sep=""),
                                   header=FALSE, sep=",", encoding = "UTF-8", stringsAsFactors = FALSE)
colnames(df_training_sinDesc_N4) <- df_training_sinDesc_N4[1,]
df_training_sinDesc_N4 <- df_training_sinDesc_N4[-1,]
df_training_sinDesc_N4[,c(2:(ncol(df_training_sinDesc_N4)-11))] <- sapply(df_training_sinDesc_N4[,c(2:(ncol(df_training_sinDesc_N4)-11))], as.numeric)

df_training_sinDesc_N4[,ncol(df_training_sinDesc_N4)-10] <- as.factor(df_training_sinDesc_N4[,ncol(df_training_sinDesc_N4)-10])
df_training_sinDesc_N4[,ncol(df_training_sinDesc_N4)-9] <- as.factor(df_training_sinDesc_N4[,ncol(df_training_sinDesc_N4)-9])
df_training_sinDesc_N4[,ncol(df_training_sinDesc_N4)-8] <- as.factor(df_training_sinDesc_N4[,ncol(df_training_sinDesc_N4)-8])
df_training_sinDesc_N4[,ncol(df_training_sinDesc_N4)-7] <- as.factor(df_training_sinDesc_N4[,ncol(df_training_sinDesc_N4)-7])
df_training_sinDesc_N4[,ncol(df_training_sinDesc_N4)-6] <- as.factor(df_training_sinDesc_N4[,ncol(df_training_sinDesc_N4)-6])
df_training_sinDesc_N4[,ncol(df_training_sinDesc_N4)-5] <- as.factor(df_training_sinDesc_N4[,ncol(df_training_sinDesc_N4)-5])
df_training_sinDesc_N4[,ncol(df_training_sinDesc_N4)-4] <- as.factor(df_training_sinDesc_N4[,ncol(df_training_sinDesc_N4)-4])
df_training_sinDesc_N4[,ncol(df_training_sinDesc_N4)-3] <- as.factor(df_training_sinDesc_N4[,ncol(df_training_sinDesc_N4)-3])
df_training_sinDesc_N4[,ncol(df_training_sinDesc_N4)-2] <- as.factor(df_training_sinDesc_N4[,ncol(df_training_sinDesc_N4)-2])
df_training_sinDesc_N4[,ncol(df_training_sinDesc_N4)-1] <- as.factor(df_training_sinDesc_N4[,ncol(df_training_sinDesc_N4)-1])
df_training_sinDesc_N4[,ncol(df_training_sinDesc_N4)] <- as.factor(df_training_sinDesc_N4[,ncol(df_training_sinDesc_N4)])


c50_n4_m3 <- C5.0( df_training_sinDesc_N4[,c(2:(ncol(df_training_sinDesc_N4)-11))], df_training_sinDesc_N4[,ncol(df_training_sinDesc_N4)-5] )

save(c50_n4_m3, file = paste(getwd(),"/",opt$outputPath,"trainingTest_knownResources_L4_c50_n4_m3",".RData",sep=""))

#get_memoryStats(currentPid = Sys.getpid(), currentFunctionPoint = "app2_C5.0 level 4",isAfter = TRUE)

gc()
rm(df_training_sinDesc_N4)


df_training_sinDesc_N5 <- read.csv(file=paste(getwd(),"/",opt$outputPath,"trainingTest_knownResources_L5.csv",sep=""),
                                   header=FALSE, sep=",", encoding = "UTF-8", stringsAsFactors = FALSE)
colnames(df_training_sinDesc_N5) <- df_training_sinDesc_N5[1,]
df_training_sinDesc_N5 <- df_training_sinDesc_N5[-1,]
df_training_sinDesc_N5[,c(2:(ncol(df_training_sinDesc_N5)-11))] <- sapply(df_training_sinDesc_N5[,c(2:(ncol(df_training_sinDesc_N5)-11))], as.numeric)

df_training_sinDesc_N5[,ncol(df_training_sinDesc_N5)-10] <- as.factor(df_training_sinDesc_N5[,ncol(df_training_sinDesc_N5)-10])
df_training_sinDesc_N5[,ncol(df_training_sinDesc_N5)-9] <- as.factor(df_training_sinDesc_N5[,ncol(df_training_sinDesc_N5)-9])
df_training_sinDesc_N5[,ncol(df_training_sinDesc_N5)-8] <- as.factor(df_training_sinDesc_N5[,ncol(df_training_sinDesc_N5)-8])
df_training_sinDesc_N5[,ncol(df_training_sinDesc_N5)-7] <- as.factor(df_training_sinDesc_N5[,ncol(df_training_sinDesc_N5)-7])
df_training_sinDesc_N5[,ncol(df_training_sinDesc_N5)-6] <- as.factor(df_training_sinDesc_N5[,ncol(df_training_sinDesc_N5)-6])
df_training_sinDesc_N5[,ncol(df_training_sinDesc_N5)-5] <- as.factor(df_training_sinDesc_N5[,ncol(df_training_sinDesc_N5)-5])
df_training_sinDesc_N5[,ncol(df_training_sinDesc_N5)-4] <- as.factor(df_training_sinDesc_N5[,ncol(df_training_sinDesc_N5)-4])
df_training_sinDesc_N5[,ncol(df_training_sinDesc_N5)-3] <- as.factor(df_training_sinDesc_N5[,ncol(df_training_sinDesc_N5)-3])
df_training_sinDesc_N5[,ncol(df_training_sinDesc_N5)-2] <- as.factor(df_training_sinDesc_N5[,ncol(df_training_sinDesc_N5)-2])
df_training_sinDesc_N5[,ncol(df_training_sinDesc_N5)-1] <- as.factor(df_training_sinDesc_N5[,ncol(df_training_sinDesc_N5)-1])
df_training_sinDesc_N5[,ncol(df_training_sinDesc_N5)] <- as.factor(df_training_sinDesc_N5[,ncol(df_training_sinDesc_N5)])


c50_n5_m3 <- C5.0( df_training_sinDesc_N5[,c(2:(ncol(df_training_sinDesc_N5)-11))], df_training_sinDesc_N5[,ncol(df_training_sinDesc_N5)-3] )

save(c50_n5_m3, file = paste(getwd(),"/",opt$outputPath,"trainingTest_knownResources_L5_c50_n5_m3",".RData",sep=""))

#get_memoryStats(currentPid = Sys.getpid(), currentFunctionPoint = "app2_C5.0 level 5",isAfter = TRUE)

gc()
rm(df_training_sinDesc_N5)


lista_modelos <- list(c50_nivel1_v3,c50_n2_m1,c50_n2_m3,c50_n3_m1,c50_n3_m3,c50_n4_m1,c50_n4_m3,c50_n5_m1,c50_n5_m3)
save(lista_modelos, file = paste(getwd(),"/",opt$outputPath,opt$nameModel,".RData",sep=""))





