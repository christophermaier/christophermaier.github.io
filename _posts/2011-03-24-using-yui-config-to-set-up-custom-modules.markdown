---
title: Using YUI_config to Set Up Custom YUI Modules
redirect_from:
  - /2011/03/24/using-yui-config-to-set-up-custom-modules.html
  - /blog/2011/03/24/using-yui-config-to-set-up-custom-modules/
---

Once you have been using the [YUI][] JavaScript framework for a little
while, you'll inevitably need to write your own custom modules.  For
me, I started creating lots and lots of [widgets][] and needed to
figure out how to properly modularize everything.  The documentation
for creating modules using [YUI.add][] is good, and it got me up and
running quickly.  So far, so good.

Armed with a handful of widgets in proper YUI modules, I needed a way
to actually register them with my YUI instances in order to use them.
Again, the docs for the [YUI Loader][] ably pointed the way, with one
tiny exception.

The examples shown all look like this:

``` javascript
YUI({
   modules:  {
       "foo_widget": {
           fullpath: "/js/foo_widget.js",
           requires: ["widget"]
           // ... other configuration ...
       },
       // ... other modules ...
   }
}).use("foo_widget", function(Y) {
    // Do stuff...
});
```

Of course, this works, but it becomes a pain to repeat all my custom
module information on each page where they're used (for each YUI
instance, really).  The documentation doesn't readily show (at least,
I wasn't able to find it) how you can set all this information once
for your entire application.

Digging around on the forums, however, turned up the `YUI_config`
object.  Basically, this is the same map that you would otherwise pass
to the `YUI` object when you want to create a new instance.  Sticking
it in `YUI_config` makes it automatically available whenever you
create a new instance.  What I've done is create a file that defines a
`YUI_config` object for my application (loading it up with all my
module definition information), and I include that in my pages.  It's
dead simple:

``` javascript
YUI_config = {
    modules: {
        "foo_widget": {
            fullpath: "/js/foo_widget.js",
            requires: ["widget"]
        },
        // ... etc.
    },
};
```

Now, I can reference `foo_widget` just like I would any other YUI
module:

``` javascript
YUI().use("foo_widget",
    function(Y){
        // do interesting things with foo_widget here...
    });
```

Problem solved.

[YUI]:http://developer.yahoo.com/yui/3
[widgets]:http://developer.yahoo.com/yui/3/widget/
[YUI.add]:http://developer.yahoo.com/yui/3/yui/#yuiadd
[YUI Loader]:http://developer.yahoo.com/yui/3/yui/#loader
