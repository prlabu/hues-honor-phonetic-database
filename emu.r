# load the package
library(emuR)
library(dplyr)
library(ggplot2)



# create path to the data directory
data_dir = "~/Documents/data/hues-honor/wav-textgrids-comb"

# list files in the data directory
list.files(data_dir, recursive = F, full.names = F)



# convert TextGrid collection to the emuDB format
# convert_TextGridCollection(dir = data_dir,
#                            dbName = "hues-honor_new",
#                            targetDir = "~/Documents/data/hues-honor",
#                            tierNames = c("word", "phone"))





# the emuDB now lives within the data/hues-honor directory
path2db = file.path("~/Documents/data/hues-honor", "hues-honor_new_emuDB")

# load emuDB into current R session
# (verbose = F is only set to avoid additional output in manual)
honorDB_handle = load_emuDB(path2db, 
                       verbose = FALSE)



# show summary
summary(honorDB_handle)

# serve the emuDB to the EMU-webApp
# serve(honorDB_handle)





# query all segments containing the phone label UW1
sl_phoneUW = query(honorDB_handle,
               query = "[phone == UW1]")





# query all segments containing the phone label AE1
segList_AE = query(honorDB_handle,
                   query = "phone == AE1")

# get the right context (phone to the right) of each of the AE segments
AE_rightContext = requery_seq(honorDB_handle, segList_AE,
                           offset = 1,
                           ignoreOutOfBounds = TRUE)

# separate the AE segment list into prenasal and other
nasals = c('N', 'M', 'NG')
AE_N = segList_AE[ (AE_rightContext$labels %in% nasals), ]
AE_nonN = segList_AE[ !(AE_rightContext$labels %in% nasals), ]

# keep only vowels 2 minute into the interviews
AE_N = AE_N %>%
       filter(start < 120000)
AE_nonN = AE_nonN %>%
          filter(start < 120000)

# get the formants for these segments, 
# "forest" = just-in-time formant computation
AE_N_formants = get_trackdata(honorDB_handle, 
                     AE_N,
                     onTheFlyFunctionName = "forest")
AE_nonN_formants = get_trackdata(honorDB_handle, 
                                 AE_nonN,
                                 onTheFlyFunctionName = "forest")

# time normalize the formant values
AE_N_formants_norm = normalize_length(AE_N_formants)
AE_nonN_formants_norm = normalize_length(AE_nonN_formants)

# extract the temporal mid-points, taking formant measurements
AE_N_midpoints = AE_N_formants_norm %>% 
  filter(times_norm == 0.5) %>% filter(T1 != 0) %>% filter(T2 != 0)
AE_nonN_midpoints = AE_nonN_formants_norm %>% 
  filter(times_norm == 0.5)

# label the environments as a column in the dataframe
AE_N_midpoints$labelsAE = 'prenasal'
AE_nonN_midpoints$labelsAE = 'non-prenasal'

# combine prenasal and non-prenasal dataframes for plotting
AE_summary = rbind(AE_N_midpoints, AE_nonN_midpoints)

# get centroids of different environments
AE_centroid = AE_summary %>%
  group_by(labelsAE) %>%
  summarise(T1 = mean(T1), T2 = mean(T2))

# plot the prenasal and non-prenasal ellipses and their centroids
ggplot(AE_summary) +
  aes(x = T2, y = T1, label = labelsAE, col = labelsAE) +
  stat_ellipse() +
  scale_y_reverse() + scale_x_reverse() + 
  labs(x = "F2 (Hz)", y = "F1 (Hz)") +
  theme(legend.position = "none") +
  geom_text(data = AE_centroid)







# query food, bad, eat, odd
honor_vowels = query(emuDBhandle = honorDB_handle,
                  query = "[phone == UW1 | AE1 | IY1 | AA1 ]")

# keep only vowels 1 minute into the interviews
honor_vowels = honor_vowels %>%
  filter(start < 60000)

# get the formants for these segments, 
# "forest" = just-in-time formant computation
honor_formants = get_trackdata(honorDB_handle, 
                               honor_vowels,
                               onTheFlyFunctionName = "forest")





# time normalize the formant values
honor_vowels_norm = normalize_length(honor_formants)
# honor_vowels_norm = honor_formants

# extract the temporal mid-points
honor_midpoints = honor_vowels_norm %>% 
  filter(times_norm == 0.5)

honor_centroid = honor_midpoints %>%
  group_by(labels) %>%
  summarise(T1 = mean(T1), T2 = mean(T2))








# plot F1 & F2 values (== eplot(..., dopoints = T, doellipse = T, centroid = T, ...))
ggplot(honor_midpoints) +
  aes(x = T2, y = T1, label = labels, col = labels) +
  stat_ellipse() +
  scale_y_reverse() + scale_x_reverse() + 
  labs(x = "F2 (Hz)", y = "F1 (Hz)") +
  theme(legend.position = "none") +
  geom_text(data = honor_centroid)

