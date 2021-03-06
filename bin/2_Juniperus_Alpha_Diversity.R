# Script for Illumina MiSeq2x300 Juniperus projects: Texcoco and Izta
# Part.2 Alpha diversity and direct quantitative observation/comparison of abundances
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
library(scales)
library(reshape2)
library(car)
library(lme4)
library(mvabund)
library(sna)
library(bipartite)
library(igraph)
library(ggnetwork)
library(statnet.common)
library(network)
library(ggpubr)
library(multcomp)


# Set working directory to source file


# Call script 
source("../bin/1_Filter_otu_table.R")


#### Abundance counts #### 
 

# Read counts before and after cleaning 

sum(taxa_sums(phyloseq_tables))

sum(taxa_sums(phyloseq_tables_cleaned)) 


# Subset data for Texcoco using OTU table with relative abundance 
pre.filtered.texcoco.alfa <- subset_samples(phyloseq_tables_cleaned, Project %in% "Texcoco")
pre.filtered.texcoco.alfa

sample_data(pre.filtered.texcoco.alfa)

sum(taxa_sums(pre.filtered.texcoco.alfa))

# Remove OTUs that are not present in any of the samples of the subset (OTUs that are only present either in Izta or Texcoco) 
taxa_sums(pre.filtered.texcoco.alfa) [1:10]
pre.filtered.texcoco.alfa <- prune_taxa(taxa_sums(pre.filtered.texcoco.alfa) > 0, pre.filtered.texcoco.alfa)
any(taxa_sums(pre.filtered.texcoco.alfa) == 0)

taxa_sums(pre.filtered.texcoco.alfa) [1:10]
pre.filtered.texcoco.alfa

sum(taxa_sums(pre.filtered.texcoco.alfa))
# Subset data for Texcoco using OTU binary table 

# create its own binary table, just in case counts change 

pre_binary_table = transform_sample_counts(phyloseq_tables_cleaned, function(x, minthreshold=0){
  x[x > minthreshold] <- 1
  return(x)})

head(otu_table(pre_binary_table))

# now susbset 
pre.filtered.texcoco.binary <- subset_samples(pre_binary_table, Project %in% "Texcoco")
pre.filtered.texcoco.binary
sample_data(pre.filtered.texcoco.binary)

#Remove OTUs that are not present in any of the samples of the subset (OTUs that are only present either in Izta or Texcoco) if we do, do it in alpha diversity and beta diversity analysis? 
taxa_sums(pre.filtered.texcoco.binary) [1:10]
pre.filtered.texcoco.binary<- prune_taxa(taxa_sums(pre.filtered.texcoco.binary) > 0, pre.filtered.texcoco.binary)
any(taxa_sums(pre.filtered.texcoco.binary) == 0)

taxa_sums(pre.filtered.texcoco.binary) [1:10]
pre.filtered.texcoco.binary


# Read and OTU counts for am, ecm, sap and unknown 

sum(taxa_sums(pre.filtered.texcoco.alfa)) 

sum(taxa_sums(subset.texcoco.alfa)) 

# ABUNDANCE ECM

subset.ECM <- subset_taxa(pre.filtered.texcoco.alfa, Trophic %in% c("a__ecm"))

subset.ECM

sum(taxa_sums(subset.ECM)) 

subset.ECM <- subset_taxa(subset.texcoco.alfa, Trophic %in% c("a__ecm"))

subset.ECM

sum(taxa_sums(subset.ECM)) 


# ABUNDANCE AM

subset.AM <- subset_taxa(pre.filtered.texcoco.alfa, Trophic %in% c("a__am"))

subset.AM

sum(taxa_sums(subset.AM))

subset.AM <- subset_taxa(subset.texcoco.alfa, Trophic %in% c("a__am"))

subset.AM

sum(taxa_sums(subset.AM))

# ABUNDANCE SAP

subset.SAP <- subset_taxa(pre.filtered.texcoco.alfa, Trophic %in% c("a__sap"))

sum(taxa_sums(subset.SAP)) 

subset.SAP

subset.SAP <- subset_taxa(subset.texcoco.alfa, Trophic %in% c("a__sap"))

sum(taxa_sums(subset.SAP)) 

subset.SAP


# ABUNDANCE UNKNOWN

subset.u <- subset_taxa(pre.filtered.texcoco.alfa, Myc %in% c("t__unknown"))

sum(taxa_sums(subset.u)) 

subset.u

subset.u <- subset_taxa(subset.texcoco.alfa, Myc %in% c("t__unknown"))

