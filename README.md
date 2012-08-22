neo4j-R
=======

Neo4j to R script that allows to call Gremlin and Cypher queries from R script and return data frames.

The queryGremlin function allows to use parameters instead of using paste to build a query string. For example:

    userid <- 123
    min_age <- 20

    data <- queryGremlin("g.idx('user')[[userid:$userid]].out.filter{it.age >= $age}",list(userid=userid,age=min_age))

The data dataframe contains colums named after the properties of the returned object. For example:

    data$age