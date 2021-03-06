#' Grab Google Trend Data
#' 
#' A function to grab \href{http://www.google.com/trends/}{Google Trend} data 
#' using the \pkg{gtrendsR} package \url{https://github.com/dvanclev/gtrendsR}.
#' 
#' @param username Your Gmail/Google name (e.g., \code{tyler.rinker@@gmail.com}).
#' @param password Your Gmail/Google password.
#' @param phrases A character vector of phrases to look up.
#' @param geo A locations to search within.
#' @return Returns a list of lists (one list for each search term):
#' \item{query}{A character... }
#' \item{meta}{A character... }
#' \item{trend}{A data.frame... }
#' \item{regions}{A list... }
#' \item{topmetros}{A list... }
#' \item{cities}{A list... }
#' \item{searches}{A list... }
#' \item{rising}{A list... }
#' \item{headers}{A character... }
#' @references \url{https://github.com/dvanclev/gtrendsR} 
#' \url{http://www.google.com/trends}
#' @export
#' @examples
#' \dontrun{
#' (out <- gtrend_scraper("tyler.rinker@@gmail.com", "password", "dog bite"))
#' 
#' library(gtrendsR)
#' as.zoo(out[[1]])
#' }
gtrend_scraper <- function(username, password, phrases, geo = "US"){

    gtrends <- NULL
    
    reqcheck <- suppressWarnings(require("gtrendsR"))

    if (!reqcheck) {

        message("gtrendsR package not found.\nShould I attempt to get from GitHub?")
        ans <- menu(c("Yes", "No"))
        if (ans == "1") {
            devtools::install_bitbucket("persican/gtrendsR")
        }
        reqcheck <- require("gtrendsR")
        if (!reqcheck) stop("Could not load or install gtrendsR package")
    }

    ch <- gtrendsR::gconnect(username, password)
    phrases <- sprintf("\"%s\"", gsub("[-,]", " ", phrases))
  
    output <- setNames(lapply(phrases, function(x) {
            out <- try(gtrends(ch, query = x , geo = geo))
            if (inherits(out, "try-error")) return(NULL)
            class(out ) <- "gtrend_scraper_element"
            out
        }
    ), phrases)  
    
    removed <- sapply(output, is.null)
    if (any(removed)) {
         output <- output[!removed]   
         message("No trend data for:\n", paste(names(removed)[removed], 
             collapse=", "))
    }
    
    class(output) <- c("gtrend_scraper", class(output))
    output
}