sum(taxa_sums(subset.u)) 

subset.u


#### Subset project ####

# Subset data for Texcoco using OTU table with relative abundance 
subset.texcoco.alfa <- subset_samples(phyloseq.rel, Project %in% "Texcoco")
subset.texcoco.alfa
sample_data(subset.texcoco.alfa)
sample_sums(subset.texcoco.alfa) [1:10] 

# Remove OTUs that are not present in any of the samples of the subset
taxa_sums(subset.texcoco.alfa) [1:10]
subset.texcoco.alfa <- prune_taxa(taxa_sums(subset.texcoco.alfa) > 0, subset.texcoco.alfa)
any(taxa_sums(subset.texcoco.alfa) == 0)
taxa_sums(subset.texcoco.alfa) [1:10]
subset.texcoco.alfa

sum(taxa_sums(subset.texcoco.alfa))

# Subset data for Texcoco using OTU binary table 
subset.texcoco.binary <- subset_samples(binary_table, Project %in% "Texcoco")
subset.texcoco.binary
sample_data(subset.texcoco.binary)

#Remove OTUs that are not present in any of the samples of the subset
taxa_sums(subset.texcoco.binary) [1:10]
subset.texcoco.binary<- prune_taxa(taxa_sums(subset.texcoco.binary) > 0, subset.texcoco.binary)
any(taxa_sums(subset.texcoco.binary) == 0)
taxa_sums(subset.texcoco.binary) [1:10]
subset.texcoco.binary

sum(taxa_sums(subset.texcoco.binary))

#### Accumulation curve #### 

# all sites
select = subset.texcoco.alfa ## select data
data = t(otu_table(select)) ## otu table in vegan
data  

plot(specaccum(data))

# per site 

# Calculate specaccum for each site
subset <- subset_samples(select, Site %in% "native")
data = t(otu_table(subset)) ## otu table in vegan
plot(specaccum(data), col = "black", xlab='Number of samples', ylab='Number of OTUs')

subset <- subset_samples(select, Site %in% "mixed")
data = t(otu_table(subset)) ## otu table in vegan
plot(specaccum(data), add = T, col="green")

subset <- subset_samples(select, Site %in% "perturbated")
data = t(otu_table(subset)) ## otu table in vegan
plot(specaccum(data), add = T, col="red")

legend('bottomright', c('native','mixed','disturbed'), 
       col=c('black','green','red'), lty=1, bty='n', inset=0.025)


# Idem  (same graph but with y range calculated)

# Calculate specaccum for each forest type
subset <- subset_samples(select, Host %in% "Quercus")
data = t(otu_table(subset)) ## otu table in vegan
Quercus=specaccum(data, method = "random")

subset <- subset_samples(select, Host %in% "Juniperus")
data = t(otu_table(subset)) ## otu table in vegan
Juniperus=specaccum(data, method = "random")

# Plotting
# Combine the specaccum objects into a list 
l <- list(Quercus, Juniperus)

# Calculate required y-axis limits
ylm = range(sapply(l, '[[', 'richness')) + range(sapply(l, '[[', 'sd'))

# Plotting
# Apply a plotting function over the indices of the list
sapply(seq_along(l), function(i) {
  if (i==1) { # If it's the first list element, use plot()
    with(l[[i]], {
      plot(sites, richness, type='l', ylim=ylm, 
           xlab='Number of samples', ylab='Number of OTUs', las=1)
      segments(seq_len(max(sites)), y0=richness - 2*sd, 
               y1=richness + 2*sd)
    })    
  } else {
    with(l[[i]], { # for subsequent elements, use lines()
      lines(sites, richness, col=i)
      segments(seq_len(max(sites)), y0=richness - 2*sd, 
               y1=richness + 2*sd, col=i)
    })     
  }
})

legend('bottomright', c('Quercus','Juniperus'), 
       col=1:5, lty=1, bty='n', inset=0.1)


#### Relative abundance (reads and OTUs) ####

# Relative abundance of reads by plant host and treatments
# melt to long format (for ggploting) 
# prune out phyla below 1% in each sample
# selecting the taxa at the wanted level 

#Poster plot 

subset.poster<- subset_taxa(subset.texcoco.binary, Trophic %in% c("a__sap", "a__par", "a__ecm", "a__am"))

