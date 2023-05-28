whichInterval <- function(sequence, number) {
  len <- length(sequence)
  
  if (sequence[1] > sequence[2]) {
    increasing <- 'FALSE'
  } else {
    increasing <- 'TRUE'
  }
  
  switch(increasing,
         'TRUE' = {
           for (i in 1:(len-1)) {
             if (sequence[i] <= number && sequence[i+1] > number) {
               n <- i
               return(n)
             } else if (sequence[1] > number) {
               n <- 1
               return(n)
             } else if (sequence[len] < number) {
               n <- len-1
               return(n)
             }
           }
         },
         'FALSE' = {
           for (i in 1:(len-1)) {
             if (sequence[i] >= number && sequence[i+1] < number) {
               n <- i
               return(n)
             } else if (sequence[1] < number) {
               n <- 1
               return(n)
             } else if (sequence[len] > number) {
               n <- len-1
               return(n)
             }
           }
         }
  )
}
