library(reshape2)

file_name <- "getdata_dataset.zip"

## Download and unzip the dataset:
if (!file.exists(file_name)){
  file_URL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
  download.file(file_URL, file_name,mode='wb')
}  

if (!file.exists("UCI HAR Dataset")) { 
  unzip(file_name) 
}

# Load activity labels + features
activity_Labels <- read.table("UCI HAR Dataset/activity_labels.txt")
activity_Labels[,2] <- as.character(activity_Labels[,2])
features <- read.table("UCI HAR Dataset/features.txt")
features[,2] <- as.character(features[,2])

# Extract only the data on mean and standard deviation
features_Wanted <- grep(".*mean.*|.*std.*", features[,2])
features_Wanted.names <- features[features_Wanted,2]
features_Wanted.names = gsub('-mean', 'Mean', features_Wanted.names)
features_Wanted.names = gsub('-std', 'Std', features_Wanted.names)
features_Wanted.names <- gsub('[-()]', '', features_Wanted.names)


# Load the datasets
train <- read.table("UCI HAR Dataset/train/X_train.txt")[features_Wanted]
train_Activities <- read.table("UCI HAR Dataset/train/Y_train.txt")
train_Subjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
train <- cbind(train_Subjects, train_Activities, train)

test <- read.table("UCI HAR Dataset/test/X_test.txt")[features_Wanted]
Activities <- read.table("UCI HAR Dataset/test/Y_test.txt")
Subjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
test <- cbind(Subjects, Activities, test)

# merge datasets and add labels
Data <- rbind(train, test)
colnames(Data) <- c("subject", "activity", features_Wanted.names)

# turn activities & subjects into factors
Data$activity <- factor(Data$activity, levels = activity_Labels[,1], labels = activity_Labels[,2])
Data$subject <- as.factor(Data$subject)

Data.melted <- melt(Data, id = c("subject", "activity"))
Data.mean <- dcast(Data.melted, subject + activity ~ variable, mean)

write.table(Data.mean, "tidy.txt", row.names = FALSE, quote = FALSE)