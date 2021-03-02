#EUNICE WORIFAH
#MGSC 661 - FINAL PROJECT - DEC 15, 2020


#-------------PART 1 : DATA EXPLORATION -----------------------------------

attach(parole)
dim(parole)
str(parole)
summary(parole)

#check column names
colnames(parole)

#numeric variables
age
time.served
max.sentence

#categorical variables
male
race
state
multiple.offenses
crime
violator


###  STEP 1a: Exploring Variables Individually (x must be numeric)

summary(age)
hist(age, breaks = 30, col='orange')
boxplot(age, outcol = 'orange', col="orange")

summary(time.served)
hist(time.served, breaks = 30, col='orange')
boxplot(time.served, outcol = 'black', col="orange")

summary(max.sentence)
hist(max.sentence, breaks = 30, col='orange')
boxplot(max.sentence, outcol = 'black', col="orange")

hist(male, breaks = 30, col='orange', main="Frequency of Male")

hist(race, breaks = 30, col='orange', main="Frequency of Race")

hist(state, breaks = 30, col='orange', main="Frequency of State")

hist(multiple.offenses, breaks = 30, col='orange', main="Frequency of Multiple Offenses")

hist(crime, breaks = 30, col='orange', main="Frequency of Crime")



###  STEP 1b: Exploring Relationships (need to dummify categorical variables)

attach(parole1)
parole1$state <- as.factor(parole1$state)
parole1$crime <- as.factor(parole1$crime)
parole1$male <- as.factor(parole1$male)
parole1$race <- as.factor(parole1$race)
parole1$multiple.offenses <- as.factor(parole1$multiple.offenses)
parole1$violator <- as.factor(parole1$violator)
attach(parole1)

library(ggplot2)
require(methods)

#age
plot=ggplot(parole, aes(y=violator, x=age))
scatter=geom_point(col=ifelse(violator==1,"orange", "black"))
plot+scatter

logit_age=glm(violator~age, family = "binomial")
summary(logit_age)

#time.served
plot=ggplot(parole, aes(y=violator, x=time.served))
scatter=geom_point(col=ifelse(violator==1,"orange", "black"))
plot+scatter

logit_timeserved=glm(violator~time.served, family = "binomial")
summary(logit_timeserved)

#max.sentence
plot=ggplot(parole, aes(y=violator, x=max.sentence))
scatter=geom_point(col=ifelse(violator==1,"orange", "black"))
plot+scatter

logit_maxsentence=glm(violator~max.sentence, family = "binomial")
summary(logit_maxsentence)


plot(state, violator, main="Violator and State", ylab = "violator", xlab='state')

plot(race, violator, main="Violator and Race", ylab = "violator", xlab='race')

plot(male, violator, main="Violator and Male", ylab = "violator", xlab='male')

plot(multiple.offenses, violator, main="Violator and Multiple Offenses", ylab = "violator", xlab='multiple offenses')

plot(crime, violator, main="Violator and Crime", ylab = "violator", xlab='crime')


###  STEP 1c: correlation matrix (x must be numeric)
parole_vars = parole[,c(1:8)]

cor <- cor(parole_vars)
round(cor, 3)

library(corrplot)
corrplot(cor, type = "upper", order = "hclust", 
         tl.col = "black", tl.srt = 45, col= c("white", "grey" , 'yellow', "orange"))



#-------------PART 2 : MODELLING  ------------------------------------------


###### STEP 2a: SIMPLE TREE (do not dummify predictors)

parole$outcome <- ifelse(parole$violator==1, "violated", "not violated") #I want 'violated' to appear in tree diagram, rather than '0' or '1'
parole$outcome <- as.factor(parole$outcome)
attach(parole)

install.packages("tree")
install.packages("rpart.plot")
library(tree)
library(rpart)
library(rpart.plot)

#SIMPLE TREE
mytree=rpart(outcome~male+race+age+state+time.served+max.sentence+multiple.offenses+crime,control=rpart.control(cp=0.0001))
rpart.plot(mytree)
printcp(mytree)
plotcp(mytree)

#find optimal cp
opt_cp=mytree$cptable[which.min(mytree$cptable[,"xerror"]),"CP"]
opt_cp = 0.017949
#0.017949 - keeps changing, but most times the output is 0.017949

#build optimal simple tree
set.seed(0)
mybesttree=rpart(outcome~male+race+age+state+time.served+max.sentence+multiple.offenses+crime,control=rpart.control(cp=opt_cp))
printcp(mybesttree)

#visualize tree
simple_tree = rpart.plot(mybesttree, box.palette = c("white",  "grey", "orange"))
simple_tree

#error rate = root node error (0.11556) x xerror (1.0256) = 0.119



###### STEP 2b: RANDOM FOREST (Bagging)

