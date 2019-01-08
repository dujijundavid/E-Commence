# Summary statistics
load('down_dataset.RData')
head(order_table_down)
summary(order_table_down)
summary(product_table_down)
summary(customer_table_down)
names(customer_table_down)

# Getting to know datasets
summary(category_table_down)
# category_table_down:  category_id, name, parent category id
names(customer_table_down)
# 90 unknown user features
# 5 tablet_features, 5 phone featurs
names(customer_table_down)[1:10]

# Construct my ER-diagram & relational schema for SQL
summary(customer_table_down$is_feature_user)

first= customer_table_down$first_visit_date
last= customer_table_down$last_visit_date


# Feature engineering
# Date features: 
    # base: make purchase between date x~x+90   =sub_customer (date)
    # dormant: x+91~x+180 no purchase = sub_customer (date, order)
    # Flag target variable: 1 for making purchase in 181~270, 0 otherwise



# Trial
# convert datetime
first[1]
as.numeric(as.Date(first))
date=as.numeric(as.Date(last)-(as.Date(first)))

# Important date

order_agg= sqldf("SELECT sum(order_amount) as amount, order_date as date FROM order_table_down 
                 GROUP BY order_date
                  HAVING order_date<20161231 and order_date >20160101
                    
                 ORDER BY order_date")

g1=ggplot(order_agg, aes(x=date, y=amount)) + 
  geom_point(col="steelblue", size=2) +   # Set static color and size for points
  geom_smooth(method="lm", col="firebrick") +  # change the color of line
  labs(title="Order Trends", y="order_amount", x="order_date", caption="2016 data")
plot(g1)



order_agg$date

