# adding 
"+.duration" <- "+.POSIXt" <- "+.difftime" <- "+.Date" <- function(e1, e2){
	
	if (is.timepoint(e1)) {
		if (is.timepoint(e2))
			stop("binary '+' not defined for adding dates together")
		else
			add_duration_to_date(e1, e2)
	}

	else if (is.timeperiod(e1)) {
		if (is.timepoint(e2))
			add_duration_to_date(e2, e1)
		else if (is.timeperiod(e2))
			add_duration_to_duration(e1, e2)
		else
			add_number_to_duration(e1, e2)
	}

	else if (is.numeric(e1)) {
		if (is.timepoint(e2))
			add_duration_to_date(e2, e1)
		else if (is.timeperiod(e2))
			add_number_to_duration(e2, e1)
		else stop("Unknown object class")
		}
}


add_duration_to_date <- function(date, timeperiod) {
	dur <- as.duration(timeperiod)
	
	days <- just_seconds(dur) %/% 86400
	seconds <- just_seconds(dur) %% 86400
	
	second(date) <- second(date) + seconds
	yday(date) <- yday(date) + days
	month(date) <- month(date) + just_months(dur)
	date
}

add_duration_to_duration <- function(period1, period2) {
	dur1 <- as.duration(period1)
	dur2 <- as.duration(period2)
	
	seconds <- just_seconds(dur1) + just_seconds(dur2)
	months <- just_months(dur1) + just_months(dur2)
	
	new_duration(second = seconds, month = months)
}

add_number_to_duration <- function(dur, num){
	if (is.difftime(dur)){
		num <- structure(num, units = units(dur), class = "difftime")
		make_difftime( as.numeric(num, units = "secs") +  as.numeric(dur, units = "secs"))
	}
	else if (is.duration(dur))
		add_duration_to_duration(dur, num)
	else
		stop("unrecognized time period class")
}


make_difftime <- function (diff) {  
	seconds <- abs(diff)
    if (seconds < 60) 
        units <- "secs"
    else if (seconds < 3600)
        units <- "mins"
    else if (seconds < 86400)
        units <- "hours"
    else if (seconds < 604800)
    	units <- "days"
    else units <- "weeks"
    
    switch(units, secs = structure(diff, units = "secs", class = "difftime"), 
    mins = structure(diff/60, units = "mins", class = "difftime"), 
    hours = structure(diff/3600, units = "hours", class = "difftime"), 
    days = structure(diff/86400, units = "days", class = "difftime"), 
    weeks = structure(diff/(604800), units = "weeks", class = "difftime"))
}


"*.duration" <- function(e1, e2){
    if (is.duration(e1) && is.duration(e2)) {
    NA
  } else if (is.duration(e1)){
    multiply_duration_by_numeric(e2, e1)
  } else if (is.duration(e2)) {
    multiply_duration_by_numeric(e1, e2)
  } else {
    base::'*'(e1, e2)
  }
}  


multiply_duration_by_numeric <- function(num, dur){
	seconds <- just_seconds(dur)
	months <- just_months(dur)
	new_duration(month = num * months, second = num * seconds)
}

"/.duration" <- function(e1, e2){
    if (is.duration(e1) && is.duration(e2)) {
    NA
  } else if (is.duration(e1)){
    divide_duration_by_numeric(e2, e1)
  } else if (is.duration(e2)) {
    divide_duration_by_numeric(e1, e2)
  } else {
    base::'*'(e1, e2)
  }
}  


divide_duration_by_numeric <- function(num, dur){
	seconds <- just_seconds(dur)/num
	months <- just_months(dur)/num
	new_duration(month = months, second = seconds)
}

  

"-.duration" <- "-.POSIXt" <- "-.difftime" <- "-.Date" <- function(e1, e2){
	if (missing(e2))
		-1 * e1
	else if(is.timepoint(e1) && is.timepoint(e2))
		as.duration(difftime(e1, e2))
	else if (is.POSIXt(e1) && !is.timeperiod(e2))
		structure(unclass(as.POSIXct(e1)) - e2, class = c("POSIXt", "POSIXct"))
	else		
		e1  + (-1 * e2)
}

get_duration <- function(date1, date2) {
	months1 <- year(date1) * 12 + month(date1)
	months2 <- year(date2) * 12 + month(date2)
	
	secs1 <- mday(date1)*3600*24 + hour(date1)*3600 + minute(date1)*60 + second(date1)
	secs2 <- mday(date2)*3600*24 + hour(date2)*3600 + minute(date2)*60 + second(date2)
	
	new_duration(month = months1 - months2, second = secs1 - secs2)

}


