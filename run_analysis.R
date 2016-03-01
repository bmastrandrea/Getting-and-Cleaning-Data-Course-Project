library(data.table)   # for manage large table data
library(dplyr)        # for aggregate the variables and create the tidy data

# It create the folder if it don't exist

if(!file.exists("./Quiz4")) {  dir.create("./Quiz4")}

# download file in the new directory
URL_file <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(URL_file, dest = "./Quiz4/Dataset.zip",method = "auto")

# unzip file
unzip(zipfile = "./Quiz4/Dataset.zip", exdir = "./Quiz4")

path_files <- file.path("./Quiz4" , "UCI HAR Dataset")
chrFeatures <- read.table(file.path(path_files, "features.txt"))
lblActivity <- read.table(file.path(path_files, "activity_labels.txt"), header = FALSE)

# for every folder I read the files and load data in the correspondent variable
# train folder
Sogg_Train <- read.table(file.path(path_files, "train", "subject_train.txt"), header = FALSE)
Att_Train <- read.table(file.path(path_files, "train", "y_train.txt"), header = FALSE)
Feat_Train <- read.table(file.path(path_files, "train", "X_train.txt"), header = FALSE)

# test folder
Sogg_Test <- read.table(file.path(path_files, "test", "subject_test.txt"), header = FALSE)
Att_Test <- read.table(file.path(path_files, "test", "y_test.txt"), header = FALSE)
Feat_Test <- read.table(file.path(path_files, "test", "X_test.txt"), header = FALSE)

# bind test and train data 

Soggetti <- rbind(Sogg_Train, Sogg_Test)
Attivita <- rbind(Att_Train, Att_Test)
Caratteristiche <- rbind(Feat_Train, Feat_Test)

# Naming the columns

colnames(Caratteristiche) <- t(chrFeatures[2]) # from the variable created before
colnames(Attivita) <- "Activity"
colnames(Soggetti) <- "Subject"
TotData <- cbind(Caratteristiche,Attivita,Soggetti)

#Extract the column indices twith mean or std
WithMeanSTD <- grep(".*Mean.*|.*Std.*", names(TotData), ignore.case = TRUE)
Elenco_Columns <- c(WithMeanSTD, 562, 563)

Dati_Estratti <- TotData[,Elenco_Columns]

# change the data type of "activity" from number to character
Dati_Estratti$Activity <- as.character(Dati_Estratti$Activity)
for (i in 1:6)
{
  Dati_Estratti$Activity[Dati_Estratti$Activity == i] <-
    as.character(lblActivity[i,2])
}

Dati_Estratti$Activity <- as.factor(Dati_Estratti$Activity)

# change the variable names 
names(Dati_Estratti)<-gsub("Acc", "Accelerometer", names(Dati_Estratti))
names(Dati_Estratti)<-gsub("Gyro", "Gyroscope", names(Dati_Estratti))
names(Dati_Estratti)<-gsub("BodyBody", "Body", names(Dati_Estratti))
names(Dati_Estratti)<-gsub("Mag", "Magnitude", names(Dati_Estratti))
names(Dati_Estratti)<-gsub("^t", "Time", names(Dati_Estratti))
names(Dati_Estratti)<-gsub("^f", "Frequency", names(Dati_Estratti))


Dati_Estratti$Subject <- as.factor(Dati_Estratti$Subject)
Dati_Estratti <- data.table(Dati_Estratti)
tidyData <- aggregate(. ~ Subject + Activity, Dati_Estratti, mean)
tidyData <- tidyData[order(tidyData$Subject,tidyData$Activity),]
write.table(tidyData, file = "Tidy.txt", row.names = FALSE)


