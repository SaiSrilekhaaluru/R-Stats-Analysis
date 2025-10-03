# Load necessary libraries
library(dplyr)
library(ggplot2)
library(caret)
library(pheatmap)

# Load dataset
file_path <- ("/Users/sathviksai/Downloads/archive-3/covid_data_log_200908.csv")
covid_data <- read.csv(file_path)

colSums(is.na(covid_data)) #mising values

head(covid_data) #View the first few rows

#-------------------------------------------------------------------------------
##BOX PLOT BEFORE OUTLIERS
# Identify numeric (continuous) variables automatically
continuous_vars <- covid_data %>%
  select_if(is.numeric)

# View the column names of continuous variables
colnames(continuous_vars)

# Select only numeric continuous columns
continuous_vars <- covid_data %>%
  select(Cases, Deaths, Poverty, Population, 
         W_Male, W_Female, B_Male, B_Female, 
         I_Male, I_Female, A_Male, A_Female, 
         NH_Male, NH_Female)

# Reshape data to long format
continuous_long <- continuous_vars %>%
  pivot_longer(cols = everything(), names_to = "Variable", values_to = "Value")

# Plot boxplots for each continuous variable
ggplot(continuous_long, aes(x = Variable, y = Value)) +
  geom_boxplot(fill = "steelblue", color = "black", outlier.color = "red", outlier.shape = 16) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  labs(title = "Boxplots of Continuous Variables", x = "Variables", y = "Values")

#-------------------------------------------------------------------------------
##OUTLIER REMOVAL

# Identify continuous variables (numeric columns)
continuous_vars <- covid_data %>% 
  select_if(is.numeric)

# Function to remove outliers using the IQR method
remove_outliers <- function(data, column) {
  Q1 <- quantile(data[[column]], 0.25, na.rm = TRUE)  # 1st Quartile
  Q3 <- quantile(data[[column]], 0.75, na.rm = TRUE)  # 3rd Quartile
  IQR <- Q3 - Q1  # Interquartile Range
  
  # Define lower and upper bounds
  lower_bound <- Q1 - 1.5 * IQR
  upper_bound <- Q3 + 1.5 * IQR
  
  # Filter data to exclude outliers
  data <- data %>%
    filter(data[[column]] >= lower_bound & data[[column]] <= upper_bound)
  return(data)
}

# Create a copy of the original dataset
filtered_data <- covid_data

# Loop through each continuous variable and remove outliers
for (col in colnames(continuous_vars)) {
  filtered_data <- remove_outliers(filtered_data, col)
}

# View the filtered dataset
print(filtered_data)

# Check the number of rows before and after outlier removal
cat("Original rows:", nrow(covid_data), "\n")    #3142 
cat("Filtered rows:", nrow(filtered_data), "\n") #2740 

#-------------------------------------------------------------------------------
##BOX PLOT AFTER OUTLIER REMOVAL USING IQR method
# Identify numeric (continuous) variables automatically
filtered_continuous_vars <- filtered_data %>%
  select_if(is.numeric)

# View the column names of continuous variables
colnames(filtered_continuous_vars)

# Select only numeric continuous columns 
filtered_continuous_vars <- filtered_data %>% 
  select(Cases, Deaths, Poverty, Population, 
         W_Male, W_Female, B_Male, B_Female, 
         I_Male, I_Female, A_Male, A_Female, 
         NH_Male, NH_Female)

# Reshape data to long format
filtered_continuous_long <- filtered_continuous_vars %>%
  pivot_longer(cols = everything(), names_to = "Variable", values_to = "Value")

# Plot boxplots for each continuous variable
ggplot(filtered_continuous_long, aes(x = Variable, y = Value)) +
  geom_boxplot(fill = "steelblue", color = "black", outlier.color = "red", outlier.shape = 16) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  labs(title = "Boxplots of filtered Continuous Variables", x = "Variables", y = "Values")

#-------------------------------------------------------------------------------
##REGRESSION MODEL-1: Cases as the dependent variable.
#Correlation check
filtered_continuous_vars <- filtered_data %>% 
  select(Cases, Poverty, Population, 
         W_Male, W_Female, B_Male, B_Female, 
         I_Male, I_Female, A_Male, A_Female, 
         NH_Male, NH_Female)

