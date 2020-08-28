library(cluster)
library(dplyr)
setwd('E:/Datasets/BIG5/Data')


#Reading the Big5 dataset
big = read.csv('data.csv', sep= "")
head(big)
str(big)

#Removing NAs and unwanted columns 
big = big[,-c(5,6)]
head(big)
big = na.omit(big)

names(big)
dim(big)

#Countries of respondents
sort(table(big$country), decreasing = TRUE)

#Removing rows with vague age values 
unique(big$age)
big = big[!(big$age>=120),]
unique(big$age)


#Taking a sample of 5000 respondents (due to computational reasons)
set.seed(2)
train = big[sample.int(nrow(big), 5000),]

remove(big)


#Adding 5000 unique names for easier identification
names=read.csv('baby-names.csv')

names = names$name
names = unique(names)
names = names[sample.int(length(names), 5000)]

train = data.frame(names,train)


#Reading the interests dataset
int = read.csv('interests.csv')
head(int)
int = na.omit(int)
heatmap(cor(int[,-51]))

#Creating a dataset of 5000 from 800 with replacement 
set.seed(2)
intlarge = int[sample.int(nrow(int), 5000, replace = TRUE),]
summary(intlarge)
summary(int)
head(intlarge)
train = data.frame(train, intlarge)
names(train)