mdata_phylum <- subset.poster %>%
  tax_glom(taxrank = "Trophic") %>%                     # agglomerate at phylum level
  transform_sample_counts(function(x) {x/sum(x)} ) %>% # Transform to rel. abundance
  psmelt() %>%                                         # Melt to long format
  filter(Abundance > 0.01) %>%                         # Filter out low abundance taxa
  arrange(Trophic)                                      # Sort data frame alphabetically by phylum

# checking the dataframe that we now created
head(mdata_phylum)

# re-order how site and species appear in the graph
mdata_phylum$Site <- factor(mdata_phylum$Site,levels = c("native", "mixed", "perturbated"))
mdata_phylum$Host <- factor(mdata_phylum$Host,levels = c("Quercus", "Juniperus"))

# Now plot: 
ggplot(mdata_phylum, aes(x = Site, y = Abundance, fill = Trophic)) + 
  #facet_grid(time~.) +
  geom_bar(stat = "identity")  +
  # Remove x axis title, and rotate sample lables
  theme(axis.title.x = element_blank(), 
      axis.text.x=element_text(angle=90,hjust=1,vjust=0.5, size = 10),
      legend.title = element_text(size = 10), 
      legend.text = element_text(size = 10)) + 
  
    
  # add labels
  guides(fill = guide_legend(reverse = TRUE, keywidth = 1, keyheight = 1)) +  
  scale_fill_discrete(name = "Trophic mode", labels = c("a__am" = "am", "a__sap" = "sap", "a__par" = "par", "a__ecm" = "ecm")) +
  scale_x_discrete(labels=c("native" = "native", "mixed" = "mixed",
                            "perturbated" = "disturbed")) +
  ylab("OTUs relative abundance") +
  ggtitle("Fungi trophic mode relative abundance") + facet_grid(Type ~ Host)

# Plot obtained: Relative Abundance (using sequence reads) of fungi Phylum by Site, Type of sample and Host plant



# How many OTUs per host 

subset.q<-subset_samples(subset.texcoco.binary, Host %in% "Juniperus")
subset.q
any(taxa_sums(subset.q) ==0)
subset.q <- prune_taxa(taxa_sums(subset.q) > 0, subset.q)
subset.q
otu_table(subset.q)
otushost<-estimate_richness(subset.q)

#### Alpha diversity tests ####

# Diversity boxplots: 

subset.myc <- subset.texcoco.binary

# fungal species richness per site showing only "Observed" in soil and roots: 
plot_richness(subset.myc, x="Host", color = "Site", measures=("Observed"))  + geom_boxplot() 

# Observed per sample type in both sites 
a <- plot_richness(subset.myc, x="Site", color = "Site", measures=("Observed"))  
ab <- a + geom_boxplot(data = a$data, aes(x=Site, y=value, color=Host, alpha=0.1)) 
abc <- ab + facet_wrap(~Type)
abc

# Create a table that gathers diversity indices and subset for different cathegories used 

subset.myc <- subset_taxa(subset.texcoco.binary, Trophic %in% "a__sap")

#verify taxa missing 
any(taxa_sums(subset.myc) == 0)
subset.myc <- prune_taxa(taxa_sums(subset.myc) > 0, subset.myc)
any(taxa_sums(subset.myc) == 0)
taxa_sums(subset.myc) [1:10]
subset.myc

# Table for diversity measures and sample data
myc.diversity <-estimate_richness(subset.myc, measures=c("Observed")) #you can add other alpha diversity measurements, e.g. Fisher 
data <- cbind(sample_data(subset.myc), myc.diversity) #combine metadata with alpha diversity
data

# ANOVA 

#one way ANOVA
# dependent variable (data) : observed richness 
# independet variable (factor): site, host or type of sample 

anova1<-aov(Observed ~ Site, data = data)
summary(anova1)
TukeyHSD(anova1)
boxplot(Observed ~ Host, data = data)


#two-way ANOVA
anova2<-aov(Observed ~ Host*Site, data = data)
summary(anova2)

#The only interaction that was significant for all fungi was host:type 

TukeyHSD(anova2)

# Check normality with visual methods  

ggdensity(myc.diversity$Observed, 
          main = "Density plot of species richness",
          xlab = "Species richness")

## Check linearity of models with normal qq plots 

ggqqplot(myc.diversity$Observed)

## Significance tests for normality 

shapiro.test(myc.diversity$Observed)

# Check residuals 

residual1<- residuals(anova1)
plot(residual1)
shapiro.test(residual1)

residual2<- residuals(anova2)
plot(residual2)
shapiro.test(residual2)


#Levene test for homogeneity of variances 

