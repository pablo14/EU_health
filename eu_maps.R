suppressPackageStartupMessages(library(googleVis))
library(plyr)
library(knitr)
library(markdown)

## Read data (this data has already some data preparation)
data=read.delim("data.txt", header=TRUE)

## Get country cod-name to translate abbreviations
country_name_abb=read.csv("country_name_abb.txt", header=TRUE)
data=merge(data, country_name_abb, by="Country", all.x =T)

## Get clean Country variable
data$Country=data$Name


## Calculate average to consider both genders
data_avg_all=ddply(data, c("Variable", "Country"), .fun = function(d)
  c(
    "age_mean" = round(mean(d[,"X2012"],na.rm=TRUE),2)
  ))


## Generating final data frame to analyze.
data_hea_lif=subset(data_avg_all, Variable=="Healthy life years")
names(data_hea_lif)[3]="Healthy_Life"

data_lif_exp=subset(data_avg_all, Variable=="Life expectancy")
names(data_lif_exp)[3]="Life_Expectancy"

data_merged=merge(data_hea_lif, data_lif_exp, by="Country")

## Computing the "age gap"
data_merged$age_gap=data_merged$Life_Expectancy-data_merged$Healthy_Life


## Map building. Pretty easy with google viz!
## Map 1
map_1<<-gvisGeoChart(data_merged, locationvar="Country", 
                     colorvar="Life_Expectancy",
                     options=list(
                       projection="kavrayskiy-vii", 
                       title="aaa", 
                       region="150"
                       #colors="['#E6E6F5', '#00006B']"  
                     ))

## Map 2
map_2<<-gvisGeoChart(data_merged, locationvar="Country", 
                     colorvar="Healthy_Life",
                     options=list(
                       projection="kavrayskiy-vii", 
                       title="aaa", 
                       region="150"
                       #colors="['#E6E6F5', '#00006B']"  
                     ))


map_1_2 <<- gvisMerge(map_1, map_2, horizontal=TRUE) 
#plot(map_1_2)


## Map 3: GAP
map_3<<-gvisGeoChart(data_merged, locationvar="Country", 
                             colorvar="age_gap",
                             options=list(
                               projection="kavrayskiy-vii", 
                               region="150",
                               colors="['#00853f', '#e31b23']"  
                               ))

#####################################
## Top 3 countries (healty and expectancy)
######################################


## Order data for both variables, and keeping the highest top 3
top3_hea_lif=head(data_merged[order(data_merged$Healthy_Life, decreasing=c(T)),],3) 
top3_lif_exp=head(data_merged[order(data_merged$Life_Expectancy, decreasing=c(T)),],3) 

## Tables building
table_top3_hea_lif <<- gvisTable(top3_hea_lif[,c("Country","Healthy_Life" )])
table_top3_lif_exp <<- gvisTable(top3_lif_exp[,c("Country","Life_Expectancy" )])

tables_top3 <<- gvisMerge(table_top3_hea_lif, table_top3_lif_exp, horizontal=TRUE) 

#####################################
## Top 3 countries (gap)
######################################
## Order data for both variables, and keeping the highest top 3
top3_highest_gap=head(data_merged[order(data_merged$age_gap, decreasing=c(T)),],3) 
top3_lowest_exp=head(data_merged[order(data_merged$age_gap),],3) 

## Tables building
table_top3_gap_hi <<- gvisTable(top3_highest_gap[,c("Country","age_gap" )])
table_top3_gap_lo <<- gvisTable(top3_lowest_exp[,c("Country","age_gap" )])

tables_top3_gap <<- gvisMerge(table_top3_gap_hi, table_top3_gap_lo, horizontal=TRUE) 


#knit("output.Rmd",encoding="UTF-8")
#markdownToHTML("output.md", "EU Geo Report.html")
