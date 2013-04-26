source("http://www.bioconductor.org/biocLite.R")

data <- read.table ( file.choose(), header = TRUE, row.names=1)

numbers <- cbind(data[,1], data[,2], data[,3], data[,4], data[,5], data[,6], data[,7], data[,8], data[,9], data[,10], data[,11], data[,12], data[,13], data[,14], data[,15], data[,16], data[,17], data[,18], data[,19], data[,20], data[,21]) # add additonal columns as needed

# biocLite("gplots")
library("gplots")
pdf("heatmap.pdf")
heatmap.2(numbers, 
          col=redgreen(77) ,
          scale="none",
          key=TRUE,
          symkey=FALSE,
          dendrogram="both",
          density.info="none",
          trace="none",
          0,0
          cexCol = 1,
          labRow = rownames(data),
          labCol = colnames(data),
          margins=c(4,10)
          )
dev.off()
