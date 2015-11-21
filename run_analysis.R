# The data linked to from the course website represent data collected from the accelerometers from the Samsung
# Galaxy S smartphone. A full description is available at the site where the data was obtained:
#    http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones
# Here are the data for the project:
#    https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip
#
#  You should create one R script called run_analysis.R that does the following:
#  * Merges the training and the test sets to create one data set.
#  * Extracts only the measurements on the mean and standard deviation for each measurement.
#  * Uses descriptive activity names to name the activities in the data set
#  * Appropriately labels the data set with descriptive variable names.
#
# From the data set in step 4, creates a second, independent tidy data set with the
# average of each variable for each activity and each subject.


# setwd("C:/Storage/CourseRA Extras/Courses/[Coursera track 02] - Data Science Intro/03 Getting and Cleaning Data/Assignments/project")
# setwd("C:/SANDBOX/CourseRA/[CourseRA track] - Data Science/ds03 Getting and Cleaning Data/Assignments/project")


# --------- LOAD DATASETS

xtest.df <- data.frame(read.delim('x_test.txt', header=FALSE, sep=""))
ytest.df <- data.frame(read.delim('y_test.txt', header=FALSE, sep=""))
test.df <- cbind(xtest.df, ytest.df)

xtrain.df <- data.frame(read.delim('x_train.txt', header=FALSE, sep=""))
ytrain.df <- data.frame(read.delim('y_train.txt', header=FALSE, sep=""))
train.df <- cbind(xtrain.df, ytrain.df)


# --------- COMBINED DATA & cleanup
all.df <- rbind(test.df, train.df)

rm(xtest.df)
rm(xtrain.df)
rm(test.df)
rm(train.df)
rm(ytest.df)
rm(ytrain.df)


# --------- ADD VARIABLE NAMES
dfnames <- read.table('features.txt', header=FALSE)
new_name <- data.frame(V1=as.numeric(562), V2=c("Activity_Code"))

dfnames <- rbind(dfnames, new_name )
colnames(all.df) <- dfnames[,2]


# --------- MAKE A SMALLER DATASET : SUBSET, ADD ACTIVITY LABELS
colnames.ToKeep <-
   colnames(all.df)[grep(".*-mean\\(.*|.*-std\\(.*",colnames(all.df),ignore.case = T)]
colnames.ToKeep[length(colnames.ToKeep)+1] <- "Activity_Code"
# -- filter
all_final.df <- all.df[,colnames.ToKeep]
rm(all.df)
# -- labels
activity.labels <- data.frame(read.table('activity_labels.txt', header=FALSE))
colnames(activity.labels) <-c ("Activity_Code", "Descriptive_Activity_Name")
# -- merge dataset and labels to assign the descriptive activity name
final.df <- merge(all_final.df, activity.labels, by.x="Activity_Code", by.y="Activity_Code")
rm(all_final.df)

# --------- SAVE RESULTS TO FILE
# install.packages("reshape2")
library(reshape2)

results.df <-   aggregate(final.df[,-c(68)], list(Descriptive_Activity_Name = final.df$"Descriptive_Activity_Name"), mean)
tidy.df <- melt(results.df, id=c("Descriptive_Activity_Name"),
                measure.vars = colnames(results.df)[3:68]
                ,variable.name="Subject",value.name="Average"
           )

#write.table(results.df, file = "results.txt", row.names = FALSE)
write.table(tidy.df, file = "results_tidy.txt", row.names = FALSE)
