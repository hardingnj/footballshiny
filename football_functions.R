### FUNCTIONS ######################################################################################
yaml.to.df <- function(table){
	x<-sapply(table,unlist);
	y<-as.data.frame(t(x)[,-1]);	
	# here add col names if we can guess format!
	return( y );
	}

# FUNCTION: COUNT.TOP.TEAMS: carries out a sliding window analysis of last x years
# index is the year to start from
# years to have as sliding window
# count how many teams to examine.
count.top.teams <- function(league.list, index, years=10, count=4,values=F){
	if(index - years < 0) return (NA);
	lists <- lapply(league.list[(index-years+1):index],function(x) x[1:count,1]) 
	teams <- levels(factor( unlist(lists ) ))
	if(values) return( teams );
	return( length(teams) );
	}

get.stats <- function( league ) {

	}

# For a given year, (index) count survial rate of newly promoted teams that got relegated. 
calculate.churn <- function(league.list, index, years=1, values=F){

	if(index + years > length(league.list)|| index <= 1) return( NA );	

	prev.year <- league.list[[index - 1]][,1];
	this.year <- league.list[[index]][,1];
	fut.year <- league.list[[index + years]][,1];
	
	new.teams <- this.year[!this.year %in% prev.year]; 
	# return how many survived
	sum(new.teams %in% fut.year)/length(new.teams);
	}
# For a given year, (index) count the proportion of newly promoted teams that got relegated. 
calculate.predictability.index <- function(league.list, index, years=1, values=F){

	if(index + years > length(league.list)|| index <= 1) return( NA );	

	prev.year <- league.list[[index - 1]][,1];
	this.year <- league.list[[index]][,1];
	
	this.year <- as.character(this.year);
	prev.year <- as.character(prev.year);

	new.teams <- which( !this.year %in% prev.year );
	for(i in 1:length(new.teams)) { this.year[new.teams[i]] <- paste('M', i); }

	old.teams <- which( !prev.year %in% this.year );
	for(i in 1:length(old.teams)) { prev.year[old.teams[i]] <- paste('M', i); }

	cor.test( 1:length(prev.year), match( prev.year, this.year ), method='spear')$estimate;
	}

