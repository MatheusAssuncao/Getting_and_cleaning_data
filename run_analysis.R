# Getting and cleaning data

# Week 4

  # Peer-graded assignment

  #You should create one R script called run_analysis.R that does the following.
  
  # 1. Merges the training and the test sets to create one data set.
  # 2. Extracts only the measurements on the mean and standard deviation for each measurement.
  # 3. Uses descriptive activity names to name the activities in the data set
  # 4. Appropriately labels the data set with descriptive variable names.
  # 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.


  # Downloading the filmes into the folder and extracting them
    getwd()
  
    install.packages("dplyr")
    library(dplyr)
    library(data.table)
    library(reshape2)
  
    url_file <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
    
    download.file(url_file, "dataset.zip")
    
    unzip("dataset.zip")
  
  
  # Loading labels + features of the activities
    
    activityLabels <- fread("UCI HAR Dataset/activity_labels.txt", col.names = c("classLabels", "activityName"))
    
    features <- fread("UCI HAR Dataset/features.txt", col.names = c("index", "featureNames"))
    
    featuresAnayzed <- grep("(mean|std)\\(\\)", features[, featureNames]) # Selecting only features of mean and standad deviation
    
    measurements <- features[featuresAnayzed, featureNames]
    
    measurements <- gsub('[()]', '', measurements)
    
    
  # Train Datasets
    
    train <- fread("UCI HAR Dataset/train/X_train.txt")[, featuresAnayzed, with = FALSE]
    data.table::setnames(train, colnames(train), measurements) # Setting the names of variables to be the measurements
    
    trainActivities <- fread("UCI HAR Dataset/train/Y_train.txt", col.names = c("Activity"))
    trainSubjects <- fread("UCI HAR Dataset/train/subject_train.txt", col.names = c("SubjectNum"))
    
    train <- cbind(trainSubjects, trainActivities, train)
    
    
  # Test Datasets
    
    test <- fread("UCI HAR Dataset/test/X_test.txt")[, featuresAnayzed, with = FALSE]
    data.table::setnames(test, colnames(test), measurements) # Setting the names of variables to be the measurements
    
    testActivities <- fread("UCI HAR Dataset/test/Y_test.txt", col.names = c("Activity"))
    testSubjects <- fread("UCI HAR Dataset/test/subject_test.txt", col.names = c("SubjectNum"))
    
    test <- cbind(testSubjects, testActivities, test)
    
    
  # Merging datasets
    
    combined <- rbind(train, test)

  
  # Adding activity labels
    
    combined[["Activity"]] <- factor(combined[, Activity]
                                     , levels = activityLabels[["classLabels"]]
                                     , labels = activityLabels[["activityName"]])
    
    combined <- reshape2::melt(combined, id = c("SubjectNum", "Activity"))
    combined <- reshape2::dcast(combined, SubjectNum + Activity ~ variable, fun.aggregate = mean)    
    
    data.table::fwrite(x = combined, file = "tidyData.txt", quote = FALSE)
    