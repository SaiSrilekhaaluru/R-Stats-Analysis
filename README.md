# COVID-19 Risk and Outcomes Analysis  

*Analyzing the impact of demographic, socioeconomic, and racial factors on COVID-19 risk and outcomes in U.S. counties*  

---

## Introduction  
The COVID-19 pandemic exposed critical health disparities across U.S. counties, disproportionately affecting communities with higher poverty rates and larger minority populations. This project investigates how **socioeconomic, racial, and demographic variables** influence COVID-19 deaths and health risk categorizations, offering evidence to guide public health interventions and equitable resource distribution.  

---

## Dataset  
The analysis uses the **COVID-19 Race, Gender, and Poverty Risk Dataset** (Kaggle), which integrates data from:  
- USA Facts  
- U.S. Census Bureau  
- CDC  
- Policy Map  

**Scope:**  
- 3,142 U.S. counties  
- 21 variables including poverty rate, racial and gender demographics, COVID-19 cases & deaths, and health risk indices  

---

## Methodology  
1. **Preprocessing**  
   - Removal of irrelevant variables and outliers  
   - Addressing multicollinearity between demographic groups  
   - Standardization of health and socioeconomic indicators  

2. **Statistical Analysis**  
   - Descriptive statistics to explore distributions of cases, deaths, and poverty rates  
   - Non-parametric tests (Kruskal-Wallis, Chi-Square) to evaluate differences across counties and categories  
   - Correlation analysis (Spearman’s Rank) to measure associations  

3. **Modeling**  
   - **Linear Regression** to quantify predictors of COVID-19 deaths  
   - **Logistic Regression** to classify counties into health risk categories  

---

##  Key Findings  
- **Socioeconomic disparities:** Strong positive correlation between poverty rates and COVID-19 mortality.  
- **Regression performance:**  
  - Linear regression explained **85%** of the variation in COVID-19 deaths.  
  - Logistic regression achieved **98.53% accuracy** in predicting county health risk categories.  
- **Disproportionate impact:** Counties with higher poverty and larger Black and Hispanic populations faced more severe outcomes.  
- **Geographic disparities:** Significant associations between risk categories and regions/states, reflecting unequal access to healthcare and resources.  

---

## Significance  
The study highlights how **poverty, race, and demographics** were central to pandemic vulnerability in the U.S. These findings reinforce the need for:  
- Targeted interventions for high-risk communities  
- Equitable distribution of healthcare resources  
- Policies that address underlying **social determinants of health**  

---

## Future Work  
- Expand models to include vaccination rates and comorbidities  
- Explore causal inference methods to move beyond correlation  
- Develop interactive dashboards to support policymakers with real-time insights  

---

## Author
**Sai Srilekha Aluru**  
MS Health Informatics | Pharm D  
📧 saisrilekhaaluru@gmail.com  
🔗 [LinkedIn](https://www.linkedin.com/in/sai-srilekha-aluru-60b156177/)  


