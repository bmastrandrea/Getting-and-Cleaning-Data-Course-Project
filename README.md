# Getting-and-Cleaning-Data-Course-Project

##Instructions for project

The purpose of this project is to demonstrate your ability to collect, work with, and clean a data set. The goal is to prepare tidy data that can be used for later analysis. You will be graded by your peers on a series of yes/no questions related to the project. You will be required to submit: 1) a tidy data set as described below, 2) a link to a Github repository with your script for performing the analysis, and 3) a code book that describes the variables, the data, and any transformations or work that you performed to clean up the data called CodeBook.md. You should also include a README.md in the repo with your scripts. This repo explains how all of the scripts work and how they are connected. 
One of the most exciting areas in all of data science right now is wearable computing - see for example this article . Companies like Fitbit, Nike, and Jawbone Up are racing to develop the most advanced algorithms to attract new users. The data linked to from the course website represent data collected from the accelerometers from the Samsung Galaxy S smartphone. 
A full description is available at the site where the data was obtained: http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones
Here are the data for the project: https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip
You should create one R script called run_analysis.R that does the following.
  1.	Merges the training and the test sets to create one data set.
  2.	Extracts only the measurements on the mean and standard deviation for each measurement.
  3.	Uses descriptive activity names to name the activities in the data set
  4.	Appropriately labels the data set with descriptive variable names.
  5.	From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each       activity and each subject.

In this assignament you can find:
  1.	run_analysis.R: the script that merge the training and the test data to create one data set.
  2.	Tidy.txt: a tidy data set with the average of each variable for each activity and each subject.
  3.	README.md: a detailed explanation of the procedures used to obtain the final file (Tidy.txt) and the run_analysis.R script.
  4.	CodeBook.md: a detailed explanation of the variables used in files Tidy.txt
	
**Used library:**
  library(data.table)   # for manage large table data
  library(dplyr)        # for aggregate the variables and create the tidy data
  
##Analysis
###Download the file and put the file in the `Quiz4` folder

  if(!file.exists("./Quiz4")) {  dir.create("./Quiz4")}

  URL_file <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"

  download.file(URL_file, dest = "./Quiz4/Dataset.zip",method = "auto")

###Unzip the file (in the folder `UCI HAR Dataset`)

  unzip(zipfile = "./Quiz4/Dataset.zip", exdir = "./Quiz4")
  
  path_files <- file.path("./Quiz4" , "UCI HAR Dataset")
  
  From the readme file I know that:
  I have two subfolder named “test” and “train”
  that in the file “features.txt” I have the list of all features and in “activity_labels.txt” I have the links between the      class labels and the activity name.
  I can seee that I don’t need the data that are in the “Inertial Signals” folder.
  
  I need the name of the features and the name of the activities which are in the files mentioned above; so I create two         variables (chrFeatures and lblActivity) and then I load their value into these variables.
  
  chrFeatures <- read.table(file.path(path_files, "features.txt"))
  lblActivity <- read.table(file.path(path_files, "activity_labels.txt"), header = FALSE)
  
###Read and formatting data from training and test files 
Both training and test data sets are split up into subject, activity and features. They are present in three different files.

Read training data
	Sogg_Train <- read.table(file.path(path_files, "train", "subject_train.txt"), header = FALSE)
	Att_Train <- read.table(file.path(path_files, "train", "y_train.txt"), header = FALSE)
	feat_Train <- read.table(file.path(path_files, "train", "X_train.txt"), header = FALSE)

Read test data
	Sogg_Test <- read.table(file.path(path_files, "test", "subject_test.txt"), header = FALSE)
	Att_Test <- read.table(file.path(path_files, "test", "y_test.txt"), header = FALSE)
	feat_Test <- read.table(file.path(path_files, "test", "X_test.txt"), header = FALSE)

###Merge the training and the test sets to create a new data set
Now I can concatenate the data table training and test by row with “rbind” and  store the in subject, activity and features.

	Soggetti <- rbind(Sogg_Train, Sogg_Test)
	Attivita <- rbind(Att_Train, Att_Test)
	Caratteristiche <- rbind(Feat_Train, Feat_Test)

**Naming the columns**

	colnames(Caratteristiche) <- t(chrFeatures[2]) # from the variable created before
	colnames(Attivita) <- "Activity"
	colnames(Soggetti) <- "Subject"
	TotData <- cbind(Caratteristiche,Attivita,Soggetti)

###Extracts the measurements on the mean and standard deviation for each measurement
	WithMeanSTD <- grep(".*Mean.*|.*Std.*", names(TotData), ignore.case = TRUE)
	Elenco_Columns <- c(WithMeanSTD, 562, 563)
	Dati_Estratti <- TotData[,Elenco_Columns]
	
###Uses descriptive activity names to name the activities in the data set
	The activity field in extractedData is originally of numeric type. We need to change its type to character so that it 	can accept activity names. The activity names are taken from metadata lblActivity.
	Dati_Estratti$Activity <- as.character(Dati_Estratti$Activity)
	for (i in 1:6)
	{
	  Dati_Estratti$Activity[Dati_Estratti$Activity == i] <-
	    as.character(lblActivity[i,2])
	}
	We need to factor the activity variable, once the activity names are updated.
	Dati_Estratti$Activity <- as.factor(Dati_Estratti$Activity)

**change the variable names** 
By examining extractedData, we can replace the following acronyms with:

    Accelerometer = Acc 
    Gyroscope = Gyro
    Body = BodyBody
    Magnitude = Mag
    Frequency Character f
    Time = Character t
and so:
	names(Dati_Estratti)<-gsub("Acc", "Accelerometer", names(Dati_Estratti))
	names(Dati_Estratti)<-gsub("Gyro", "Gyroscope", names(Dati_Estratti))
	names(Dati_Estratti)<-gsub("BodyBody", "Body", names(Dati_Estratti))
	names(Dati_Estratti)<-gsub("Mag", "Magnitude", names(Dati_Estratti))
	names(Dati_Estratti)<-gsub("^t", "Time", names(Dati_Estratti))
	names(Dati_Estratti)<-gsub("^f", "Frequency", names(Dati_Estratti))

###Creates a second, independent tidy data set and ouput it
	From the previously create data set, I create a second, independent tidy data set with the average of each variable 		for each activity and each subject.
	
	Dati_Estratti$Subject <- as.factor(Dati_Estratti$Subject)
	Dati_Estratti <- data.table(Dati_Estratti)
	tidyData <- aggregate(. ~ Subject + Activity, Dati_Estratti, mean)
	tidyData <- tidyData[order(tidyData$Subject,tidyData$Activity),]
	write.table(tidyData, file = "Tidy.txt", row.names = FALSE)
