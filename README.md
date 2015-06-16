# Getting and Cleaning Data Project

## Background

### Information from Course Project Assigment

The purpose of this project is to demonstrate your ability to collect, work with, and clean a data set. The goal is to prepare tidy data 
that can be used for later analysis. You will be graded by your peers on a series of yes/no questions related to the project. 
You will be required to submit: 

   1. a tidy data set as described below,
   2. a link to a Github repository with your script for performing the analysis
   3. a code book that describes the variables, the data, and any transformations or work that you performed to clean up the data called CodeBook.md. 
   4. You should also include a README.md in the repo with your scripts. This repo explains how all of the scripts work and how they are connected. 

One of the most exciting areas in all of data science right now is wearable computing - see for example <a href="http://www.insideactivitytracking.com/data-science-activity-tracking-and-the-battle-for-the-worlds-top-sports-brand/">this article. </a>
Companies like Fitbit, Nike, and Jawbone Up are racing to develop the most advanced algorithms to attract new users. 
The data linked to from the course website represent data collected from the accelerometers from the Samsung Galaxy S smartphone. 
A full description is available at the site where the data was obtained:

http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones

Here are the data for the project:

https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

You should create one R script called run_analysis.R that does the following. 

   1. Merges the training and the test sets to create one data set.
   2. Extracts only the measurements on the mean and standard deviation for each measurement. 
   3. Uses descriptive activity names to name the activities in the data set
   4. Appropriately labels the data set with descriptive variable names. 
   5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.


### Data Set Information (from <a href="http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones">UCI Machine Learning Respository</a>)

The experiments have been carried out with a group of 30 volunteers within an age bracket of 19-48 years. Each person performed six activities (WALKING, WALKING_UPSTAIRS, 
WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING) wearing a smartphone (Samsung Galaxy S II) on the waist. Using its embedded accelerometer and gyroscope, we captured 3-axial 
linear acceleration and 3-axial angular velocity at a constant rate of 50Hz. The experiments have been video-recorded to label the data manually. The obtained dataset has been 
randomly partitioned into two sets, where 70% of the volunteers was selected for generating the training data and 30% the test data.

The sensor signals (accelerometer and gyroscope) were pre-processed by applying noise filters and then sampled in fixed-width sliding windows of 2.56 sec and 50% overlap (128 
readings/window). The sensor acceleration signal, which has gravitational and body motion components, was separated using a Butterworth low-pass filter into body acceleration 
and gravity. The gravitational force is assumed to have only low frequency components, therefore a filter with 0.3 Hz cutoff frequency was used. From each window, a vector of 
features was obtained by calculating variables from the time and frequency domain.

Check the README.txt file for further details about this dataset.
   

### Attribute Information

For each record in the dataset is provided:
- Triaxial acceleration from the accelerometer (total acceleration) and the estimated body acceleration.
- Triaxial Angular velocity from the gyroscope.
- A 561-feature vector with time and frequency domain variables.
- Its activity label.
- An identifier of the subject who carried out the experiment. 


## Data Processing

### Initial Inspection of Data

Inspection of the unzipped data set reveals data in multiple files in multiple directories. According to the course definition this data set is not in a "tidy" format.

The data in the files in the subdirectories /test/Inertial Signals/ and /train/Inertial Signals/ (body_acc_[xyz].txt, body_gyro_[xyz].txt and tot_acc_[xyz].txt) appear to be 
partially processed raw data which is then further processed to form the larger feature data sets in /test/X_test.txt and /train/X_train.txt. As this would be pre-processed 
and post-processed versions of the same data it was therefore assumed that these files should not be merged into an integrated data set (as per project requirement 1).

Inpection of the processed feature data sets in in /test/X_test.txt and /train/X_train.txt reveal no missing data (NAs). Therefore no further account was made for missing data in
the run_analysis script.

### Package requirements

The run_analysis.R script uses libraries:
- dplyr
- tidyr

### run_analysis.R script

There is only one R script (run_analysis.R) needed for this project. This script runs all of the required steps.

#### Loading of data

