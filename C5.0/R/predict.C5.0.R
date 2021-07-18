library(Cubist)
library("data.table")
#library(C50)

##### Función makeDataFile de Cubist
dyn.load("C5.0/src/top.so")


create_strings <- function(original_vector) {

  vector_length = length(original_vector)
  
  nchars = sum(nchar(original_vector, type = "chars"))
  
  ## Check if the length of the string would reach the length limits in R
  #1900000000
  if(nchars >= 1900000000){
  
    ## Calculate how many strings we could create of the maximum length 
    nchunks = 0
    while(nchars > 0){
      nchars = nchars - 1900000000
      nchunks = nchunks + 1
    }
    
    ## Get the number of rows that would be contained in each string
    chunk_size = vector_length/nchunks
    
    ## Get the rounded number of rows in each string
    chunk_size = floor(chunk_size)
    index = chunk_size
    
    ## Create a vector with the indexes of the rows that delimit each string
    indexes_vector = c()  
    indexes_vector = append(indexes_vector, 0)
    
    n = nchunks
    while(n > 0){
      indexes_vector = append(indexes_vector, index)
      index = index + chunk_size
    
      n = n - 1
    }
    
    ## Get the last few rows if the division had remainder 
    remainder = vector_length %% nchunks
    if (remainder != 0){
      indexes_vector = append(indexes_vector, vector_length)
      nchunks = nchunks + 1
    }
    
    ## Create the strings pasting together the rows from the indexes in the indexes vector
    strings_vector = c()
    i = 2
    while (i <= length(indexes_vector)){
     
      ## Sum 1 to the index_init so that the next string does not contain the last row of the previous string
      index_init = indexes_vector[i-1] + 1
      index_end = indexes_vector[i]
      
      ## Paste the rows from the vector from index_init to index_end
      string <- paste0(original_vector[index_init:index_end], collapse="")
      ## Create vector containing the strings that were created 
      strings_vector <- append(strings_vector, string)
      i = i + 1
    }
    
    
  }else {
    strings_vector = paste0(original_vector, collapse="")
  }
  
  strings_vector
}

escapes <- function(x, chars = c(":", ";", "|")) {
  for (i in chars)
    x <- gsub(i, paste("\\", i, sep = ""), x, fixed = TRUE)
  gsub("([^[:alnum:]^[:space:]])", "\\\\\\1", x, useBytes = TRUE)
}

makeDataFile_modificado <- function(x, y, w = NULL) {
  if (!is.data.frame(x) || inherits(x, "tbl_df")) {
    x <- as.data.frame(x)
  }
  convert <-
    unlist(lapply(x, function(x)
      is.factor(x) | is.character(x)))
  if (any(convert))
    for (i in names(convert)[convert])
      x[, i] <- escapes(as.character(x[, i]))
  if (is.null(y))
    y <- rep(NA_real_, nrow(x))
  y <- escapes(as.character(y))
  x <- cbind(y, x)
  if (!is.null(w))
    x <- cbind(x, w)
  ## Determine the locations of missing values
  naIndex <- lapply(x, function(x) which(is.na(x)))
  anyNA <- any(unlist(lapply(naIndex, length)) > 0)
  x <- as.matrix(format(x, digits = 15, scientific = FALSE))
  ## remove leading white space
  x <- gsub("^[[:blank:]]*", "", x)
  ## reset missing values
  if (anyNA)
    for (i in seq(along = naIndex))
      if (length(naIndex[[i]]) > 0)
        x[naIndex[[i]], i] <- "?"
  
  x = apply(x, 1, paste, collapse = ",")
  
  x = paste(x, "\n", sep="")
  
  char_vec = create_strings(x)
  
  rm(y)
  rm(x)
  gc()
  
  char_vec
}


