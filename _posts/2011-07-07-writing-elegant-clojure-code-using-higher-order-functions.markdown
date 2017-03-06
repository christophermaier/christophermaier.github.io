---
title: Writing Elegant Clojure Code Using Higher-Order Functions
redirect_from:
  - /2011/07/07/writing-elegant-clojure-code-using-higher-order-functions.html
  - /blog/2011/07/07/writing-elegant-clojure-code-using-higher-order-functions/
---

Back when I first started writing [Clojure][clojure] code, I heard lots about the use of [_higher-order functions_][HOF] (also known as _HOFs_).  Since functions are first-class language members in Clojure, you can do things like pass them as arguments or return them from function calls.  Any function that accepts or produces another function in this way is a higher-order function.  This allows you to write some very powerful and consise code, because you can capture the general _form_ of a computation, while allowing its specific _behavior_ to be determined at runtime by the user.  You basically say to the function caller "I'm going to give you _X_, but I'll make it however you tell me to".

So I knew about all this, and could see how powerful a technique it could be, but I didn't fully _grok_ the whole concept yet.  Coming from a mainly Java background at the time, I hadn't had any experience with first-class functions, and still approached everything from a procedural and object-oriented background.  Using HOFs was a bit of an alien concept.

Clojure is littered with HOFs; if you're new to the language, you've already used them, perhaps without realizing it.  The [`map`][map] function is probably the archetype of a HOF.  It iterates through a sequence of items, applying a function to each one in turn, and returns a sequence of the results.  It says "I'm going to transform each element of this sequence, but I'll do it however you tell me to".  So, you can pass in the `inc` function to `map` to increment each number in a list, like so:

``` clojure
(map inc [1 2 3 4 5])
; => (2 3 4 5 6)
```

