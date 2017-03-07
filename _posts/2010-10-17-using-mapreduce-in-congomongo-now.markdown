---
title: Using MapReduce in Congomongo Now
redirect_from:
  - /2010/10/17/using-mapreduce-in-congomongo-now.html
  - /blog/2010/10/17/using-mapreduce-in-congomongo-now/
---

My patch to Congomongo that adds support for running MapReduce jobs in
MongoDB [was accepted][], but that code hasn't yet been pushed out to
the official Congomongo SNAPSHOT jar in Clojars.

Until that happens, if you'd like to use the new MapReduce code, you
can use [my version][].

If you're using Leiningen, add this to your `project.clj`:

``` clojure
[org.clojars.christophermaier/congomongo "0.1.3-SNAPSHOT"]
```

And here's the dependency information for Maven:

``` xml
<dependency>
  <groupId>org.clojars.christophermaier</groupId>
  <artifactId>congomongo</artifactId>
  <version>0.1.3-SNAPSHOT</version>
</dependency>
```

[was accepted]:http://christophermaier.name/2010/08/23/patches-accepted.html
[my version]:http://clojars.org/org.clojars.christophermaier/congomongo
