---
title: Using Idiomatic Clojure, Part 1 - comp
redirect_from:
  - /2010/10/12/using-idiomatic-clojure-part-1.html
  - /blog/2010/10/12/using-idiomatic-clojure-part-1/
---

As I read the Clojure code of others, I come across better ways to write my own code.  Today's example comes from
[The Joy of Clojure][] by Michael Fogus and Chris Houser.

I often find myself writing anonymous functions along the lines of

``` clojure
#(not (vector? %))
```

to act as filters in various places (`filter`, `for`, `take-while`, etc.).  I always thought it looked a bit gnarly like that.  Fortunately, there is a better way, using the `comp` function.

According to the [documentation string], `comp` takes a number of functions and returns a new function that is the composition of all of them.  I've used `comp` a few other places before, but for some reason, it didn't "click" that I could use it in this situation, too.  With it, the above code transforms into the much cleaner-looking

``` clojure
(comp not vector?)
```

Looks much better without the anonymous function trappings, yes?

*Update*: I just came back to this post after a long time... Now I probably wouldn't even use `comp` here, opting instead for

``` clojure
(complement vector?)
```

It keeps getting shorter!

[The Joy of Clojure]: http://manning.com/fogus/
[documentation string]: http://clojure.github.com/clojure/clojure.core-api.html#clojure.core/comp
