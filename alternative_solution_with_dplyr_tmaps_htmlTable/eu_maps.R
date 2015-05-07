library(magrittr)
library(knitr)
library(markdown)
library(dplyr)
library(tmap)
library(ISOcodes)
library(htmlTable)

## Read data (this data has already some data preparation)
data=read.delim("data.txt", header=TRUE)

data("ISO_3166_1") # countrycodes
data("Europe")

ISO_3166_1 %<>% transmute(  iso_a2 = Alpha_2, iso_a3 = Alpha_3, Country = Name)
data %<>% mutate( iso_a2 = Country) %>% select(-Country)

data %<>% left_join(ISO_3166_1, by= "iso_a2")

data_hea_lif <- data %>% filter(Variable == "Healthy life years") %>% 
      group_by(Country) %>% summarise(Healthy_life=mean(X2012))

data_lif_exp <- data %>% filter(Variable == "Life expectancy") %>% 
  group_by(Country) %>% summarise(Life_Expectancy=mean(X2012))

data_merged <- left_join(data_hea_lif, data_lif_exp, by="Country") %>% mutate(age_gap=Life_Expectancy-Healthy_life) %>% 
  filter(Country != "NA")

Europe@data  %>% left_join(ISO_3166_1, by="iso_a3") %>% left_join(data_merged, by="Country") -> Europe@data

map_1<- tm_shape(Europe) +
  tm_fill("Healthy_life", textNA="NA") +
  tm_borders() +
  tm_text("iso_a3", cex="AREA", root=5) + 
  tm_layout_Europe("Healthy life years")


map_2 <- tm_shape(Europe) +
  tm_fill("Life_Expectancy", textNA="NA") +
  tm_borders() +
  tm_text("iso_a3", cex="AREA", root=5) + 
  tm_layout_Europe("Life expectancy")

map_3 <- tm_shape(Europe) +
  tm_fill("age_gap", textNA="NA") +
  tm_borders() +
  tm_text("iso_a3", cex="AREA", root=5) + 
  tm_layout_Europe("Age gap")



# #####################################
# ## Top 3 countries (healty and expectancy)
# ######################################

top3_hea_lif <- data_merged %>% arrange(desc(Healthy_life)) %>% select(Country, Healthy_life) %>% head(3)
top3_lif_exp <- data_merged %>% arrange(desc(Life_Expectancy)) %>% select(Country, Life_Expectancy) %>% head(3)
tables_top3 <- bind_cols(top3_hea_lif,top3_lif_exp)

# #####################################
# ## Top 3 countries (gap)
# ######################################
# ## Order data for both variables, and keeping the highest top 3

top3_highest_gap <- data_merged %>% arrange(desc(age_gap) ) %>% head(3)
top3_lowest_exp <- data_merged %>% arrange(desc(age_gap) ) %>% tail(3)
tables_top3_gap <- bind_cols(top3_highest_gap,top3_lowest_exp)

#knit("output.Rmd",encoding="UTF-8")
#markdownToHTML("output.md", "EU Geo Report.html")
