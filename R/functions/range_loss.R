process_raster_data <- function(file_path, scenario,dat) {
  # Read raster data
  raster_data <- rast(file_path) %>%
    as.data.frame(xy = TRUE) %>%
    as_tibble() %>%
    rename(bioen = tmp)
  
  # Inner join with species data
  raster_data <- raster_data %>%
    inner_join(dat) %>%
    select(-c(x, y))
  
  # Arrange data by bioenergy values in descending order
  combined <- raster_data %>%
    arrange(desc(bioen))
  
  # Calculate 'biodiv' and 'biodiv_sum'
  combined_cumsum <- combined %>%
    mutate(biodiv_cumsum = cumsum(rowSums(.[2:ncol(.)]))) %>%
    mutate(biodiv_rowsum = rowSums(combined[2:ncol(combined)]))  # Use 'combined' here
  
  # Select and calculate 'bioen' as cumulative sum
  finalres <- combined_cumsum %>%
    select(bioen, biodiv_cumsum, biodiv_rowsum) %>%
    mutate(bioen = cumsum(bioen))
  
  finalres$scenario<-scenario
  
  return(finalres)
}




