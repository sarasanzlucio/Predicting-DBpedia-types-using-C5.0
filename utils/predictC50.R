#!/usr/bin/env Rscript
#predictC50.R

#Input parameters
# -i --inputData  : .ttl file with properties and objects that will be predicted.
# -m --modelPath  : .RData which contains C5.0 models.
# -o --outputData : path to indicate where predictions should be saved.
# -d --domain     : indicates if it is English or Spanish. It means, if URIs starts with '<http://dbpedia.org/resource/' or '<http://es.dbpedia.org/resource/'.

library("optparse")
source(paste(getwd(),"/preparating/module_preparating.R",sep=""))
#source(paste(getwd(),"/modeling/module_modeling.R",sep=""))
source(paste(getwd(),"/C5.0/R/predict.C5.0.R",sep=""))
#library(C50)


option_list <- list(
  make_option(c("-i","--inputData", type="character", default = NULL),
              help=".ttl file with properties and objects that will be predicted.",
              metavar="character"),
  make_option(c("-m","--modelPath", type="character", default = NULL),
              help=".RData which contains C5.0 model",
              metavar="character"),
  make_option(c("-o","--outputData", type="character", default = NULL),
              help="path to indicate where predictions should be saved.",
              metavar="character"),
  make_option(c("-n","--nameFiles", type="character", default = NULL),
              help="name for identify output files. There will be two files, a csv file with all possible predictions (with binary decisions) and a ttl selecting types from csv file with positive binary decisions. Extensions ('.csv' and '.ttl') will be added automatically, so do not include that in -n option",
              metavar="character"),
  make_option(c("-d","--domain", type="character", default = NULL),
              help="indicates if it is English or Spanish. It means, if URIs starts with '<http://dbpedia.org/resource/' or '<http://es.dbpedia.org/resource/'.",
              metavar="character")
)

