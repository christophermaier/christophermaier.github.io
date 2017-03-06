---
title: Not-So-Private Clojure Functions
redirect_from:
  - /2011/04/30/not-so-private-clojure-functions.html
  - /blog/2011/04/30/not-so-private-clojure-functions/
---

If you've been programming in Clojure for longer than, oh, about 5 minutes, you probably already know how `defn` creates a publicly accessible function in a namespace, while `defn-` creates a private one.  If you're outside the original namespace and you try to call a private function, you will get the smackdown.

Here's a simple demonstration.  We'll create two functions, one public and one private, in the `user` namespace:

```clojure
user> (defn hello []
        "Hello World")
#'user/hello
user> (hello)
"Hello World"
user> (defn- secret []
        "TOP SECRET")
#'user/secret
user> (secret)
"TOP SECRET"
```

If we switch to the `other` namespace, though, we can only use the public one:

```clojure
user> (ns other)
nil
other> (user/hello)
"Hello World"
other> (user/secret)
```

Oops!

    var: #'user/secret is not public
      [Thrown class java.lang.IllegalStateException]

However, you _can_ get around the private flag; all you need to do is refer directly to the function's var:

```clojure
other> (#'user/secret)
"TOP SECRET"
```

You can make it a bit easier by creating a var in your new namespace that points to the private one:

```clojure
other> (def secret #'user/secret)
#'other/secret
other> (secret)
"TOP SECRET"
```

Now why the hell would you ever want to do this?  In general, you probably shouldn't, at least with other people's code.  Private functions are private for a reason; they're not part of any public API, so they could disappear or change at a moment's notice.  However, it can come in handy when you're testing your own code.  Often, I'll have a few private functions that do something useful within a namespace, but really have no business being used anywhere else.  Sometimes when I'm testing my public functions, though, I'll find myself needing these private functions to either set things up, create test data, or otherwise verify that things turned out alright.

You could also create a separate namespace for all your private helper functions (making them public this time), and then only ever pull that namespace into your main and test namespaces (Fogus and Chouser describe this approach in Section 9.1.2 of [The Joy of Clojure][]; conveniently this chapter is also available as a [free download][]).  If you've only got a handful of these functions, though, this var shadowing trick is pretty straightforward.

[The Joy of Clojure]:http://joyofclojure.com/
[free download]:http://www.manning.com/fogus/Sample-Ch9.pdf
