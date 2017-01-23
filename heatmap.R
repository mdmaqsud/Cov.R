################heatmap that is working##################33
require(graphics); require(grDevices)
setwd("~/R_data") # set to what required
data <- read.csv ( file.choose(), header = TRUE, row.names=1)
dim(data)
number <- cbind(data[,1], data[,2], data[,3], data[,4], data[,5], data[,6], data[,7], data[,8], data[,9])
#biocLite("gplots")

library("gplots")
pdf("heatmap_grp1_2_dominant.pdf")
hmcols<-colorRampPalette(c("cadetblue","yellow"))(75)
heatmap.2(number,
          col=hmcols,
          scale="none",
          key=TRUE,
          symkey=FALSE,
          dendrogram="both",
          density.info="none",
          trace="none",
          cexRow= 0.6,
          cexCol = 0.8,
          labRow = rownames(data),
          labCol = colnames(data),
          margins=c(7, 5)
)
dev.off()
