# Script for Illumina MiSeq2x300 Juniperus projects: Texcoco and Izta
# Part. 3. Beta diversity 
# February, 2020 

library("plyr"); packageVersion("plyr")
library("phyloseq"); packageVersion("phyloseq")
library("ggplot2"); packageVersion("ggplot2")
library("vegan"); packageVersion("vegan")
library("RColorBrewer"); packageVersion("RColorBrewer")
library("plotly"); packageVersion("plotly")
library("htmltools"); packageVersion("htmltools")
library("DT"); packageVersion("DT")
library(ggplot2)
library(dplyr)
library(tibble)
library(randomForest)
library(knitr)
library(gplots)
library(VennDiagram)
library(bipartite)
library(sna)
library(igraph)
library(ggnetwork)
library(statnet.common)
library(network)

theme_set(theme_bw())


# Set working directory to source file


source("../bin/1_Filter_otu_table.R")


# Beta diversity plots and tests 

#### Subset by project ####

# Use binary table where OTUs present in only one sample were removed

subset.texcoco.binary.beta <- subset_samples(binary_table_OTU2, Project %in% "Texcoco")
subset.texcoco.binary.beta
sample_data(subset.texcoco.binary.beta)

# Remove OTUs that are not present in any of the samples of the subset
any(taxa_sums(subset.texcoco.binary.beta) == 0)
taxa_sums(subset.texcoco.binary.beta) [1:10]

subset.texcoco.binary.beta <- prune_taxa(taxa_sums(subset.texcoco.binary.beta) > 0, subset.texcoco.binary.beta)

any(taxa_sums(subset.texcoco.binary.beta) == 0)
taxa_sums(subset.texcoco.binary.beta) [1:10]
subset.texcoco.binary.beta

#### Data vizualisation ####

# Reorder Texcoco for facet_wrap
sample_data(subset.texcoco.binary.beta)$Site = factor(sample_data(subset.texcoco.binary.beta)$Site, levels=c("native","mixed","perturbated"))

# Select data or subset 
sample_data(subset.texcoco.binary.beta)


# Take out samples with no fungi present for ECM and for AM 
trophicmode = subset_samples(subset.texcoco.binary.beta, phinchID != "F3-J5s-2-2621810")
trophicmode 

#Subset if necessary
selectedtrophic <- subset_taxa(trophicmode, Trophic %in% c("a__ecm"))
selectedtrophic 


# Table for diversity measures and sample data
myc.diversity <-estimate_richness(selectedtrophic, measures=c("Observed"))

otu_table(selectedtrophic)
any(taxa_sums(selectedtrophic) == 0)
selectedtrophic<- prune_taxa(taxa_sums(selectedtrophic) > 0, selectedtrophic)
selectedtrophic
sample_data(selectedtrophic)

# NMDS Texcoco (change method for distance)
nmds = distance(selectedtrophic, method = "raup")
nmds
ordination = ordinate(selectedtrophic, method = "NMDS", distance = nmds)
ordination
scores(ordination)

# New facet label names for supp variable
supp.labs <- c("native", "mixed", "disturbed")
names(supp.labs) <- c("native", "mixed", "perturbated")
sample_data(subset.texcoco.binary.beta)$Site = factor(sample_data(subset.texcoco.binary.beta)$Site, levels=c("native","mixed","disturbed"))

#Plot nmds 
p1 <- plot_ordination(selectedtrophic, ordination, color="Host", shape = "Site", title = "All fungi") + theme(aspect.ratio=1)+geom_point(size=3) 
print(p1)
p1 + facet_wrap(~Site)

#### Tests #### 

#PERMANOVA: Adonis
sampledf <- data.frame(sample_data(selectedtrophic))

adonis2( nmds ~ Host+Site, data = sampledf) 
adonis2( nmds ~ Type, data = sampledf) 
adonis2( nmds ~ Site, data = sampledf)
adonis2( nmds ~ Host, data = sampledf)
adonis2( nmds ~ Site+Type, data = sampledf)

#Network 

plot_net(selectedtrophic, color = "Host", shape = "Site") #not using 


#### Create table frequency mycorrhizal fungi in each Host####

subset.myc <- subset_taxa(subset.texcoco.binary.beta, Trophic %in% c("a__am"))
subset.myc <- subset_samples(subset.myc, Type %in% c("root"))
subset.myc

