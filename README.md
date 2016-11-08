# Energy-and-Compliance

The repository is for the final data assignment for the course on **Collaborative Data Science** at [Hertie School of Governance](https://www.hertie-school.org/home/). 

## About the Project

Rising electricity costs in developed nations has become the political topic du jour across OECD jurisdictions. The cost of electricity matters: the impact of rising electricity costs is felt most acutely by low-income individuals, who see a greater proportion of their pay checks directed towards their hydro bills. Given the economic difficulties caused by rising electricity prices, this is an ongoing topic of importance for academics and politicians alike.

We question whether *different degrees of judicial compliance with political regulations leads to different cost outcomes*. Our project will deal with measuring complicance through American commissioner court decisions to identify impact on residential electricty pricing. 

### Running Knitr

The pdf otputs were createred using **KnitR** and **Rmarkdown** on R. In order to install the pckage please run the following commands.

```
install.packages(c("knitr", "rmarkdown"))
```

Once installed, please open the RMD file to create the pdf. You can use the functionality provided in Rstudio, or run the following command in R.

```
rmarkdown::render("Literature Review.Rmd")
```

## TODO:

- [ ] Download residential prices and covariates for regression
- [ ] Identify Commissioner court website archives and scrape court rulings
- [ ] Indentify measure of compliance.
- [ ] Visualise!