You can also use an anonymous function (because hey, it's still a function), allowing you to, say, multiply each number in a list by five:

``` clojure
(map #(* 5 %) [1 2 3 4 5])
; => (5 10 15 20 25)
```

All well and good, but this is all still pretty basic.  As I said, these kinds of functions are all over Clojure, and you quickly figure out how to use them, out of necessity if nothing else; it's difficult to do _anything_ in Clojure without them!  Soon I realized that it wasn't the function-_accepting_ HOFs that I hadn't quite gotten; it was the function-_generating_ HOFs that I didn't fully appreciate.  Clojure has several of these functions, too, and mastering them really allows you to create some elegant constructs.  I'll mainly talk about [`partial`][partial] and [`comp`][comp], but there are also [`juxt`][juxt] and [`complement`][complement], and I may have overlooked others.  And of course, you can always make your own.

The simplest of Clojure's built-in function generators is probably `partial`, which lets you "prime" an existing function with some number of arguments.  For example, you could make a "quintupler" function like we used above, but using `partial` like this:

``` clojure
(def quintuple (partial * 5))
(map quintuple [1 2 3 4 5])
; => (5 10 15 20 25)
```

This `quintuple` function is just the standard multplication function (`*`), already primed with a first argument of `5` (it is exactly equivalent to `(fn [x] (* 5 x))`).  Any other arguments passed into `quintuple` will also be multiplied together, and then multiplied by 5.  (Though I've broken `quintuple` out as a separate function here, it is more idiomatic to use it directly, like `(map (partial * 5) [1 2 3 4 5])`.)

The `comp` function is a little trickier, but not by much.  Short for "compose", it carries out the functional composition you learned about in high school algebra class (you remember _f(g(h(x))_, right?).  So basically, `(comp f g h)` creates a function that will apply the function `h` to its arguments, then apply `g` to the result, then apply `f` to the result of that.  Of course, you can supply as many functions as you like.  In this way, it's similar to (but _not_ the same as!) Clojure's threading macros (`->` and `->>`).

Actually, this whole post is basically an excuse to share the fun trick I recently discovered.  Say you need to condense a sequence of pairs into a map.  No problem, right?  We'll just use `into`.

``` clojure
(def pairs [[:one 1] [:two 2] [:three 3]])
(into {} pairs)
; => {:one 1, :two 2, :three 3}
```

Now for a wrinkle: what if a key repeats?

``` clojure
(def pairs [[:one 1] [:two 2] [:three 3]
            [:rest 4] [:rest 5] [:rest 6]])
(into {} pairs)
; => {:one 1, :two 2, :three 3, :rest 6}
```

That's no good; each successive pair with a duplicated key will overwrite the previous values.  What you really want is to create a _sequence_ if there are multiple values, but not if there's only one.  HOFs to the rescue!

``` clojure
(apply merge-with
       (comp vec flatten vector)
       (map (partial apply hash-map)
            pairs))
; => {:rest [4 5 6], :three 3, :two 2, :one 1}
```

That did it!  The magic happens with `(comp vec flatten vector)`.  This generates  the function that `merge-with` will use to combine the pairs together (once we turn them into maps, that is).  If a key is already present, the function gets called with both the existing value and the value to be added.  This can be a bit tricky to grasp at first, so I'll walk through what's happening step by step.

Keep in mind that our merge function, `(comp vec flatten vector)` is only called when there is already a value for a given key.  If it's the first time we're merging a particular key, there will be one value, but for all subsequent times, there will be a vector of values.  We thus have two cases to examine.  Since the `comp` is just composing `vec`, `flatten`, and `vector`, I'll split out each operation to show what happens.

First, we'll look at what happens the first time we merge a value.  We'll call the pre-existing value `:A` and the incoming (to-be-merged) value `:B`; in the end, we'll expect to see `[:A :B]`.

``` clojure
(vector :A :B)
; => [:A :B]
(flatten [:A :B])
; => (:A :B)
(vec '(:A :B))
; => [:A :B]
```

Remember, `comp` passes the result of one computation as the input to the next in the chain.  In this particular scenario, the calls to `flatten` and `vec` seem unnecessary; after all, we could have stopped after `vector` and been done with it.  If you're only ever going to merge two values, then yes, you could have just used `vector`...  but that's not very interesting, is it?  Let's continue on with our example and merge in an additional value, `:C`.  This time we're starting with the vector `[:A :B]`, which will illustrate the second case of behavior.

``` clojure
(vector [:A :B] :C)
; => [[:A :B] :C]
(flatten [[:A :B] :C])
; => (:A :B :C)
(vec '(:A :B :C))
; => [:A :B :C]
```

Now the need for `flatten` is apparent; if we didn't use it, we'd end up with an increasingly nested set of vectors within vectors within vectors.  By flattening, we eliminate the nesting before it has a chance to start.  But `flatten` gives us a sequence, and we wanted to get a vector back.  No problem; `vec` to the rescue!  (Strictly speaking, everything could still work fine without `vec`, so long as you don't mind a mixture of vectors and sequences as values in your data structure).

Now we can see that in both cases, we end up with a vector of all the values for a given key being plugged into our growing map.  Of course, the astute reader will recognize the (potential) bug lurking here: what if one of your values is _already a vector?_  If that's the case, this particular implementation will not be very kind to you, since it unmercilessly flattens everything in sight.  You can get around this, though (and I leave that as an exercise for the reader); in this article I'm focusing on the uses of higher order functions... that, and the software I wrote this function for never has to deal with vector values, so there :P

So that covers the `comp`-generated HOF, but there's another HOF lurking in there, too: `(partial apply hash-map)`.  All that does is convert the vector pairs into maps for feeding into `merge-with` (we have to use `apply`, because `hash-map` is not expecting a sequence as input).  I told you: HOFs are _everywhere_ in Clojure.

Now, contrast this to how I would have written this function when I was young and foolish, pre-HOF:

``` clojure
(apply merge-with
       (fn [vals v]
         (if (vector? vals)
           (conj vals v)
           [vals v]))
       (for [[k v] pairs]
        {k v}))
```

Quite a bit more verbose and just _uglier_.  Also note that the `(comp vec flatten vector)` and `(partial apply hash-map)` functions are more general and re-usable than their wordier counterparts.

This just shows that you can get the job done in Clojure in any number of ways, but to get really succinct and elegant code, it pays to get familiar with Clojure's function-generating functions.

Exploration of `juxt` (quite handy for destructuring `let` bindings) and `complement` (great for use with `filter`, `remove`, and other predicate-consuming functions) are left as exercises for the reader.

[clojure]:http://www.clojure.org
[HOF]:http://en.wikipedia.org/wiki/Higher-order_function
[map]:http://clojure.github.com/clojure/clojure.core-api.html#clojure.core/map
[comp]:http://clojure.github.com/clojure/clojure.core-api.html#clojure.core/comp
[partial]:http://clojure.github.com/clojure/clojure.core-api.html#clojure.core/partial
[juxt]:http://clojure.github.com/clojure/clojure.core-api.html#clojure.core/juxt
[complement]:http://clojure.github.com/clojure/clojure.core-api.html#clojure.core/complement
