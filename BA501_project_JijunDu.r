library(data.table)
library(sqldf)
library(dplyr)
customer_table <- fread("~/Desktop/Project Ecommece/customer_table.csv")
order_table <- fread("~/Desktop/Project Ecommece/order_table.csv")
product_table <- fread("~/Desktop/Project Ecommece/product_table.csv")
category_table <- fread("~/Desktop/Project Ecommece/category_table.csv")


#### to change from scientific notation to the actual number
customer_table[,customer_id := as.character(customer_table$customer_id)]
order_table[,customer_id := as.character(order_table$customer_id)]
order_table[,order_id := as.character(order_table$order_id)]
order_table[,product_id := as.character(order_table$product_id)]
product_table[,product_id := as.character(product_table$product_id)]

# Step 1
customer_start=sqldf(
  "SELECT c.customer_id,sum(order_amount)
  FROM customer_table c  join order_table o on c.customer_id=o.customer_id
  WHERE order_date<20161222 AND order_amount>0
  GROUP BY 1")
purchase_again=sqldf("SELECT customer_id,max(order_date)
                      FROM order_table
                     WHERE order_date BETWEEN 20161222 AND 20170222 AND order_amount>0
                     group by 1")

# Step 2
dormant_3_month=sqldf("SELECT customer_id 
                      FROM customer_start
                      WHERE customer_id not in (SELECT customer_id from purchase_again)")

# Step 3
re_purchase=sqldf("SELECT d.customer_id
                  FROM dormant_3_month d join order_table o on d.customer_id=o.customer_id
                  WHERE order_date between 20170223 and 20170522
                   ")
customer_sub=sqldf("SELECT * 
                    FROM customer_table c JOIN order_table o on c.customer_id=o.customer_id 
                   WHERE order_date<20161222 ")

flag = sqldf("SELECT CASE WHEN r.customer_id IS NOT NULL THEN 1
                      ELSE 0 END AS 
                     FROM dormant_3month d
                     LEFT JOIN re_purchase r
                     ON d.customer_id = r.customer_id
                     ")


# 4. Data cleaning: remove the character type features
#	deal with missing values (users whose features have ‘NA’). 
customer_temp= customer[!is.na(customer_temp)]

colname<-c('country','gender','has_additional_device1','has_additional_device2',
        'has_additional_device3','is_feature_user','latest_device_class')
customer_sub[colname]<-lapply(customer_sub[colname],factor)


# split data into training and testing
train_num=nrow(customer_sub)*0.8
train=customer_sub[1:train_num,]
test=customer_flag_nona[train_num+1,]


#logistic regression, lasso/ridge regression, random forest,

# 5.1 Logistic Regression
model<-glm(flag~.,family = binomial(link="logit"),data=train)

# 5.2 Lasso/ridge regression
library(glmnet)

ridge.mod <- glmnet(x, y, alpha = 0, lambda = lambda)
predict(ridge.mod, s = 0, exact = T, type = 'coefficients')[1:6,]



# 5.3 random forest
library(randomForest)

customer_rf=randomForest(flag~  , data = customer_usb, subset = train)
summary(customer_rf)


#### option 1
## instrutions in the doc: https://docs.google.com/document/d/1q5O1Z8aLDm0laC14nFPov3FeQOJ4B-9ZxUoY8E7WYv0/edit?usp=sharing

#### option 2
## instrutions in the doc: https://docs.google.com/document/d/1q5O1Z8aLDm0laC14nFPov3FeQOJ4B-9ZxUoY8E7WYv0/edit?usp=sharing

#### logistic regression instructions



## http://michael.hahsler.net/SMU/EMIS7332/R/logistic_regression.html