install.packages("randomForest")
library(randomForest)

set.seed(0)
myforest=randomForest(violator~male+race+age+state+time.served+max.sentence+multiple.offenses+crime, ntree=1000, data=parole1, importance=TRUE, na.action = na.omit, do.trace=100)
myforest #mean squared residuals = 0.0824
plot(myforest, log='y', col='dark orange')

#error rate = 0.117
myforest$confusion


###### STEP 2c: BOOSTING
library(gbm)

set.seed(0)

indexes = createDataPartition(parole$violator, p = .80, list = F) #split data - 80% train, 20% test
train = parole[indexes, ]
test = parole[-indexes, ]


set.seed (0)
boosted=gbm(violator~male+race+age+state+time.served+max.sentence+multiple.offenses+crime,
            data=train,distribution="bernoulli",n.trees=10000, interaction.depth=3)
summary(boosted) 
pred<-predict(object=boosted,newdata=test,n.trees=10000,type="response")
pred

error <- ifelse(pred > 0.5,1,0)
error = as.factor(error)

testerror = test$violator
testerror = as.factor(testerror)

cm <- confusionMatrix(error,testerror)
cm

ERROR = 1-cm$overall
ERROR


######## STEP 2d: LOGISTIC REGRESSION

#use all predictors

parole1$state = relevel(parole1$state, ref=3) #relevel state variable because I want state 3 (louuisiana) to be the reference
parole1$crime = relevel(parole1$crime, ref=4) #relevel crime variable because I want crime 2 (larceny) to be the reference
attach(parole1)

install.packages("caret")
library(caret) 

set.seed(0)
indexes = createDataPartition(parole1$violator, p = .80, list = F) #split data - 80% train, 20% test
train = parole1[indexes, ]
test = parole1[-indexes, ]

#Build the model
logit = glm(violator~male+race+age+state+time.served+max.sentence+multiple.offenses+crime, family="binomial", data=train)
#logit = glm(violator~state+multiple.offenses+max.sentence+time.served, family="binomial", data=train)
summary(logit)

#stargazer
install.packages("stargazer")
library(stargazer)
stargazer(logit, type="html",  title = "Table 3: Logistic Regression")

#R-Squared (do this in rstudio)
install.packages("rms")
require(rms)
mlogit2 =lrm(violator~male+race+age+state+time.served+max.sentence+multiple.offenses+crime, data=train)
mlogit2


#Evaluate model on test set
pred = predict(logit, type = "response", newdata = test)
max(pred)

error <- ifelse(pred > 0.5,1,0)
error = as.factor(error)

testerror = test$violator
testerror = as.factor(testerror)

cm <- confusionMatrix(error,testerror)
cm

ERROR = 1-cm$overall
ERROR
#0.10447761 - with all predictors
#0.11940299 - with the 4 important variables from the decision tree


###### STEP 2e: FEATURE SELECTION

#VARIABLE IMPORTANCE

imp = importance(myforest)
stargazer(imp, type='html', summary=FALSE, align=TRUE, title ="Table 1: Variable Importance Table")

varImpPlot(myforest, lcolor='orange', main='Variable Importance Plot', bg='grey')


#PCA
parole_vars = parole[,c(1:8)]
pca=prcomp(parole_vars, scale=TRUE)
pca


install.packages("ggfortify")
library(ggplot2)
library(ggfortify)

autoplot(pca, data = parole_vars, loadings = TRUE, 
         col=ifelse(parole$violator==1,"orange","grey"),loadings.label = TRUE, lcol="black" )


pve=(pca$sdev^2)/sum(pca$sdev^2)
par(mfrow=c(1,2))
plot(pve, ylim=c(0,1), ylab = "proportion of variance",  col="orange", bg='grey')
plot(cumsum(pve), ylim=c(0,1), ylab = "cumulative proportion", col="orange", bg='grey')

summary(pca)



#-------------PART 3 : MAKING PREDICTIONS  ------------------------------------------

#new data
value = data.frame(male=1, race=2, age=35, state=2, time.served=4,  max.sentence=12, multiple.offenses=0,crime=3)
value$state <- as.factor(value$state)


value_1 = data.frame(male=1, race=2, age=35, state=2, time.served=4,  max.sentence=12, multiple.offenses=0,crime=3)
value_1$male <- as.factor(value_1$male)
value_1$race <- as.factor(value_1$race)
value_1$crime <- as.factor(value_1$crime)
value_1$state <- as.factor(value_1$state)
value_1$multiple.offenses <- as.factor(value_1$multiple.offenses)

#Simple Tree
predict(mybesttree, newdata=value_1)

#Random Forest
pred = predict(myforest, new_data=value_1)
summary(pred)


#Logistic Regression
m = predict(logit, newdata=value_1, type="response")
prob = m/(1+m)
prob

