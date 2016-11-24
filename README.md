# Energy-and-Compliance
***Emma Heffernan & Devvart Poddar***

The repository is for the final data assignment for the course on **Collaborative Data Science** at [Hertie School of Governance](https://www.hertie-school.org/home/).

## About the Project

Rising electricity costs in developed nations has become the political topic du jour across OECD jurisdictions. The cost of electricity matters: the impact of rising electricity costs is felt most acutely by low-income individuals, who see a greater proportion of their pay checks directed towards their hydro bills. Given the economic difficulties caused by rising electricity prices, this is an ongoing topic of importance for academics and politicians alike.

We question whether *different degrees of judicial compliance with political regulations leads to different cost outcomes*. Our project will deal with measuring complicance through American commissioner court decisions to identify impact on residential electricty pricing.

### Assignment 3 Files
**Note:** The Rmd file as well as the pdf for assignment 3 is located in the folder "Data and Methodolgy".

### Running Knitr

The pdf otputs were createred using **KnitR** and **Rmarkdown** on R. In order to install the package please run the following commands.

```
install.packages(c("knitr", "rmarkdown"))
```

**NOTE:** There are several other packages which our also utilised and should be installed (Please look at the source file for a complete list of packages called ```pkgs```). The code uses the command ```require()``` which is a wrapper around ```library()``` . It does not stop the execution of the script if the package is not installed.


Once installed, please open the RMD file to create the pdf. You can use the functionality provided in Rstudio, or run the following command in R.

```
rmarkdown::render("Data.Rmd")
```

**NOTE:** Our analysis uses webscraping of multiple pdf and doc files.Due to the sheer size of the documents we could not upload them online. In order to run the document in its entirety please **uncomment line 31** in the Data.Rmd file. The entire .Rmd file takes arond 40~45 minutes in a weak Linux machine.


## TODO:

- [x] Download residential prices and covariates for regression
- [x] Identify Commissioner court website archives and scrape court rulings
- [ ] Indentify measure of compliance.
- [ ] Visualise!