opt_parser <- OptionParser(usage = "Usage: %prog <options>",
                           description = "Description:
                           This software provides a way to predict new types using trained models with C5.0 algorithm and a properties.ttl formtat as predictors.
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


prepare_properties(file_properties_In = opt$inputData, 
                   file_object_propertiesMatrix_Out = paste(opt$outputData,"objects_properties_Matrix.csv",sep=''),
                   domain_resourcesURI = dominio)


df_data <- read.csv(file=paste(opt$outputData,"objects_properties_Matrix.csv",sep=''),
                        header=FALSE, sep=",", encoding = "UTF-8", stringsAsFactors = FALSE)
colnames(df_data) <- df_data[1,]
df_data <- df_data[-1,]

gc()


# modelWrapper <- load(file = opt$modelPath)
load(file = opt$modelPath)

c50_nivel1_v3 <- lista_modelos[1]
c50_nivel1_v3 <- c50_nivel1_v3[[1]]

c50_n2_m1 <- lista_modelos[2]
c50_n2_m1 <- c50_n2_m1[[1]]
c50_n2_m3 <- lista_modelos[3]
c50_n2_m3 <- c50_n2_m3[[1]]

c50_n3_m1 <- lista_modelos[4]
c50_n3_m1 <- c50_n3_m1[[1]]
c50_n3_m3 <- lista_modelos[5]
c50_n3_m3 <- c50_n3_m3[[1]]

c50_n4_m1 <- lista_modelos[6]
c50_n4_m1 <- c50_n4_m1[[1]]
c50_n4_m3 <- lista_modelos[7]
c50_n4_m3 <- c50_n4_m3[[1]]

c50_n5_m1 <- lista_modelos[8]
c50_n5_m1 <- c50_n5_m1[[1]]
c50_n5_m3 <- lista_modelos[9]
c50_n5_m3 <- c50_n5_m3[[1]]


test1_n1 <- predict(object = c50_nivel1_v3, newdata = df_data[,2:(ncol(df_data))])


test1_n2_m1 <- predict(object = c50_n2_m1, newdata = df_data[,c(2:(ncol(df_data)))])


test1_n2_m3 <- predict(object = c50_n2_m3, newdata = df_data[,c(2:(ncol(df_data)))])


test1_n3_m1 <- predict(object = c50_n3_m1, newdata = df_data[,c(2:(ncol(df_data)))])


test1_n3_m3 <- predict(object = c50_n3_m3, newdata = df_data[,c(2:(ncol(df_data)))])

test1 <- cbind(as.data.frame(df_data[,1]),     #1
              test1_n1,    #2
              test1_n2_m1, #3
              test1_n2_m3, #4
              test1_n3_m1,
              test1_n3_m3) 
colnames(test1) <- c("s",          #1
                     "Class1",     #2
                     "Class2_m1",  #3
                     "Class2_m3",  #4
                     "Class3_m1",
                     "Class3_m3")  


write.csv(test1, file = paste(opt$outputData,"test1_n1_n2_n3.csv",sep=''), fileEncoding = "UTF-8", row.names=FALSE)

rm(test1)
rm(test1_n3_m3)
rm(test1_n3_m1)
rm(test1_n2_m3)
rm(test1_n2_m1)
rm(test1_n1)
gc()

test1_n4_m1 <- predict(object = c50_n4_m1, newdata = df_data[,c(2:(ncol(df_data)))])

write.csv(test1_n4_m1, file = paste(opt$outputData,"test1_n4_m1.csv",sep=''), fileEncoding = "UTF-8", row.names=FALSE)


rm(test1_n4_m1)
gc()


test1_n4_m3 <- predict(object = c50_n4_m3, newdata = df_data[,c(2:(ncol(df_data)))])


write.csv(test1_n4_m3, file = paste(opt$outputData,"test1_n4_m3.csv",sep=''), fileEncoding = "UTF-8", row.names=FALSE)

rm(test1_n4_m3)
gc()

test1_n5_m1 <- predict(object = c50_n5_m1, newdata = df_data[,c(2:(ncol(df_data)))])


write.csv(test1_n5_m1, file = paste(opt$outputData,"test1_n5_m1.csv",sep=''), fileEncoding = "UTF-8", row.names=FALSE)

rm(test1_n5_m1)
gc()

test1_n5_m3 <- predict(object = c50_n5_m3, newdata = df_data[,c(2:(ncol(df_data)))])

write.csv(test1_n5_m3, file = paste(opt$outputData,"test1_n5_m3.csv",sep=''), fileEncoding = "UTF-8", row.names=FALSE)

rm(test1_n5_m3)
rm(df_data)
gc()

data_n1_n2_n3 <- read.csv(file = paste(opt$outputData,"test1_n1_n2_n3.csv",sep=''),
                        header=TRUE, sep=",", encoding = "UTF-8", stringsAsFactors = FALSE)
                        
data_n4_m1 <- read.csv(file = paste(opt$outputData,"test1_n4_m1.csv",sep=''),
                        header=TRUE, sep=",", encoding = "UTF-8", stringsAsFactors = FALSE)
                        
data_n4_m3 <- read.csv(file = paste(opt$outputData,"test1_n4_m3.csv",sep=''),
                        header=TRUE, sep=",", encoding = "UTF-8", stringsAsFactors = FALSE)
                        
data_n5_m1 <- read.csv(file = paste(opt$outputData,"test1_n5_m1.csv",sep=''),
                        header=TRUE, sep=",", encoding = "UTF-8", stringsAsFactors = FALSE)
                        
data_n5_m3 <- read.csv(file = paste(opt$outputData,"test1_n5_m3.csv",sep=''),
                        header=TRUE, sep=",", encoding = "UTF-8", stringsAsFactors = FALSE)
                        


test1_total <- cbind(data_n1_n2_n3, 
                      Class4_m1= data_n4_m1,
                      Class4_m3= data_n4_m3,
                      Class5_m1= data_n5_m1,
                      Class5_m3= data_n5_m3)
                                        
colnames(test1_total) <- c("s",          #1
                     "Class1",     #2
                     "Class2_m1",  #3
                     "Class2_m3",  #4
                     "Class3_m1",  #5
                     "Class3_m3",  #6
                     "Class4_m1",  #7
                     "Class4_m3",  #8
                     "Class5_m1",  #9
                     "Class5_m3")  #10
                                        
rm(data_n1_n2_n3)
rm(data_n4_m1)
rm(data_n4_m3)
rm(data_n5_m1)
rm(data_n5_m3)
gc()

file.remove(paste(opt$outputData,"test1_n1_n2_n3.csv",sep=''))
file.remove(paste(opt$outputData,"test1_n4_m1.csv",sep=''))
file.remove(paste(opt$outputData,"test1_n4_m3.csv",sep=''))
file.remove(paste(opt$outputData,"test1_n5_m1.csv",sep=''))
file.remove(paste(opt$outputData,"test1_n5_m3.csv",sep=''))

write.csv(test1_total, file = paste(opt$outputData,"test1_total.csv",sep=''), fileEncoding = "UTF-8", row.names=FALSE)


gc()


salida_test1_n1 <- test1_total[,c(1,2)]
colnames(salida_test1_n1) <- c("s","o")
salida_test1_n2 <- test1_total[test1_total$Class2_m1!="desconocido",c(1,4)]
colnames(salida_test1_n2) <- c("s","o")
salida_test1_n3 <- test1_total[test1_total$Class3_m1!="desconocido",c(1,6)]
colnames(salida_test1_n3) <- c("s","o")
salida_test1_n4 <- test1_total[test1_total$Class4_m1!="desconocido",c(1,8)]
colnames(salida_test1_n4) <- c("s","o")
salida_test1_n5 <- test1_total[test1_total$Class5_m1!="desconocido",c(1,10)]
colnames(salida_test1_n5) <- c("s","o")

rm(test1_total)
gc()


salida_test1 <- rbind(salida_test1_n1,
                      salida_test1_n2,
                      salida_test1_n3,
                      salida_test1_n4,
                      salida_test1_n5)

salida_test1$p <- "<http://www.w3.org/1999/02/22-rdf-syntax-ns#type>"
salida_test1[,c(1,2,3)] <- salida_test1[,c(1,3,2)]
write.table(salida_test1, file = paste(opt$outputData,opt$nameFiles,".ttl",sep=''),
            fileEncoding = "UTF-8", sep = " ", row.names=FALSE, col.names=FALSE, quote = FALSE)


