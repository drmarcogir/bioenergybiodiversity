prop_rich <- function(indat) {
  # Loop through columns 
  for (i in 2:ncol(indat)) {
    # Subset column i
    tmpv <- indat[, i] %>%
      pull(1)
    # Set first non-zero values to NA i.e. using row number
    tmpv[which(tmpv != 0)[1]] <- NA
    # Set non-NA values to 0
    tmpv[!is.na(tmpv)] <- 0
    # Set NA values to 1
    tmpv[is.na(tmpv)] <- 1
    # Overwrite column of interest
    indat[, i] <- tmpv
  }
  
  # Calculate cumulative sums and proportions 
  res <- indat %>%
    mutate(rich = rowSums(indat[2:dim(indat)[2]])) %>%
    dplyr::select(bioen, rich) %>%
    mutate(richcum = cumsum(rich / 28133), bioen = cumsum(bioen))
  
  return(res)
}