The script checks whether or not the zip data file has been downloaded and unzipped. If this has not happened, then it downloads the zip file and unzips it in a pre-specified directory.
The 8 main data files are then read into memory as dataframes. The files are:
- features.txt				Description of data features in columns of X_*.txt files
- activity_labels.txt 		Description of activities in column 2 of y_*.txt files
- /test/subject_test.txt	ID labels for subjects in test set
- /test/X_test.txt			Processed feature data for test subjects
- /test/y_test.txt			Activity labels for subjects in test set
- /train/subject_train.txt	ID labels for subjects in training set
- /train/X_train.txt		Processed feature data for training subjects
- /train/y_train.txt		Activity labels for subjects in training set
    

#### Step 1 - Merging of data

To start creating a tidy data set the columns of /test/subject_test.txt (1 col), /test/y_test.txt (1 col) and /test/y_test.txt (561 cols )were combined to create a new dataset, called *test*. 
A new column descriptor "Set" containing the value "test" was also added in the event that identification of the original source of the data was needed (564 cols in total, 2947 rows).

The columns of /train/subject_train.txt, /train/y_train.txt and /train/y_train.txt were similarly combined to create a new dataset, called *train*. A new column descriptor "Set"
containing the value "train" was also added (again 564 cols in total, but with 7352 rows).

The rows of dataframe *test* and *train* were then combined into one unified dataframe, called *data* (564 cols, 10299 rows).


### Step 2 - Extract only the measurements on the mean and standard deviation

There is some ambiguity about how to interpret and operationalize this step. I chose to interpret this as meaning keep only those feature columns (cols 4 to 564) in the combined dataframe 
*data* that were themselves explicitly labelled as being a mean or standard deviation. I operationalized this by searching for, and only selecting, those names in the features.txt file that 
either contained the string "mean()" or the string "std()" to create an index *idx*. This index was used to extract only those columns from *data* that matched, together with the initial 3 
id columns (SubjectID, ActivityID, Set). This created a reduced dataframe, still called *data* containing 82 columns (the 3 ID cols of SubjectID, ActivityID and Set + 79 mean/std feature cols)
and 10299 rows.


### Step 3 - Use descriptive activity names to name the activities in the data set

The names of the activities present in the activity_labels.txt file were used to replace their respective ID codes in the main dataframe *data*. Specifially where the dataframe *data*, column
*ActivityID* contains:
- ID code 1, this is replaced with "WALKING"
- ID code 2, this is replaced with "WALKING_UPSTAIRS"
- ID code 3, this is replaced with "WALKING_DOWNSTAIRS"
- ID code 4, this is replaced with "SITTING"
- ID code 5, this is replaced with "STANDING"
- ID code 6, this is replaced with "LAYING"

The column name of the field is then renamed from "ActivityID" to "Activity"

### Step 4 - Appropriately label the data set with descriptive variable names

Columns 1-3 are already labelled with meaningfully descriptive variable names:

1. SubjectID - unique number identifying subject
2. Activity -  name of activity being undertaken
3. Set - name of data set (test or train) from where data came

but the remaining 79 columns containing feature data are somewhat messy partly because of the original naming scheme and also because the import of text fields as variable names has replaced certain
characters such as "-", "(" and ")" with a "." symbol.

Cleaning up these columns and making more readable is achieved by:

1. Replacing all instances of "..." with "."
2. Replacing all instances of ".." with nothing
3. Replacing the beginning of each variable name "t" with "Time"
4. Replacing the beginning of each variable name "f" with "Freq"

### Step 5 - Creates a second, independent tidy data set with the average of each variable for each activity and each subject

This is achieved very simply by using the tidyr library commands. The dataframe is first converted to long format using the gather() command. It is then grouped by SubjectID, Activity and Feature using
the group_by() command. The summarize() command is then applied to extract the mean values of each Feature per Activity per Subject. At this point, the mean summarized tidy data needs to be written out
to a text file. However there is a choice to be made between writing it out in long format (14220 rows by 4 cols) or wide format (180 rows by 81 cols). The latter format seems more readable so the long
form mean summary data is converted to a wide format version using the spread() command prior to being written out as a txt file created with write.table() using row.name=FALSE. This file has 180 rows, 
comprising 30 subjects x 6 activity conditions (30x6=180) and 81 columns comprising 2 ID columns (SubjectID and Activity) together with 79 columns that are the mean values of the selected mean/std 
features.
