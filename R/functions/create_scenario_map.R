create_scenario_map <- function(scenario) {
  # Read richness raster
  rich_file <- paste0("./data/RCP19_", scenario, "_2050_bio_RICHNESS_cropped.tif")
  rich <- rast(rich_file) %>%
    project(targetr)
  
  # Read bioenergy raster
  bioen_file <- paste0("./data/RCP19_", scenario, "_2050_bio_cropped.tif")
  bioen <- rast(bioen_file) %>%
    project(targetr)
  
  # Convert to data frame and filter
  tmp <- as.data.frame(rich, xy = TRUE) %>%
    as_tibble() %>%
    rename(rich = 3) %>%
    inner_join(as.data.frame(bioen, xy = TRUE) %>%
                 rename(bioen = 3)) %>%
    filter(bioen > 0) %>%
    as_tibble()
  
  # Bivariate class creation
  tmp %>%
    mutate(tmprich = as.numeric(cut(rich,quantile(rich,p=c(0,0.70,0.83,1)),include.lowest=T)),
           tmpbioen = as.numeric(cut(bioen,quantile(bioen,p=c(0,0.33,0.67,1)),include.lowest=T))) %>%
    mutate(bi_class = paste0(tmprich,"-",tmpbioen)) %>%
    inner_join(tibble(bi_class=factor(c("1-1","1-2","1-3","2-1","2-2","2-3","3-1","3-2","3-3"),
                                      levels = c("1-1","1-2","1-3","2-1","2-2","2-3","3-1","3-2","3-3"))) %>%
                 mutate(fill = c("#cce8d7","#80c39b","#008837","#cedced","#85a8d0","#0a50a1","#fbb4d9","#f668b3","#d60066")) %>%
                 mutate(bi_classf = bi_class)) ->dat2
  
  # Create the map of synergies and conflicts
  map <- dat2 %>%
    ggplot() +
    theme(legend.position = "none",
          plot.background = element_rect(fill = 'black'),
          panel.background = element_rect(fill = 'black', color = "black"),
          panel.border = element_rect(colour = "black", fill = NA),
          strip.text = element_text(size = rel(2.5), face = "bold"),
          axis.text = element_blank(), axis.ticks = element_blank(),
          panel.grid.major = element_line(colour = 'transparent')) +
    geom_sf(data = worldr, color = 'white', fill = 'grey40', size = 0.1) +
    geom_tile(aes(x = x, y = y, fill = bi_classf)) +
    scale_fill_manual(values = c("#cce8d7", "#80c39b", "#008837", "#cedced", "#85a8d0", "#0a50a1", "#fbb4d9",
                                 "#f668b3", "#d60066")) +
    xlab("") + ylab("") +
    coord_sf(crs = rob, xlim = c(-12808078, 16927051), ylim = c(-5930924, 8342353))
  
  # Create the legend
  mypal <- brewer.qualseq(9)
  mypal1 <- c(mypal[1], mypal[4], mypal[7], mypal[2], mypal[5], mypal[8], mypal[3], mypal[6], mypal[9])
  
  legend <- tibble(bi_class = factor(c("1-1", "1-2", "1-3", "2-1", "2-2", "2-3", "3-1", "3-2", "3-3"),
                                     levels = c("1-1", "1-2", "1-3", "2-1", "2-2", "2-3", "3-1", "3-2", "3-3"))) %>%
    mutate(fill = c("#cce8d7", "#80c39b", "#008837", "#cedced", "#85a8d0", "#0a50a1", "#fbb4d9", "#f668b3", "#d60066")) %>%
    mutate(bi_class1 = bi_class) %>%
    separate(bi_class, into = c("gini", "mean"), sep = "-") %>%
    mutate(gini = as.integer(gini), mean = as.integer(mean)) %>%
    ggplot() +
    geom_tile(mapping = aes(x = gini, y = mean, fill = mypal1)) +
    scale_fill_identity() +
    labs(x = "Biodiversity ⟶️", y = "Bioenergy ⟶️") +
    theme(panel.background = element_rect(fill = 'black'), panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
          panel.border = element_blank(), axis.text.x = element_blank(), axis.ticks.x = element_blank(),
          axis.text.y = element_blank(), axis.ticks.y = element_blank(),
          axis.title = element_text(size = 10, colour = "white", face = "bold"),
          plot.background = element_rect(fill = 'black')) +
    coord_fixed()
  
  # Combine map and legend
  finalplot <- ggdraw() + draw_plot(map, 0, 0, 1, 1) + draw_plot(legend, 0.01, 0.1, 0.15, 0.3)
  
  # Save the file
  fileout <- paste0("./figures/", scenario, "_bioen.png")
  png(fileout, width = 4000, height = 2000, res = 400)
  pushViewport(viewport(layout = grid.layout(1, 1)))
  print(finalplot, vp = viewport(layout.pos.row = 1, layout.pos.col = 1))
  dev.off()
}

