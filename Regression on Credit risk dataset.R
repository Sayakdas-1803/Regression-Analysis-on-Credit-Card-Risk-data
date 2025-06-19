data<-read.csv("C:\\Users\\sayak\\Downloads\\creditcard.csv\\creditcard.csv")
View(data)
install.packages(c("tidyverse","caret","pROC","ROCR","ggplot2","GGally"))


# Load required libraries.......................
library(tidyverse)
library(caret)
library(pROC)
library(ROCR)
library(ggplot2)
library(GGally)

head(data)
str(data)
summary(data)

#Exploratory Data Analysis........................
#Visualize the Class Distribution............
ggplot(data, aes(x = factor(Class))) +
  geom_bar(fill = c("blue", "red")) +
  labs(title = "Class Distribution (0: No Fraud, 1: Fraud)",
       x = "Class", y = "Count") +
  theme_minimal()

# Check the distribution of transaction amounts......................
ggplot(data, aes(x = Amount, fill = factor(Class))) +
  geom_histogram(bins = 50, alpha = 0.6) +
  scale_y_log10() +
  scale_fill_manual(values = c("blue", "red"), name = "Class") +
  labs(title = "Distribution of Transaction Amounts by Class") +
  theme_minimal()

# Correlation matrix (for regression analysis)
ggcorr(data[, c(1:5, 30)], label = TRUE, label_size = 3)

#Data Preperation..................
# Split data into training and test sets
set.seed(42)
train_index <- createDataPartition(data$Class, p = 0.7, list = FALSE)
train_data <- data[train_index, ]
test_data <- data[-train_index, ]

# Standardize the data (excluding Time and Class)
preprocess_params <- preProcess(train_data[, -c(1, 31)], method = c("center", "scale"))
train_data_scaled <- predict(preprocess_params, train_data)
test_data_scaled <- predict(preprocess_params, test_data)

#linear regression analysis..................
# Linear Regression (for demonstration)
lin_model <- lm(Class ~ . - Time, data = train_data_scaled)
summary(lin_model)

# Predictions
lin_pred <- predict(lin_model, newdata = test_data_scaled)

# Evaluate the model
mse <- mean((test_data_scaled$Class - lin_pred)^2)
paste("Linear Regression Mean Squared Error:", mse)

# Plot actual vs predicted
ggplot(data.frame(Actual = test_data_scaled$Class, Predicted = lin_pred), 
       aes(x = Actual, y = Predicted)) +
  geom_point(alpha = 0.3) +
  geom_abline(slope = 1, intercept = 0, color = "red") +
  labs(title = "Linear Regression: Actual vs Predicted") +
  theme_minimal()

#logistic regression.....................
# Logistic Regression (more appropriate for classification)
log_model <- glm(Class ~ . - Time, 
                data = train_data_scaled, 
                family = binomial(link = "logit"),
                control = list(maxit = 50))

summary(log_model)

# Predictions
log_pred_prob <- predict(log_model, newdata = test_data_scaled, type = "response")
log_pred_class <- ifelse(log_pred_prob > 0.5, 1, 0)


#RoC CUrve vs AUC Curve
# Calculate ROC curve
roc_obj <- roc(test_data_scaled$Class, log_pred_prob)
auc_val <- auc(roc_obj)

# Plot ROC curve
plot(roc_obj, main = paste0("ROC Curve (AUC = ", round(auc_val, 2), ")"),
     col = "darkorange", lwd = 2)
abline(a = 0, b = 1, lty = 2, col = "navy")

# Print AUC score
paste("AUC Score:", auc_val)

# Alternative ROC plot with ggplot
ggroc(roc_obj, legacy.axes = TRUE) +
  geom_abline(slope = 1, intercept = 0, linetype = "dashed") +
  labs(title = paste0("ROC Curve (AUC = ", round(auc_val, 2), ")"),
       x = "False Positive Rate",
       y = "True Positive Rate") +
  theme_minimal()