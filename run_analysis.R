## load necessary packages
library(reshape2)

## Set working directory
setwd("C:/Users/Administrator/Desktop/Coursera/project")


## Download the zip file and unzip it
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
if (!file.exists('./data')) {
  dir.create("./data")
}
if (!file.exists('./data/dataset.zip')) {
  download.file(fileUrl, destfile = './data/dataset.zip')
}
if (!file.exists('./data/CI HAR Dataset')) {
  unzip('./data/dataset.zip', exdir='./data')
}


## Read activity labels, features commonly used in data set
features <- read.table('./data/UCI HAR Dataset/features.txt')
activityLabels <- read.table('./data/UCI HAR Dataset/activity_labels.txt')


## Extract measurements on the mean(mean) and standard deviation(std)
featureIndex <- grep("mean|std", features$V2)
featureNames <- features[grep("mean|std", features$V2),2]


## Read the data
train <- read.table('./data/UCI HAR Dataset/train/X_train.txt')[,featureIndex]
trainActivities <- read.table('./data/UCI HAR Dataset/train/y_train.txt')
trainSubjects <- read.table('./data/UCI HAR Dataset/train/subject_train.txt')
train <- cbind(trainSubjects, trainActivities, train)

test <- read.table('./data/UCI HAR Dataset/test/X_test.txt')[,featureIndex]
testActivities <- read.table('./data/UCI HAR Dataset/test/y_test.txt')
testSubjects <- read.table('./data/UCI HAR Dataset/test/subject_test.txt')
test <- cbind(testSubjects, testActivities, test)


## Merge them
totalData <- rbind(train, test)
colnames(totalData) <- c("subject", "activity", featureNames)


## Transform subject and activity columns to factor columns,
## prepared for later calculation
totalData$subject <- as.factor(totalData$subject)
totalData$activity <- factor(totalData$activity, 
                              levels=activityLabels[,1],
                              labels=activityLabels[,2])


## Firstly, I wanted to use group_by and summarize to calculate the values.
## But summarize function need name-value pairs, that sounds tedious.
## Finally, found that the combination of melt and dcast maybe the best.
meltedData <- melt(totalData, id.vars = c("subject", "activity"))
averageNeeded <- dcast(meltedData, subject+activity~variable,
                       fun.aggregate = mean,
                       value.var = "value")

write.table(averageNeeded, "./data/tidy.txt", quote = FALSE, row.names = FALSE)