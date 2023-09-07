# Bioenergy Expansion and Post-2020 Biodiversity Conservation Targets

## Overview
This README provides an overview of the GitHub repository associated with the paper titled "XXX." The repository contains R and Python code related to the analysis and visualization of conflicts and synergies in biodiversity and bioenergy expansion.

## Repository Structure

The GitHub repository is organized to facilitate easy access to the code, data, and results produced during the research process. The main components of the repository include:

### 1. R Code
- **Folder Name:** `R`
- **Description:** This folder contains R scripts and associated data files used to generate figures and visualizations related to the analysis.

```
R/
├── functions/
│ ├── create_scenario_map.R
├── analysis.R
```


### 2. Python code (Jupyter Notebook)
- **Folder Name:** `notebooks`
- **Description:** This folder contains a Jupyter notebook (.ipynb) with Python code for calculating the Million hectares (Mha) of bioenergy within and outside protected areas in the most important biodiversity areas (top 17% and top 30% of pixels). These calculations were performed using the Google Earth Engine Python API.

```
├── notebooks/
│   └── analysis_notebook.ipynb
```

### 3. Figures
- **Folder Name:** `figures`
- **Description:** This folder contains figures produced with the R scripts.
```
├── figures/
│   ├── figure1.png
│   └── figure2.png
```

### 4. PDF Docs with Code Readability
- **Folder Name:** `pdf`
- **Description:** This folder contains PDF versions of the Jupyter notebooks and R Markdown documents used in the paper. These PDFs are provided for the convenience of reviewers and readers who may prefer a static, printable format for reviewing the code and results.
```
├── pdf/
│   ├── notebook1.pdf
│   └── notebook2.pdf
```

## How to Use the Repository, R Project, and Jupyter Notebook

To access the content of this repository, follow these steps:

1. **Clone the Repository:** You can clone the repository using the following command in your terminal or command prompt:
`git clone https://github.com/drmarcogir/bioenergybiodiversity.git`

2. **R Code:** The R code is structured in R project format. No relative paths need to be specified when reproducing the analyses. The `.Rproj` file can be used to open it.

3. **Jupyter Notebook:** The notebook can be run as a standalone notebook using Jupyter notebooks, Jupyter Lab, or similar tools. Note that the Python Earth Engine API should be installed. Alternatively, it can be imported into Google Colab (https://colab.research.google.com/) and run from there.