#' Predict new samples using a C5.0 model
#'
#' This function produces predicted classes or confidence values
#'  from a C5.0 model.
#'
#' Note that the number of trials in the object my be less than
#'  what was specified originally (unless `earlyStopping = FALSE`
#'  was used in [C5.0Control()]. If the number requested
#'  is larger than the actual number available, the maximum actual
#'  is used and a warning is issued.
#'
#'   Model confidence values reflect the distribution of the classes
#'  in terminal nodes or within rules.
#'
#'   For rule-based models (i.e. not boosted), the predicted
#'  confidence value is the confidence value from the most specific,
#'  active rule. Note that C4.5 sorts the rules, and uses the first
#'  active rule for prediction. However, the default in the original
#'  sources did not normalize the confidence values. For example,
#'  for two classes it was possible to get confidence values of
#'  (0.3815, 0.8850) or (0.0000, 0.922), which do not add to one.
#'  For rules, this code divides the values by their sum. The
#'  previous values would be converted to (0.3012, 0.6988) and (0,
#'  1). There are also cases where no rule is activated. Here, equal
#'  values are assigned to each class.
#'
#'   For boosting, the per-class confidence values are aggregated
#'  over all of the trees created during the boosting process and
#'  these aggregate values are normalized so that the overall
#'  per-class confidence values sum to one.
#'
#'   When the `cost` argument is used in the main function, class
#'  probabilities derived from the class distribution in the
#'  terminal nodes may not be consistent with the final predicted
#'  class. For this reason, requesting class probabilities from a
#'  model using unequal costs will throw an error.
#'
#' @param object an object of class `C5.0`
#' @param newdata a matrix or data frame of predictors
#' @param trials an integer for how many boosting iterations are
#'  used for prediction. See the note below.
#' @param type either `"class"` for the predicted class or
#'  `"prob"` for model confidence values.
#' @param na.action when using a formula for the original model
#'  fit, how should missing values be handled?
#' @param \dots other options (not currently used)
#' @return when `type = "class"`, a factor vector is returned.
#'  When `type = "prob"`, a matrix of confidence values is returned
#'  (one column per class).
#' @author Original GPL C code by Ross Quinlan, R code and
#'  modifications to C by Max Kuhn, Steve Weston and Nathan Coulter
#' @seealso [C5.0()], [C5.0Control()],
#'  [summary.C5.0()], [C5imp()]
#' @references Quinlan R (1993). C4.5: Programs for Machine
#'  Learning. Morgan Kaufmann Publishers,
#'  \url{http://www.rulequest.com/see5-unix.html}
#' @keywords models
#' @examples
#'
#' library(modeldata)
#' data(mlc_churn)
#'
#' treeModel <- C5.0(x = mlc_churn[1:3333, -20], y = mlc_churn$churn[1:3333])
#' predict(treeModel, mlc_churn[3334:3350, -20])
#' predict(treeModel, mlc_churn[3334:3350, -20], type = "prob")
#'
#'
#' @export
#' @rawNamespace export(predict.C5.0)
#' @importFrom Cubist makeDataFile makeNamesFile QuinlanAttributes
predict.C5.0 <-
  function (object,
            newdata = NULL,
            trials = object$trials["Actual"],
            type = "class",
            na.action = na.pass,
            ...)  {
    if (!(type %in% c("class", "prob")))
      stop("type should be either 'class', 'confidence' or 'prob'",
           call. = FALSE)
    if (object$cost != "" &
        type == "prob")
      stop("confidence values (i.e. class probabilities) should ", "
           not be used with costs",
           call. = FALSE)
    if (is.null(newdata))
      stop("newdata must be non-null", call. = FALSE)

    if (!is.null(object$Terms)) {
      object$Terms <- delete.response(object$Terms)
      newdata <-
        model.frame(object$Terms,
                    newdata,
                    na.action = na.action,
                    xlev = object$xlevels)
    } else
      newdata <- newdata[, object$predictors, drop = FALSE]

    if (is.null(colnames(newdata)))
      stop("column names are required", call. = FALSE)

    if (length(trials) > 1)
      stop("only one value of trials is allowed")
    if (trials > object$trials["Actual"])
      warning(
        paste(
          "'trials' should be <=",
          object$trials["Actual"],
          "for this object. Predictions generated using",
          object$trials["Actual"],
          "trials"
        ),
        call. = FALSE
      )

    ## If there are case weights used during training, the C code
    ## will expect a column of weights in the new data but the
    ## values will be ignored. `makeDataFile` puts those last in
    ## the data when `C5.0.default` is run, so we will add a
    ## column of NA values at the end here
    if (object$caseWeights)
      newdata$case_weight_pred <- NA

    ## make cases file
    caseString_mio <- makeDataFile_modificado(x = newdata, y = NULL)
  
    num_chars = sum(nchar(caseString_mio, type = "chars"))
    

    ## When passing trials to the C code, convert to
    ## zero if the original version of trials is used

    if (trials <= 0)
      stop("'trials should be a positive integer", call. = FALSE)
    if (trials == object$trials["Actual"])
      trials <- 0
      

    ## Add trials (not object$trials) as an argument
    results <- .Call(
      "call_predictions",
      caseString_mio,
      as.character(num_chars),
      as.character(object$names),
      as.character(object$tree),
      as.character(object$rules),
      as.character(object$cost),
      pred = integer(nrow(newdata)),
      confidence = double(length(object$levels) * nrow(newdata)),
      trials = as.integer(trials)
    )
    
    
    predictions = as.numeric(unlist(results[1]))
    confidence = as.numeric(unlist(results[2]))
    output = as.character(results[3])
    
    
    if(any(grepl("Error limit exceeded", output)))
      stop(output, call. = FALSE)

    if (type == "class") {
      out <- factor(object$levels[predictions], levels = object$levels)
    } else {
      out <-
        matrix(confidence,
               ncol = length(object$levels),
               byrow = TRUE)
      if (!is.null(rownames(newdata)))
        rownames(out) <- rownames(newdata)
      colnames(out) <- object$levels
    }
    
    rm(results)
    rm(caseString_mio)
    rm(newdata)
    rm(object)
    gc()
    
    out
  }