# Calculate Correlation Matrix
cor_matrix <- cor(filtered_continuous_vars, use = "complete.obs")

# Print the correlation matrix
print(cor_matrix)

# Step 3: Define custom breaks for the color gradient
breaks <- c(-1, -0.55, 0, 0.75, 0.85, 1)

# Create custom color palette
custom_colors <- colorRampPalette(c("white", "darkblue", "blue", "red", "darkred"))(length(breaks) - 1)

# Step 4: Visualize Correlation Matrix as a Heatmap
pheatmap(cor_matrix, 
         color = custom_colors, 
         breaks = breaks,  
         main = "Correlation Heatmap before correction",
         display_numbers = FALSE, 
         fontsize_number = 8)

#CORRECTION OF CORRELATION: Aggregate racial populations
Aggregated_filtered_data <- filtered_data %>%
  mutate(
    W_Total = W_Male + W_Female,  # White total population
    B_Total = B_Male + B_Female,  # Black total population
    A_Total = A_Male + A_Female,  # Asian total population
    I_Total = I_Male + I_Female,  # American Indian total population
    NH_Total = NH_Male + NH_Female # Native Hawaiian total population
  )

# View the first few rows to verify the aggregation
head(Aggregated_filtered_data)

#Select relevant continuous variables for correlation analysis**
# We exclude W_Male, W_Female, B_Male, B_Female, etc., since we now have aggregated totals
##model_1, predicting cases
correlation_vars <- Aggregated_filtered_data %>%
  select(Poverty, Deaths, Risk_Index,
         W_Total, B_Total, A_Total, I_Total, 
         NH_Total)

# **Step 3: Compute correlation matrix**
cor_matrix <- cor(correlation_vars, use = "complete.obs")

# Print the correlation matrix to view the results
print(cor_matrix)

# Step 3: Define custom breaks for the color gradient
breaks <- c(-1, -0.55, 0, 0.75, 0.85, 1)

# Create custom color palette
custom_colors <- colorRampPalette(c("white", "darkblue", "blue", "red", "darkred"))(length(breaks) - 1)

# Step 4: Visualize Correlation Matrix as a Heatmap
pheatmap(cor_matrix, 
         color = custom_colors, 
         breaks = breaks,  
         main = "Custom Correlation Heatmap",
         display_numbers = FALSE, 
         fontsize_number = 8)

------------------------------------------------------------------
#Regression Model (Cases as Dependent Variable)
# Define the independent variables and dependent variable
regression_vars <- Aggregated_filtered_data %>%
  select(Deaths, 
         Poverty, Cases, Risk_Index, 
         W_Total, B_Total, A_Total, I_Total, 
         NH_Total)

# Fit the linear regression model
regression_model <- lm(Deaths ~ Poverty + Cases + Risk_Index + 
                         W_Total + B_Total + A_Total + I_Total + NH_Total, 
                       data = Aggregated_filtered_data)

# View the model summary
summary(regression_model)

##Diagnostics and Assumption Checks
# 1. Residuals vs Fitted Plot
ggplot(data.frame(Fitted = fitted(regression_model), Residuals = residuals(regression_model)), 
       aes(x = Fitted, y = Residuals)) +
  geom_point(color = "black", alpha = 0.6) +
  geom_hline(yintercept = 0, color = "red", linetype = "dashed") +
  labs(title = "Residuals vs Fitted Plot", x = "Fitted Values", y = "Residuals") +
  theme_minimal()

# 2. Q-Q Plot to check normality of residuals
qqnorm(residuals(regression_model))
qqline(residuals(regression_model), col = "red")

# 3. Scale-Location Plot
ggplot(data.frame(Fitted = fitted(regression_model), 
                  Scaled = sqrt(abs(residuals(regression_model)))), 
       aes(x = Fitted, y = Scaled)) +
  geom_point(color = "black", alpha = 0.6) +
  geom_smooth(se = FALSE, color = "red") +
  labs(title = "Scale-Location Plot", x = "Fitted Values", y = "√|Residuals|") +
  theme_minimal()

# 4. Residuals vs Leverage
leverage <- hatvalues(regression_model)
cook <- cooks.distance(regression_model)

