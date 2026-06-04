set.seed(111)

peeps <- c(
    "Nick",
    "Gerry",
    "Kate",
    "Chitra",
    "Saras",
    "Yuval",
    "Dave",
    "John",
    "August"
)
n_peeps <- length(peeps)

driver <- peeps[sample.int(n_peeps)]
# shuffle such that the person driving is the person documenting the week after
documenter <- driver[c(2:length(peeps),1)]