sort(table(train$Education), decreasing = TRUE)
hist(train$age, col = 'red', xlab = 'Age', ylab = 'Frequency', main = 'AGE FREQUENCY')
hist(train$gender, col = 'blue', xlab = 'Gender
     1=Male, 2=Female, 3=Other', ylab = 'Frequency', main = 'GENDER FREQUENCY')



#PRINCIPAL COMPONENT ANALYSIS___________________

#Principal Component Analysis on interest columns
pr.out = prcomp(intlarge[,1:50], scale = TRUE)
pr.out

pr.out$x
par(mfrow=c(1,1))
plot(pr.out$x[,1:2], pch=19, xlab = 'PC1', ylab='PC2')
plot(pr.out$x[,c(1,3)], pch=19, xlab = 'PC1', ylab='PC3')

summary(pr.out)
plot(pr.out$sdev, xlab='Principal Component', ylab='Standard Deviation', main='Standard Deviation explained by each PC')

#Proportion of Variance explained by each additional PC
pve = 100*pr.out$sdev^2/sum(pr.out$sdev^2)
par(mfrow=c(1,2))
plot(pve[1:18],type='o',ylab='Prop. var. explained', xlab="Principal Component", col='blue')
plot(cumsum(pve[1:18]),type='o',ylab='Cum. Prop. var. explained', xlab="Principal Component", col='blue')

par(mfrow=c(1,1))
plot(cumsum(pve[1:18]),type='o',ylab='Cum. Prop. var. explained', xlab="Principal Component", col='blue')
abline(h=60)

pr.out$x[,1:14]
head(sort(pr.out$rotation[,1],decreasing = TRUE))
head(sort(pr.out$rotation[,2],decreasing = TRUE))
head(sort(pr.out$rotation[,3],decreasing = TRUE))
head(sort(pr.out$rotation[,4],decreasing = TRUE))
head(sort(pr.out$rotation[,5],decreasing = TRUE))

#Taking out the first 14 PCs
pca.int.data = pr.out$x[,1:14]
head(pca.int.data)



#Principal Component Analysis on Big5 columns
head(train)
pr.out2 = prcomp(train[,7:56], scale = TRUE)
pr.out2

pr.out2$x
par(mfrow=c(1,1))
plot(pr.out2$x[,1:2], pch=19, xlab = 'PC1', ylab='PC2')
plot(pr.out2$x[,c(1,3)], pch=19, xlab = 'PC1', ylab='PC3')

summary(pr.out2)
plot(pr.out2$sdev, xlab='Principal Component', ylab='Standard Deviation', main='Standard Deviation explained by each PC')

#Proportion of Variance explained by each additional PC 
pve2= 100*pr.out2$sdev^2/sum(pr.out2$sdev^2)
par(mfrow=c(1,2))
plot(pve2[1:20],type='o',ylab='Prop. var. explained', xlab="Principal Component", col='blue')
plot(cumsum(pve2[1:20]),type='o',ylab='Cum. Prop. var. explained', xlab="Principal Component", col='blue')

par(mfrow=c(1,1))
plot(cumsum(pve2[1:18]),type='o',ylab='Cum. Prop. var. explained', xlab="Principal Component", col='blue')
abline(h=60)

pr.out2$x[,1:12]
head(sort(pr.out2$rotation[,1],decreasing = TRUE))
head(sort(pr.out2$rotation[,2],decreasing = TRUE))
head(sort(pr.out2$rotation[,3],decreasing = TRUE))
head(sort(pr.out2$rotation[,4],decreasing = TRUE))
head(sort(pr.out2$rotation[,5],decreasing = TRUE))

#Taking out first 12 PCs
pca.big.data = pr.out2$x[,1:12]
head(pca.big.data)

#Creating a dataframe with Principal Component values only
pcatrain = data.frame(train[,1:6], pca.big.data)
names(pcatrain) 
names(pcatrain) = c("names","race","age","engnat","gender","country",
                    "bigPC1","bigPC2","bigPC3","bigPC4","bigPC5","bigPC6","bigPC7","bigPC8","bigPC9","bigPC10","bigPC11","bigPC12")
head(pcatrain)

pcatrain = data.frame(pcatrain, pca.int.data)
names(pcatrain) 
names(pcatrain) = c("names","race","age","engnat","gender","country",
                    "bigPC1","bigPC2","bigPC3","bigPC4","bigPC5","bigPC6","bigPC7","bigPC8","bigPC9","bigPC10","bigPC11","bigPC12",
                    "intPC1","intPC2","intPC3","intPC4","intPC5","intPC6","intPC7","intPC8","intPC9","intPC10","intPC11","intPC12","intPC13","intPC14")

head(pcatrain)
names(pcatrain)
summary(pcatrain)
str(pcatrain)

remove(pr.out)
remove(pr.out2)
remove(pca.big.data)
remove(pca.int.data)




#CLUSTERING PEOPLE ON THE BASIS OF THEIR INTERESTS_______________________________

#Heirarchical Clustering
scaled = scale(pcatrain[,7:32])

summary(pcatrain[,7:32])
summary(scaled)

distances = dist(scaled[,13:26], method = "euclidean")
hc = hclust(distances, method = 'ward.D')
remove(distances)

plot(hc)
abline(h=185, col = 'red')

hc.cluster = cutree(hc, h=185)
hc.cluster
remove(scaled)


#KMeansClustering
kmc = kmeans(pcatrain[,7:32], centers = 12, iter.max = 20)
kmc$cluster
par(mfrow = c(1,1))
plot(kmc$cluster)

kmc$cluster[1:10]
sort(kmc$cluster)
sort(kmc$centers)

#Joining the cluster assigned
cluster = kmc$cluster
pcatrain = data.frame(pcatrain, cluster)
head(pcatrain)

#Column means in different clusters
colMeans(pcatrain[pcatrain$cluster==1,7:32])
colMeans(pcatrain[pcatrain$cluster==2,7:32])
colMeans(pcatrain[pcatrain$cluster==3,7:32])


#FINAL STEPS____________________________
#Selecting close matches for selected user
user = pcatrain[pcatrain$names == 'Penni',]
user

#Filtering out people from the same cluster, age-group and country
closecluster = pcatrain %>% filter(kmc$cluster == user$cluster)
refined = as.data.frame(subset(closecluster,closecluster$country == user$country & closecluster$gender != user$gender & (closecluster$age >= (user$age-3) & closecluster$age <= (user$age+3))))
head(refined)

#Finding people with personality most similar  to user's
for(i in c(1:nrow(refined))) {refined$sumdifference[i] = sum(sqrt((refined[i,7:18]-user[,7:18])^2))}
selected = head(refined[order(refined$sumdifference),],10)$names
selected

#Original responses of the filtered people and user 
train[train$names==user$names,]
train[train$names %in% selected,]




#SORTING PEOPLE WITH ONLY PERSONALITY MOST SIMILAR TO THE USER'S; DOESNT CONSIDER CLUSTERS
#NOTE:  COMPUTATIONALLY EXPENSIVE
pcatrain2 = pcatrain

for(i in c(1:nrow(pcatrain2))) {pcatrain2$sumdifference[i] = sum(sqrt((pcatrain2[i,7:18]-user[,7:18])^2))}
head(pcatrain2[order(pcatrain2$sumdifference),])


#FIN__________________________________________________________________