leveneTest(Observed ~ Site, data=data)


# Use glm because data is not all normal distributed (only for ECM fungi it is) 

# Poisson Regression
# where count is a count and
# x1-x3 are continuous predictors
fit <- glm(Observed ~ Site, data = data, family = Gamma())
summary(fit)

#Kruskal Wallis test: no parametric

head(data)
levels(data$Site)

group_by(data, Site) %>%
  summarise(
    count = n(),
    mean = mean(Observed, na.rm = TRUE),
    sd = sd(Observed, na.rm = TRUE), 
    median = median(Observed, na.rm = TRUE),
    IQR = IQR(Observed, na.rm = TRUE)
  )

KW1<- kruskal.test(Observed ~ Site, data)
KW1

pairwise.wilcox.test(data$Observed, data$Site,
                     p.adjust.method = "bonferroni")

#### Abundance of TOP OTUs  (change for trophic mode and cathegories) ####

#Obtain 50 most abundant OTUs
Top50OTUs <- names(sort(taxa_sums(subset.texcoco.binary), TRUE)[1:50])
ent50 <- prune_taxa(Top50OTUs, subset.texcoco.binary)
ent50
taxa_names(ent50)
ntaxa(ent50)
taxa_sums(ent50)
tax_table(ent50)

options(max.print=2000)
print(otu_table(ent50))


# Plot most abundant OTUs by site
p=plot_bar(ent50, "Site", fill = "Family") +
  geom_bar(aes(color=Family, fill=Family), stat="identity", position="stack") + # remove the dividing lines that separate OTUs inside the bars
  labs(y="Abundance of Top 20 OTUs") # change y-axis title

order_site <- list("native", "mixed", "perturbated") # re-orer the sites on x axis
p$data$Site <- factor(p$data$Site, levels = order_site)
print(p) # Plot obtained: Abundance of TOP 50 OTUs by Family per Site 

# Plot most abundant OTUs by host plant
p=plot_bar(ent50, "Host", fill = "Family", facet_grid = "Site") +
  geom_bar(aes(color=Family, fill=Family), stat="identity", position="stack") + # remove the dividing lines that separate OTUs inside the bars
  labs(y="Abundance of Top 20 OTUs") # change y-axis title
print(p) # Plot obtained: Abundance of TOP 50 OTUs by family per host plant and site 

# Plot most abundant OTUs by host plant merging at trophic mode
plot_bar(ent50, "Host", fill = "Trophic", facet_grid = "Site") +
  geom_bar(aes(color=Trophic, fill=Trophic), stat="identity", position="stack") + # remove the dividing lines that separate OTUs inside the bars
  labs(y="TOP 20 OTUs abundance") # change y-axis title


#### Relative Abundance for most abundant ####

# Most abundant (otus, trophic modes, families) for each host/site using relative abundance in plots

subset <- subset_samples(subset.texcoco.binary, Host %in% c("Quercus"))
subset <- subset_samples(subset, Site %in% c("native"))
subset <- subset_samples(subset, Type %in% c("soil"))
subset

taxa_sums(subset) [1:10]
any(taxa_sums(subset) == 0)
ent <- prune_taxa(taxa_sums(subset) > 0, subset)
any(taxa_sums(ent) == 0)
taxa_sums(ent) [1:10]
ent

Top <- names(sort(taxa_sums(ent), TRUE)[1:10])
ent <- prune_taxa(Top, ent)
ent

taxa_names(ent)
tax_table(ent)


mdata_top <- ent %>%
  tax_glom(taxrank = "Family") %>%                     # agglomerate at trophic level
  transform_sample_counts(function(x) {x/sum(x)} ) %>% # Transform to rel. abundance
  psmelt() %>%                                         # Melt to long format
  arrange(Family)                                      # Sort data frame alphabetically by trophic mode

# checking the dataframe that we now created
head(mdata_top)

# re-order how site and species appear in the graph
mdata_top$Site <- factor(mdata_top$Site,levels = c("native", "mixed", "perturbated"))
mdata_top$Host <- factor(mdata_top$Host,levels = c("Quercus", "Juniperus"))

# Now plot: OTU relative abundance trophic mode by site, type of sample and plant host
ggplot(mdata_top, aes(x = Site, y = Abundance, fill = Family)) + 
  #facet_grid(time~.) +
  geom_bar(stat = "identity")  +
  # Remove x axis title, and rotate sample lables
  theme(axis.title.x = element_blank(),
        axis.text.x=element_text(angle=90,hjust=1,vjust=0.5)) + 
  
  # add labels
  guides(fill = guide_legend(reverse = TRUE, keywidth = 1, keyheight = 1)) +  # modifying the legend
  ylab("OTU relative abundance") +
  ggtitle("TOP OTUs by Family - relative abundance") + facet_wrap("Host")

