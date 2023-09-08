# Bioenergy Expansion and Post-2020 Biodiversity Conservation Targets

## Overview
This README provides an overview of the GitHub repository associated with the paper titled "XXX." The repository contains R and Python code related to the analysis and visualization of conflicts and synergies in biodiversity and bioenergy expansion.

## Repository Structure

The GitHub repository is organized to facilitate easy access to the code, data, and results produced during the research process. The main components of the repository include:

### 1. Data
- **Folder Name:** `data`
- **Description:** This folder contains the data files needed to run the R code.

```
data/
├── backgroundmap/
│   └── countries.gpkg
├── csv/
│   └── speciesdat.zip
└── rasters/
    ├── RCP19_SSP1_2050_bio_cropped.tif
    ├── RCP19_SSP1_2050_bio_RICHNESS_cropped.tif
    ├── RCP19_SSP1_2050_bio.tif
    ├── RCP19_SSP2_2050_bio_cropped.tif
    ├── RCP19_SSP2_2050_bio_RICHNESS_cropped.tif
    ├── RCP19_SSP2_2050_bio.tif
    ├── RCP19_SSP5_2050_bio_cropped.tif
    ├── RCP19_SSP5_2050_bio_RICHNESS_cropped.tif
    └── RCP19_SSP5_2050_bio.tif
```

### 2. R Code
- **Folder Name:** `R`
- **Description:** This folder contains R scripts used to generate figures and visualizations related to the analysis.

```
R/
├── analysis.R
├── analysis.Rmd
└── functions/
    ├── create_scenario_map.R
    └── range_loss.R
```


### 3. Python code (Jupyter Notebook)
- **Folder Name:** `notebooks`
- **Description:** This folder contains a Jupyter notebook (.ipynb) with Python code for calculating the Million hectares (Mha) of bioenergy within and outside protected areas in the most important biodiversity areas (top 17% and top 30% of pixels). These calculations were performed using the Google Earth Engine Python API.

```
notebooks/
└── PA_GEE.ipynb
```

### 4. Figures
- **Folder Name:** `figures`
- **Description:** This folder contains figures produced with the R scripts.
```
figures/
├── curves/
│   ├── rangeloss_curve.png
│   └── prop_species_lost.png
└── maps/
    ├── SSP1_bivariate.png
    ├── SSP2_bivariate.png
    └── SSP5_bivariate.png
```

### 5. PDF Docs with Code Readability
- **Folder Name:** `pdf`
- **Description:** This folder contains PDF versions of the Jupyter notebooks and R Markdown documents used in the paper. These PDFs are provided for the convenience of reviewers and readers who may prefer a static, printable format for reviewing the code and results.
```
pdf/
├── analysis.pdf
└── PA_GEE.pdf
```

## How to Use the Repository, R Project, and Jupyter Notebook

To access the content of this repository, follow these steps:

1. **Clone the Repository:** You can clone the repository using the following command in your terminal or command prompt:
`git clone https://github.com/drmarcogir/bioenergybiodiversity.git`

2. **R Code:** The R code is structured in R project format. No relative paths need to be specified when reproducing the analyses. The `.Rproj` file can be used to open it.

3. **Jupyter Notebook:** The notebook can be run as a standalone notebook using Jupyter notebooks, Jupyter Lab, or similar tools. Note that the Python Earth Engine API should be installed. Alternatively, it can be imported into Google Colab (https://colab.research.google.com/) and run from there.
