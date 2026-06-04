set.seed(111)

peeps <- c(
    "Nick",
    "Gerry",
    "Kate",
    "Chitra",
    "Saras",
    "Yuval",
    "Dave",
    "John"
)
n_peeps <- length(peeps)

screen_sharer <- peeps[sample.int(n_peeps)]
minute <- peeps[sample.int(n_peeps)]