# most abundant merging families

subset.fam<- subset_taxa(subset.texcoco.binary, Trophic %in% "a__sap") 
subset.fam
tax_table(subset.fam)

subset.fam <- tax_glom(subset.fam, taxrank = "Family")
subset.fam
tax_table(subset.fam)

taxa_sums(subset.fam) [1:10]
any(taxa_sums(subset.fam) == 0)
subset.fam <- prune_taxa(taxa_sums(subset.fam) > 0, subset.fam)
any(taxa_sums(subset.fam) == 0)
taxa_sums(subset.fam) [1:10]
subset.fam

#In case you need to get top 50 (for ecm it comes out to only 31 families, for am only 14, so is not needed)
Top <- names(sort(taxa_sums(subset.fam), TRUE)[1:50])
ent <- prune_taxa(Top, subset.fam)

ent <- subset.fam
taxa_sums(ent)
taxa_names(ent)
tax_table(ent)
ent

mdata_top <- ent %>%
  tax_glom(taxrank = "Family") %>%                     # agglomerate at trophic level
  transform_sample_counts(function(x) {x/sum(x)} ) %>% # Transform to rel. abundance
  psmelt() %>%                                         # Melt to long format
  arrange(Family)                                      # Sort data frame alphabetically by trophic mode

# checking the dataframe that we now created
head(mdata_top)

# re-order how site and species appear in the graph
mdata_top$Site <- factor(mdata_top$Site,levels = c("native", "mixed", "perturbated"))
mdata_top$Host <- factor(mdata_top$Host,levels = c("Quercus", "Juniperus"))

# Now plot: OTU relative abundance trophic mode by site, type of sample and plant host
ggplot(mdata_top, aes(x = Site, y = Abundance, fill = Family)) + 
  #facet_grid(time~.) +
  geom_bar(stat = "identity")  +
  # Remove x axis title, and rotate sample lables
  theme(axis.title.x = element_blank(),
        axis.text.x=element_text(angle=90,hjust=1,vjust=0.5)) + 
  
  # add labels
  guides(fill = guide_legend(reverse = TRUE, keywidth = 1, keyheight = 1)) +  # modifying the legend
  ylab("OTU relative abundance") +
  ggtitle("TOP OTUs by Family - relative abundance") + facet_wrap("Host")





#### #Finding most species-rich families  ####

subset<- subset_taxa(subset.texcoco.binary, Trophic %in% "a__sap")
subset
tax_table(subset)

spprich<-subset %>% 
  psmelt %>%
  group_by(Family) %>% 
  summarize(OTUn = (unique(OTU) %>% length)) %>% 
  arrange(desc(OTUn))

subset<- subset_taxa(subset.texcoco.binary, Trophic %in% "a__sap") 
subset
subset<- subset_taxa(subset, Family %in% c("f__ Herpotrichiellaceae"))
subset
tax_table(subset)


#### mvabund and glm for most abundant OTUs #### 

##### subset

ent <- subset.texcoco.binary

Top50OTUs <- names(sort(taxa_sums(ent), TRUE)[1:50])
ent50 <- prune_taxa(Top50OTUs, ent)
ent50
taxa_names(ent50)
ntaxa(ent50)
taxa_sums(ent50)


#What data? 
ent50
tax_table(ent50)
sample_data(ent50)

abun_table <- otu_table(ent50) 
abun_table

#transform to binary table in case using agglomeration (e.g. at family level using tax_glom)
abun_table = transform_sample_counts(abun_table, function(x, minthreshold=0){
  x[x > minthreshold] <- 1
  return(x)})
head(otu_table(abun_table))

#if not, procede:

abun_table = t (abun_table)

meta_table <- sample_data(ent50) 
meta_table

abun_sample_table <- data.frame(abun_table, meta_table)
abun_sample_table

mvabund_table <- mvabund(abun_sample_table [,1:65]) #format table 
mvabund_table

mod2 <- manyglm(mvabund_table ~ abun_sample_table$Host , family="binomial")
plot(mod2)

#manyglm <- manyglm(mvabund ~ pH * factor(Elevation), family="binomial")

anova(mod2)
anova(mod2, p.uni="adjusted")


