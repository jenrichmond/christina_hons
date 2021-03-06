library(tidyr)
library(httr)

## THIS SCRIPT BREAKS DOWN THE COMPLETENESS OF DATA AND MATERIALS IN PSYCHOLOGICAL SCIENCE THAT WERE REPORTEDLY AVAILABLE AT OPEN ACCESS LOCATIONS BUT NOT AWARDED A BADGE.

## NOTE: THIS SCRIPT WILL AUTOMATICALLY IMPORT THE DATA FILE NECESSARY TO RUN THIS SCRIPT, "Master Dataset.csv," FROM THE OPEN SCIENCE FRAMEWORK (OSF).

## IF YOU WOULD PREFER TO MANUALLY DOWNLOAD THE DATA FILE TO YOUR MACHINE AND IMPORT INTO R, PLEASE:
## 1. DOWNLOAD "Master Dataset.csv" FROM THE OPEN SCIENCE FRAMEWORK: https://osf.io/a29bt/
## 2. DO NOT RUN LINE 14
## 3. MODIFY LINE 15 TO READ THE LOCATION OF THE FILE ON YOUR MACHINE.

# Import tables from OSF file "Master Dataset.csv"
metadata <- GET('https://osf.io/a29bt/?action=download', write_disk('Master Dataset.csv', overwrite = TRUE))
metadata <- as.data.frame(read.csv("Master Dataset.csv", header=T, sep=","))

# Remove any article IDs that are not from Psychological Science
PS_metadata <- subset(metadata, grepl(" PS", metadata$Article.ID.number))

# Remove any articles that are not empirical in nature (commentaries, corrigendum, corrections, editorials, etc.)
PS_empirical_metadata <- subset(PS_metadata, Number.of.experiments > 0)

########### COMPLETENESS: NO DATA BADGE ##############

# for loop to see within each year how many article received data badge and if they were found at their location
PS_openaccess_data <- subset(PS_empirical_metadata, Data.URL.links.to. %in% c("Independent archive / repository", "Personal site", "Third party site"))

# for loop to see within each year how many article received data badge and if they were found at their location
datacompleteness.results <- data.frame() #empty place to store results

for (year in (c(2012, 2013, 2014, 2015))){
  print(year) #make sure loop is working
  papers <- subset(PS_openaccess_data, grepl(year, PS_openaccess_data$Article.ID.number)) #subsetting papers by year
  papers <- subset(papers, papers[7] == "Yes")
  intm <- aggregate(Did.the.article.receive.a.badge.for.open.data.~Are.the.data.complete.,
                    data=papers, FUN=table) #of articles that had a data availability statement, are the data complete. FUN is for summary statistics
  result <- data.frame(year, Are.the.data.complete.=intm$Are.the.data.complete.  ,
                       intm$Did.the.article.receive.a.badge.for.open.data.) #build data frame with year and title, =intm$ recall and produce output
  datacompleteness.results <- rbind(datacompleteness.results, result) #combine results together
} #end of loop, signals to go back to next year
datacompleteness.results
sum(datacompleteness.results$No, datacompleteness.results$Yes) #double check to make sure all articles are included

#reorganize the R output
Dunorganized <- datacompleteness.results
Total <- rowSums(Dunorganized[,c("Yes", "No")])
withtotal <- cbind(Dunorganized, Total)
keeps <- c("year", "Are.the.data.complete.", "No") # Change to columns you want to keep
keepcolumns <- withtotal[keeps]
Completeness.NoDataBadge <- spread(keepcolumns, Are.the.data.complete., No)
Completeness.NoDataBadge[is.na(Completeness.NoDataBadge)] <- 0

colnames(Completeness.NoDataBadge)[2] <- "N/A" # Manual curation

# At this point you should have 6 columns
colnames(Completeness.NoDataBadge) #  puts out the order so you can rearrange
Completeness.NoDataBadge <- Completeness.NoDataBadge[c(1,5,6,4,3,2)] # Rearrange columns so they match the order you want
Before_badges <- colSums(Completeness.NoDataBadge[1:2, c(2,3,4,5,6)])
Before_badges <- c("2012-2013", Before_badges)
After_badges <- colSums(Completeness.NoDataBadge[3:4, c(2,3,4,5,6)])
After_badges <- c("2014-2015", After_badges)
Completeness.NoDataBadge <- rbind(Completeness.NoDataBadge, Before_badges, After_badges)

## Open dataframe "Completeness.NoDataBadge" for final output

########## COMPLETENESS: NO MATERIALS BADGE ##############

# for loop to see within each year how many article received data badge and if they were found at their location
PS_openaccess_materials <- subset(PS_empirical_metadata, Materials.URL.links.to. %in% c("Independent archive / repository", "Personal site", "Third party site"))

# for loop to see within each year how many article received materials badge and if they were found at their location
materialcompleteness.results <- data.frame()

for (year in (c(2012, 2013, 2014, 2015))){
  print(year) #make sure loop is working
  papers <- subset(PS_openaccess_materials, grepl(year, PS_openaccess_materials$Article.ID.number)) #subsetting papers by year
  papers <- subset(papers, papers[25] == "Yes")
  if (nrow(papers) > 0){
    intm <- aggregate(Did.the.article.receive.a.badge.for.open.materials.~Are.the.materials.complete.,
                      data=papers, FUN=table) #of articles that had a materials availability statement, are the materials complete. FUN is for summary statistics
    result <- data.frame(year, Are.the.materials.complete.=intm$Are.the.materials.complete.  ,
                         intm$Did.the.article.receive.a.badge.for.open.materials.) #build data frame with year and title, =intm$ recall and produce output
    materialcompleteness.results <- rbind(materialcompleteness.results, result) #combine results together
  }
} #end of loop, signals to go back to next year
materialcompleteness.results
sum(materialcompleteness.results$No, materialcompleteness.results$Yes) #double check to make sure all articles are included

#reorganize the R output
Munorganized <- materialcompleteness.results
Total <- rowSums(Munorganized[,c("Yes", "No")])
withtotal <- cbind(Munorganized, Total)
keeps <- c("year", "Are.the.materials.complete.", "No") # Change to columns you want to keep
keepcolumns <- withtotal[keeps]
Completeness.NoMaterialsBadge <- spread(keepcolumns, Are.the.materials.complete., No)
Completeness.NoMaterialsBadge[is.na(Completeness.NoMaterialsBadge)] <- 0

colnames(Completeness.NoMaterialsBadge)[2] <- "N/A" # Manual curation

# At this point you should have 6 columns
colnames(Completeness.NoMaterialsBadge) #  puts out the order so you can rearrange
Completeness.NoMaterialsBadge <- Completeness.NoMaterialsBadge[c(1,5,6,4,3,2)] # Rearrange columns so they match the order you want
Before_badges <- colSums(Completeness.NoMaterialsBadge[1:2, c(2,3,4,5,6)])
Before_badges <- c("2012-2013", Before_badges)
After_badges <- colSums(Completeness.NoMaterialsBadge[3:4, c(2,3,4,5,6)])
After_badges <- c("2014-2015", After_badges)
Completeness.NoMaterialsBadge <- rbind(Completeness.NoMaterialsBadge, Before_badges, After_badges)

## Open dataframe "Completeness.NoMaterialsBadge" for final output