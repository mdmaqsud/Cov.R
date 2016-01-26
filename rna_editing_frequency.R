data <- read.table(file.choose())
data.frame(data)
View(head(data))
M<-table(data$V11)
M<-sort(M,decreasing = TRUE)


# barplot of top n genes of interest
barplot(M[1:20],las=3,col = "skyblue", main="barplot_top20genes")


# density plot of all genes
plot(density(M),lwd=2,col="red")

# density plot of imp genes
N<-M[M>=5]
lines(density(N),lwd=2,col="blue", main="density_red_all_blue_withfrequeycgt5")


# genes of interest
length(which(M>5))

# total genes
length(M)

# names of top genes
N<-M[M>=5]
names(N)
write.table(names(N),file="genes.txt",quote = FALSE,row.names = FALSE)
dev.off()
getwd()
