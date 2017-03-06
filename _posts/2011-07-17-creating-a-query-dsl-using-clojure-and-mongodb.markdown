---
title: Creating a Query DSL using Clojure and MongoDB
redirect_from:
  - /2011/07/17/creating-a-query-dsl-using-clojure-and-mongodb.html
  - /blog/2011/07/17/creating-a-query-dsl-using-clojure-and-mongodb/
---

One of the nice things about [MongoDB][] (particularly when using it in Clojure via the [Congomongo][] library) is that its map-based query language is so amenable to the creation of a domain-specific language, or [DSL][].   Creating and manipulating maps is like breathing in Clojure, so it is trivial to decompose the different query requirements of your application into a small collection of simple functions that can be used to create a rather fluent domain-specific language.  The data-structure-based query language of MongoDB makes this possible (or at least easier; it would be much more difficult to do in a string-based language like SQL).

Not only does creating a DSL make querying easy (particularly with complex conditions), but it also insulates your application from change in a few important ways.  Especially in the initial, exploratory stages of a project, it is common to change and evolve a data schema, and NoSQL environments make this very simple.  Using a DSL will shield your code from these changes; you only need to change the DSL "atoms" that the schema change affects.

Another benefit is that you can more easily change out your underlying database when and if the need arises.  With SQL databases, this is not as big of a problem.  SQL is a standard, and we have things like JDBC to provide (more or less) equivalent interaction with SQL databases (yes, reality is more complicated, but we're comparing to swapping out one NoSQL database for another).  There is no corresponding "NoSQL standard", but even if there were, there are so many different kinds of NoSQL databases (document, graph, key-value, column store, etc.) that there probably *can't* be any sort of meaningful general abstraction like JDBC that covers them all.  However, when you create a query DSL, you don't need to create a completely general abstraction over your underlying database; you just need one that works for your project.

I recently implemented a simple DSL for a project at work that we use for querying complex proteomics and genomics data.  I'll illustrate a small bit of the DSL here to describe the general approach and show some of the benefits.

# Background

In a nutshell, we're querying to find certain features within the human genome.  The raw data are called "peptide / spectrum matches", or a "PSMs".  They have sequences, scores, and genomic coordinates, among other things, and we query to find PSMs based on various combinations of these criteria.  We store the data in MongoDB, with one document per PSM, and query using Congomongo.

If you want to find all PSMs that have a particular peptide sequence, you'd have a query map like this;

``` clojure
{:peptide.sequence "GLYQRPHDSTRFK"}
```

If you want to further restrict that to only results that have an expectation value of no greater than 0.01, you'd use this:

``` clojure
{:peptide.sequence "GLYQRPHDSTRFK"
 :scores.e-value {:$lte 0.01}}
```

Further restricting results to lying within a region of a chromosome would be done like this:

``` clojure
{:peptide.sequence "GLYQRPHDSTRFK"
 :scores.e-value {:$lte 0.01}
 :location.chromosome "X"
 :location.strand "+"
 :location.start {:$gte 12345}
 :location.stop {:$lte 34567}}
```

## Creating the DSL

In reality, there are many more criteria, but by this point a pattern suggests itself.  Each individual criterion will be a map, while each query will be a simple merging of these maps.  Let's start with the `query` function first, which we'll use to generate the final query map (not actually perform the query).

``` clojure
(defn query [& criteria]
  (apply merge criteria))
```

That's it.  Now for the rest of the criteria:

``` clojure
(defn matches-peptide [peptide]
  {:peptide.sequence peptide})

(defn with-e-value-cutoff [cutoff]
  {:scores.e-value {:$lte cutoff}})

(defn in-region [{:keys [chromosome strand start stop]}]
  {:location.chromosome chromosome
   :location.strand strand
   :location.start {:$gte start}
   :location.stop {:$lte stop}})
```

All very straightforward.  Now, when we want to create a final query, we write something like this:

``` clojure
(query (matching-peptide "GLYQRPHDSTRFK")
       (with-e-value-cutoff 0.001)
       (in-region {:chromosome "X"
                   :strand "+"
                   :start 12345
                   :stop 34567}))
```

That's pretty readable.  We've gained a lot of flexibility, too, since we've decoupled the *semantic* meaning of a query from the underlying *syntactic* realities of my data schema and database.  We're free to change how we structure the underlying data (something we've already done several times in the course of this project!).  For instance, maybe we'll want to represent a peptide as a plain String instead of a complex object like we have here.  We only need to change one line of code for the queries to keep working.

We can go further, extending our DSL to actually retrieving the results.

``` clojure
(find-psms [& criteria]
  (fetch PSM-COLLECTION :where (apply query criteria)))
```

Here, our application no longer even needs to be aware of which collection we're searching.  The code to retrieve our results is now:

``` clojure
(find-psms (matching-peptide "GLYQRPHDSTRFK")
           (with-e-value-cutoff 0.001)
           (in-region {:chromosome "X"
                       :strand "+"
                       :start 12345
                       :stop 34567}))
```

That's almost exactly what the equivalent request would be in plain English.  You don't get much simpler.

## Conclusion

Obviously what I have shown here is pretty basic stuff, and not at all difficult to implement.  There's a lot more that the application will have to do, including paging, limiting, sorting, as well as more complicated queries.  However, there's not much more functionality that needs to be added that is significantly different from what's been shown.  And look what has been gained: an almost-English query language that insulates our application not only from the specific modeling choices we've made, but also from the specific database system we are using.  This last point is particularly nice in my case, as I plan to migrate from MongoDB to a Neo4j graph database in the near future.  Using this DSL internally is going to make that task significantly more straightforward.

**Update**: Aaron Crow mentioned this post in his presentation [Clojure on Mongo: Fun and Easy with CongoMongo](https://github.com/dirtyvagabond/mongola), presented at Mongo LA on 19 January 2012.  Thanks, Aaron!

[DSL]: http://en.wikipedia.org/wiki/Domain-specific_language
[MongoDB]: http://www.mongodb.org
[Congomongo]: https://github.com/aboekhoff/congomongo