any(taxa_sums(subset.myc) == 0)
subset.myc <- prune_taxa(taxa_sums(subset.myc) > 0, subset.myc)
subset.myc

tax_table(subset.myc)
otu_table(subset.myc)


#make a dataframe with OTUs as column and samples as rows
predictors <- t(otu_table(subset.myc))
dim(predictors)

predictors <- as.table(predictors)


predictors<- as.data.frame(predictors)
dim(predictors)

Host <- as.factor(sample_data(subset.myc)$Host)
Site <- as.factor(sample_data(subset.myc)$Site)

predictors <- data.frame(predictors,Host,Site)

tax.table<-as.data.frame(tax_table(subset.myc))
tax.table
match.id <- match(predictors$Var2, rownames(tax.table))

predictors$Family <- tax.table$Family[match.id]
predictors$Trophic <- tax.table$Trophic[match.id]
predictors$Genus <- tax.table$Genus[match.id] 

predictors <- subset(predictors, predictors$Freq == 1)
  
sort(table(predictors$Var2))

sharedotusam<-write.csv(predictors, file = "sharedotusacm.csv")

###

#make a column for the outcome/response variable
response <- as.factor(sample_data(subset.myc)$Host)

response2 <- t(tax_table(subset.myc))

#combine them into 1 data frame
rf.data <- data.frame(response, predictors, response2)

#
library(tidyr)
?as.data.frame

predictors.1 <- as.data.frame(predictors)

predictors.1$samples <- rownames(predictors.1)

predictors.1 <- gather(predictors.1)











#### network using sna #### 

#Select data
subset <- subset_taxa(subset.texcoco.binary.beta, Trophic %in% c("a__am"))
subset<- subset_samples(subset, Type %in% "root")
subset

#Merge by category 
nw <-merge_samples(subset, group = "Host")
network_host <- as.data.frame(otu_table(nw))
is.matrix(network_host)

#vectors
taxa_names(subset)
color_vector <- c("f__ Glomeraceae", "f__ Claroideoglomeraceae", "f__ Acaulosporaceae", "f__ Gigasporaceae", "f__ Ambisporaceae", "f__ Paraglomeraceae", "f__ Unknown")
color<-as.matrix(tax_table(subset))
color<-as.data.frame(color)
color<-color$Family

#color_vector <- color$Family


#Gplot
gplot(network_host, thresh = 0.2, displaylabels = TRUE, vertex.col = color)
network_host


#Merge more than one category 

sample_variables(subset)

variable1 = as.character(get_variable(subset, "Host"))
variable2 = as.character(get_variable(subset, "Site"))

sample_data(subset)$NewPastedVar <- mapply(paste0, variable1, variable2, 
                                           collapse = "_")
nw2<- merge_samples(subset, "NewPastedVar")

network_host <- as.data.frame(otu_table(nw2))
is.matrix(network_host)



#Gplot
gplot(network_host, thresh = 0.2, displaylabels = TRUE, label=rownames(network_host),
      legend(x=1,y=-1, color_vector, pch=21, col = "#777777", 
             pt.cex=2, cex=.8, bty="n", ncol=1), vertex.col = color)


#Other format
abc<-t(network_host)

#Plot
plotweb(network_host)

#Plot
visweb(network_host)

network_host

#Other type of plot 

pal2 <-brewer.pal(8, "Set2")

par(mfrow=c(1,2), xpd=T)
gplot(as.one.mode(network_host),
      displaylabels = TRUE,
      label=rownames(network_host), 
      gmode="graph",
      label.cex=0.6, vertex.col = color, vertex.cex=2)

+legend(x=-1,y=-1, color$Family, pch=21, col = pal2, pt.cex=2, cex=.8, bty="n", ncol=1)

#### Networks using igraph ####

sampledata = data.frame(sample_data(selectedtrophic))
d1 = as.matrix(phyloseq::distance(nw, method="raup"))
gr = graph.adjacency(d1, mode = "directed", weighted = TRUE)

net = igraph::mst(gr)
V(net)$id = sampledata[names(V(net)), "phinchID"]
V(net)$label[V(net)$type==F] <- nodes$media[V(net)$type==F]


gnet=ggnetwork(net)

ggplot(gnet, aes(x = x, y = y, xend = xend, yend = yend))+
  geom_edges(color = "darkgray") +
  geom_nodes(aes(color = )) +
  theme_blank()+
  theme(legend.position="bottom")


