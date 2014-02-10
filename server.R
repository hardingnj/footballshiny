library(shiny)
library(datasets)
library(RColorBrewer);
library(yaml);
library(ggplot2);

source('football_functions.R');

### GET DATA #######################################################################################

all.leagues <- list(
	England = 'england_data.yaml',
	Scotland = 'scotland_data.yaml',
	France = 'france_data.yaml',
	Germany = 'germany_data.yaml',
	Spain = 'spain_data.yaml',
	Italy = 'italy_data.yaml'
	);
setwd('football_data');
all.data.yaml <- lapply( all.leagues, yaml.load_file, as.named.list=T)

all.data <- lapply(
	all.data.yaml, 
	function(league.yaml) {
		lapply( league.yaml, yaml.to.df );
		}
	);

### ANALYSIS ######################################################################################
all.metrics <- lapply(
	all.data,
	function( country ){
		# country is a list of each year.
		out <- sapply(1:length(country), function(index) { 
			c( calculate.churn( country, index), calculate.predictability.index( country, index) );
			});
		#do.call(rbind, out);
		out <- t(out);
		rownames(out) <- names(country);
		colnames(out) <- c('Churn', 'Predictability');
		return(out);
		}); 

# combine different countries into a single df. Probably a dumb way to do this, but can't think of a one liner...
temp.list <- list();
for(country in names(all.metrics)){
	new <- as.data.frame( all.metrics[[country]] );
	new$country <- country;
	new$year <- as.numeric(rownames(new));
	temp.list[[country]] <- new;
	}
combined.results.frame <- do.call(rbind, temp.list);
combined.results.frame$country <- factor( combined.results.frame$country);
rownames( combined.results.frame ) <- NULL;

# Define server logic required to plot various variables against mpg
# output: caption + lineplot
shinyServer(function(input, output) {

  # Compute the forumla text in a reactive expression since it is 
  # shared by the output$caption and output$mpgPlot expressions
  headerText <- reactive({
    paste("Showing data for years", input$range[1], "to", input$range[2])
  })

  # Return the formula text for printing as a caption
  output$caption <- renderText({
    headerText()
  })
  
  # get country data:
  include.countries <- reactive({c(
      input$england,
      input$scotland,
      input$france,
      input$italy,
      input$germany,
      input$spain
    )})

  req.subset <- reactive({subset(
    combined.results.frame, 
    year > input$range[1] & year < input$range[2] & country %in% c('England', 'Scotland', 'France', 'Italy', 'Germany', 'Spain')[which(include.countries())]
  )})
    
  output$predictabilityDesc <- renderText({'Predictibility is the correlation between the ranks of the current year and the previous year. Uniform random order will correspond to a score of 0. Perfect +ve/-ve correlation to +1/-1. Newly promoted teams replace the previously relegated team positions in the most parsimious order.'})

  output$churnDesc <- renderText({'Churn is the proportion of newly promoted teams that survive relegation in their first season.'})
  # Generate a plot of the requested years
  output$lineplot <- renderPlot({ 

    # option to alter colour scheme??
    l <- length(unique(req.subset()[,'country']))
    colour.scheme = brewer.pal(l, 'Set1')
    
    plot <- ggplot(
      req.subset(), 
      aes(x = year, y = Predictability, group = country, color = country)
      ) + geom_line(alpha=0.5) + scale_color_manual(values=colour.scheme)
    # smooth?
    if(input$smooth) { plot <- plot + geom_smooth(size=2, se=F) }
    print(plot)
  })

  # Generate a plot of churn!
  output$churn <- renderPlot({ 

    # option to alter colour scheme??
    l <- length(unique(req.subset()[,'country']))
    colour.scheme = brewer.pal(l, 'Set1')
    
    plot <- ggplot(
      req.subset(), 
      aes(x = year, y = Churn, group = country, color = country)
      ) + geom_line(alpha=0.5) + scale_color_manual(values=colour.scheme)
    # smooth?
    if(input$smooth) { plot <- plot + geom_smooth(size=2, se=F) }
    print(plot)
  })
})

