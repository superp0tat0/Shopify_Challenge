# Outliers Detection Dashboard

**Link**: [https://superp0tat0.shinyapps.io/shopify_shiny/](https://superp0tat0.shinyapps.io/shopify_shiny/)

**Report**: [Final Report](https://github.com/superp0tat0/Shopify_Challenge/blob/master/Shopify%202022%20Winter%20Challenge.pdf)

**The above link only has 25 hours usage. But this repo was up to date so feel free to build the app locally.**

![demo_shiny](https://raw.githubusercontent.com/superp0tat0/superp0tat0.github.io/master/files_posts/project_shiny.png)

## Backgrounds

Hey, this is Luke. 

I did this project with the engagement of my daily work at Bayer and one data scienctist challenge from Shopify. To demonstrate the importance of the reusability for data science project. I implement this dashboad and would like to share my belief.

## Motivations

I am a believer that data analysis should be a simple skill just as breathing for everyone. Moreover, data scientists should deliver solution instead of reports to their stakeholders with minimum education required.
This dashboard could replace a whole data analysis project about outliers detection. In another word, anyone could use this dashboard to do a data analysis, detect the outliers and made conclusions with in 5 mins. Also the dashboard is interactive and it is so simple, that you should able to work with it with little introduction.

## Object

Assume there are some Shopify sneaker shops are generating transactions data. However, one of the metric, Averge Order Value (AOV) is too high with 3156.54$. The question is asking the candidates why this is the case and how could you come up the better metrics, and the reasons to choose those metrics.

## Panel Functions

**Summary Panel**

The first panel contains an interactive histogram plot with X axis to be the time stamp and the Y axis to be the sales amount. But here we could see there are some outliers that are pushing the box to X axis. You could apply the filter on the left to remove certain outliers. For example, from the plot we could see `Shop ID` 42 is an outlier.

* Try `exclude shop id 42` using `Exclude Shop ID` Box

![](https://raw.githubusercontent.com/superp0tat0/Shopify_Challenge/master/images/panel1.png)

**Trend Panel**

The second panel highlight the trend of each transaction by different shop and users. However, it no longer support too many transactions since the computational resouce limitations. You could also use the panel on the left to filter the transactions you want to see. 

* Try set `User ID` to 607 and `Shop ID` to 42.

![](https://raw.githubusercontent.com/superp0tat0/Shopify_Challenge/master/images/panel2.png)

**Statistics Panel**

The third panel contains some interesting metrics and the time series plot for the average value for per order and average value per item for each day. For the left bottom corner you could see how those metrics behave with the exclusion of outliers. And for the left top corner you could see all the transactions after filtering.

* Try `exclude shop id 42` using `Exclude Shop ID` Box

![](https://raw.githubusercontent.com/superp0tat0/Shopify_Challenge/master/images/panel3.png)


## Future Plan

About the implementation, I designed it using different modules so it should be ablt to fit your needs very easily.

Other than that, please give it a star if you like it or it helps your project somehow. If you think there could be some improvements can be done, please open an issue ticket or create a pull request.
