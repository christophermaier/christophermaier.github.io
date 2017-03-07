---
title: The Path to MapReduce with Congomongo
redirect_from:
  - /2010/08/21/the-path-to-map-reduce-with-congomongo.html
  - /blog/2010/08/21/the-path-to-map-reduce-with-congomongo/
---

I've recently started a Clojure / [MongoDB][] project at work to help
us with our proteogenomic annotation work.  Naturally, I'm using
[Congomongo][] to interact with the database.  It's a great wrapper
for the [MongoDB Java driver][], written in a very nice functional
style.

Lately I've been looking into the [map-reduce][] capabilities of
MongoDB and have been trying to figure out how to make it work from
Clojure.  Looking at the Congomongo API, I came across the
[server-eval][] function, which looked like a promising place to
start.

I decided to kick the tires a bit:

``` clojure
user> (use 'somnium.congomongo)
nil
user> (server-eval "function(){return 3+3}")
6.0
```

So far, so good.  `server-eval` takes a string of JavaScript code
defining a function with no arguments.  This gets sent over to
MongoDB, where it gets evaluated and run.

Under the hood, Congomongo is passing off to the MongoDB Java driver's
[com.mongodb.DB.doEval][] method, which effectively runs this command
(as typed into the MongoDB JavaScript console):

``` javascript
> db.$cmd.findOne({$eval:"function(){return 3+3}"})
{ "retval" : 6, "ok" : 1 }
```

It's calling the special [eval][] command in MongoDB and passing the
result back.  Check out the [MongoDB Command Documentation][] as well
as the [List of Database Commands][] for more on how this stuff works
out.

That's all well and good, but it doesn't actually help for kicking off
a map-reduce job from Clojure.  As the MongoDB documentation [says][]:

> Use map/reduce instead of db.eval() for long running jobs. db.eval blocks other operations!

That's a bummer.  The only facility Congomongo currently provides for
executing code server-side is the aforementioned `server-eval`
function, which only uses the MongoDB `eval` command; `mapReduce` is a
separate command.  It's actually pretty straightforward to add support
for map-reduce in Congomongo, though.  Though we could easily use
`com.mongodb.DB.doEval` to perform our map-reduce job, the Java driver
helpfully provides [com.mongodb.DBCollection.mapReduce][], which
provides a little bit of sugar for such things.  Studying the code for
some other Congomongo functions leads to this solution:

[My Congomongo fork, now with map-reduce!][]

The nice thing about this function is that it fully exposes all the
capabilities of the native MongoDB map-reduce framework.  Want to add
a finalize function?  No problem!  Want sorted or limited query
results?  Done!  Want results or just the collection?  You got it.
There's lots of documentation for how it all works; the test cases
will help, too.

[MongoDB]: http://www.mongodb.org
[Congomongo]: http://www.github.com/somnium/congomongo
[MongoDB Command Documentation]: http://www.mongodb.org/display/DOCS/Commands
[map-reduce]: http://www.mongodb.org/display/DOCS/MapReduce
[server-eval]: http://github.com/somnium/congomongo/blob/6fc8345a35fa1aa1ba27efa76a4363265b67cad2/src/somnium/congomongo.clj#L316
[com.mongodb.DB.doEval]:http://github.com/mongodb/mongo-java-driver/blob/r2.0/src/main/com/mongodb/DB.java#L145
[eval]:http://www.mongodb.org/display/DOCS/Server-side+Code+Execution
[List of Database Commands]: http://www.mongodb.org/display/DOCS/List+of+Database+Commands
[says]: http://www.mongodb.org/display/DOCS/Server-side+Code+Execution#Server-sideCodeExecution-Using%7B%7Bdb.eval%28%29%7D%7D
[com.mongodb.DBCollection.mapReduce]: http://github.com/mongodb/mongo-java-driver/blob/r2.0/src/main/com/mongodb/DBCollection.java#L613
[MongoDB Java driver]: http://github.com/mongodb/mongo-java-driver
[My Congomongo fork, now with Map-Reduce!]: http://github.com/christophermaier/congomongo/commit/df433fc11ab76c48dcfe8fa77c4bf19227161a92
