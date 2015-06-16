#----------------------------------------------------------------------------------------------------------------------
#
# Data Sciences Specialization
# Getting and Cleaning Data Course Project
# 16/06/2015
#
#----------------------------------------------------------------------------------------------------------------------

run_analysis <- function() {

    # Load libraries that will be used
    library(dplyr)
    library(tidyr)    

    #------------------------------------------------------------------------------------------------------------------
    # Downloading stage
    cur_dir   <- getwd()                        # Save current working dir
    data_dir  <- "./UCI HAR Dataset"            # Directory where unzipped data is saved (current working dir)
    save_file <- "tidy_averages.txt"            # Name of the final saved output file (tidy averaged data)
    
    # Check if the data files exist locally, if not retrieve and unzip them
    if (!dir.exists(data_dir)) {
        print("Downloading zip file...") 

        ## Retrieve zip data from URL
        filename <- tempfile()
        download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip", filename)

        print("Unzipping data files...")         
        unzip(filename, exdir=dirname(data_dir))

        ##Tidy up
        unlink(filename, force=TRUE)
    }
    setwd(data_dir)
    
    # Load individual files into memory as dataframes (s=subject, d=data, a=activity)
    print("Loading files into memory...")
    features   <- read.table("./features.txt", header=F, as.is=F, col.names=c("FeatureID", "Feature"))
    activities <- read.table("./activity_labels.txt", header=F, col.names=c("ActivityID", "Activity"))
    test.s     <- read.table("./test/subject_test.txt", header=F, col.names=c("SubjectID"))
    test.d     <- read.table("./test/X_test.txt", header=F, col.names=features$Feature)
    test.a     <- read.table("./test/y_test.txt", header=F, col.names=c("ActivityID"))
    train.s    <- read.table("./train/subject_train.txt", header=F, col.names=c("SubjectID"))
    train.d    <- read.table("./train/X_train.txt", header=F, col.names=features$Feature)
    train.a    <- read.table("./train/y_train.txt", header=F, col.names=c("ActivityID"))
    
    #------------------------------------------------------------------------------------------------------------------
    # Step 1. Merge the training and the test sets to create one data set, converted to a dplyr table
    test  <- cbind(test.s,  test.a, Set="test", test.d)         # Added extra column Set to keep track of data source
    train <- cbind(train.s, train.a, Set="train", train.d)      # Added extra column Set to keep track of data source
    data  <- tbl_df(rbind(test,train))
    # Bit of tidying up to save memory
    rm(test.s, test.d, test.a, test, train.s, train.d, train.a, train)
    
    #------------------------------------------------------------------------------------------------------------------
    # Step 2. Extract from data the only the feature columns containing mean or standard deviation measures. 
    # Also retain subject, set and activity data in columns 1:3 from the overall dataframe
    idx  <- c(1:3, 3+sort(c(grep("mean\\(\\)",features$Feature), grep("std\\(\\)",features$Feature))))    
    data <- data[,idx]
    
    #------------------------------------------------------------------------------------------------------------------
    # Step 3. Use descriptive activity names to name the activities in the data set (rather than the ActivityID)
    data$ActivityID          <- as.factor(data$ActivityID)    
    levels(data$ActivityID)  <- activities$Activity
    names(data)[2]           <- "Activity"
    
    #------------------------------------------------------------------------------------------------------------------
    # Step 4. Appropriately label the data set with descriptive variable names
    # Basic labels are in place but the feature labels are messy and need tidying
    labels <- names(data)
    labels <- gsub("\\.\\.\\.", ".", labels)
    labels <- gsub("\\.\\.", "", labels)    
    labels <- gsub("^t", "Time", labels)
    labels <- gsub("^f", "Freq", labels)
    names(data) <- labels
    
    #------------------------------------------------------------------------------------------------------------------
    # Step 5. From the data set in step 4, create a second, independent tidy data set with the average of each 
    #         variable for each activity and each subject.
    
    # First restructure the data into long format
    data_long <- gather(data, Feature, Value, 4:ncol(data))
    
    # Group the data by SubjectID, Activity and Feature
    dataGroup <- group_by(data_long, SubjectID, Activity, Feature)
    
    # Collapse the data to extract mean values of each Feature per Activity per Subject
    data_mean <- summarize(dataGroup,mean(Value))
    names(data_mean)[4] <- "meanValue"
    
    # At this spoint could either export data in long or wide format.
    # Chose wide format for greater readability
    data_mean_wide <- spread(data_mean, Feature, meanValue)
    
    # Write this summary tidied data out (to current working dir)
    setwd(cur_dir)
    write.table(data_mean_wide, save_file, row.names=FALSE, quote=FALSE)
    
    # Done
    print("Finished processing")
}