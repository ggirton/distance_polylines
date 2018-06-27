# distance_polylines 
#   Write .pln line file from distance table of lat/long coordinates

# install.packages("tidyverse")
# install.packages("readxl")
# install.packages("glue")

library(tidyverse)
library(readxl)
library(glue)

# Rudimentary read the distance table file ------
distance_table <- read_excel("HarborGarden-to-WF.xlsx")

# Just keep the indicated fields -------
distances <- distance_table %>% 
  transmute(key = `key_from:From key`, 
            k_to = `key_to:To key`,
            location_name = `name_from:From name`,
            name = `name_to:To name`,
            from_lat = round(`lat_from:From latitude (NAD83)`,6),
            from_long = round(`lng_from:From longitude (NAD83)`,6),
            to_lat = round(`lat_to:To latitude (NAD83)`,6),
            to_long = round(`lng_to:To longitude (NAD83)`,6),
            distance = `dist_mi:Distance (miles)`) %>%
  arrange(k_to) 

length(unique(distances$key)) == 1   ## By convention, we are doing only one of these at a time
length(unique(distances$k_to)) == 7  ## check to see if it matches the number of distance lines, in this case 7

# View(distances)    # Check it out!


# Form output polyline text file lines ------------------------------------

distances$writeline <- 
  glue('\n\n{distances$key} "{round(distances$distance,2)} miles"\n<1>{distances$from_lat} {distances$from_long},{distances$to_lat} {distances$to_long}')

# Put it all in one string (might not work with a ton of tons of locations)
outputlines <- glue::collapse(distances$writeline)


# Output to file ----------------------------------------------------------

outputname <- c("spidergram.pln")
write_file("{NAD83}",outputname)  # This is the header
write_file(outputlines,outputname, append = TRUE)   #This is the rest of the file

# That's all, folks! -------


# Reference: Write a file that looks (sans '#' comments) like this: --------------------------------------

# {NAD83}
# Line0001 "Line 0001"
# <1>33.77279 117.92135,33.73294 117.99030
# Line0002 "Line 0002"
# <1>33.77077 117.92018,33.62331 117.87298
# Line0003 "Line 0003"
# <1>33.77331 117.91712,33.70163 117.82585
# Line0004 "Line 0004"
# <1>33.77637 117.91953,33.66628 117.75566
# Line0005 "Line 0005"
# <1>33.78040 117.92383,33.90514 117.85065