ggplot(data.frame(Leverage = leverage, Residuals = residuals(regression_model), Cook = cook),
       aes(x = Leverage, y = Residuals, size = Cook)) +
  geom_point(color = "black", alpha = 0.6) +
  geom_hline(yintercept = 0, color = "red", linetype = "dashed") +
  labs(title = "Residuals vs Leverage", x = "Leverage", y = "Residuals") +
  theme_minimal()

## Evaluate Model Performance
# Calculate Root Mean Squared Error (RMSE)
predicted_values <- predict(regression_model, Aggregated_filtered_data)
rmse <- sqrt(mean((Aggregated_filtered_data$Cases - predicted_values)^2))
cat("Root Mean Squared Error (RMSE):", rmse, "\n")

# Calculate R-squared and Adjusted R-squared
rsq <- summary(regression_model)$r.squared
adj_rsq <- summary(regression_model)$adj.r.squared
cat("R-squared:", rsq, "\n")
cat("Adjusted R-squared:", adj_rsq, "\n")


#------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
##CLASSIFICATION MODEL-3: Risk Category (Risk_Cat) as the dependent variable


## Load Required Libraries
library(dplyr)
library(ggplot2)
library(caret)  # For train/test split, confusion matrix
library(nnet)   # For multinomial logistic regression (if needed)
library(pROC)   # For ROC curve


## Step 1: Aggregate Racial Populations
Aggregated_filtered_data <- filtered_data %>%
  mutate(
    W_Total = W_Male + W_Female,  # White total population
    B_Total = B_Male + B_Female,  # Black total population
    A_Total = A_Male + A_Female,  # Asian total population
    I_Total = I_Male + I_Female,  # American Indian total population
    NH_Total = NH_Male + NH_Female # Native Hawaiian total population
  )

# Remove old disaggregated racial population columns
Aggregated_filtered_data <- Aggregated_filtered_data %>%
  select(-W_Male, -W_Female, -B_Male, -B_Female, 
         -A_Male, -A_Female, -I_Male, -I_Female, 
         -NH_Male, -NH_Female)

# Ensure Risk_Cat is a factor (since it is a classification target)
Aggregated_filtered_data$Risk_Cat <- as.factor(Aggregated_filtered_data$Risk_Cat)

# View the first few rows to verify
head(Aggregated_filtered_data)


## Step 2: Split the Data into Training and Testing Sets (80-20 split)
set.seed(123)  # For reproducibility
train_index <- createDataPartition(Aggregated_filtered_data$Risk_Cat, p = 0.8, list = FALSE)
train_data <- Aggregated_filtered_data[train_index, ]
test_data <- Aggregated_filtered_data[-train_index, ]

# Check the distribution of Risk_Cat in train and test
table(train_data$Risk_Cat)
table(test_data$Risk_Cat)

## Step 3: Fit the Classification Model (Logistic Regression or Multinomial Logistic Regression)
# If binary classification (e.g., "Low" vs "High"), use glm()
if (length(unique(Aggregated_filtered_data$Risk_Cat)) == 2) {
  logistic_model <- glm(Risk_Cat ~ Poverty + Cases + Deaths + Risk_Index + 
                          W_Total + B_Total + A_Total + I_Total + NH_Total, 
                        data = train_data, family = binomial(link = "logit"))
} else {
  # Multinomial logistic regression for multi-class classification
  multinomial_model <- multinom(Risk_Cat ~ Poverty + Cases + Deaths + Risk_Index + 
                                  W_Total + B_Total + A_Total + I_Total + NH_Total, 
                                data = train_data)
}

# View model summary
if (exists("logistic_model")) {
  summary(logistic_model)
} else {
  summary(multinomial_model)
}


## Step 4: Make Predictions
# Predict on the test data
if (exists("logistic_model")) {
  predictions <- predict(logistic_model, test_data, type = "response")
  predicted_classes <- ifelse(predictions > 0.5, 1, 0)  # Convert probabilities to binary predictions
} else {
  predicted_classes <- predict(multinomial_model, test_data)
}


## Step 5: Evaluate the Model
# Confusion Matrix
confusion_matrix <- confusionMatrix(factor(predicted_classes), test_data$Risk_Cat)
print(confusion_matrix)

# Calculate accuracy
accuracy <- confusion_matrix$overall['Accuracy']
cat("Accuracy of the Classification Model:", accuracy, "\n")






