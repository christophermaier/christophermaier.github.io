---
title: Github's new "Fork and Edit" Feature is Awesome
redirect_from:
  - /2011/05/22/fork-and-edit-is-awesome.html
  - /blog/2011/05/22/fork-and-edit-is-awesome/
---

Github recently rolled out a new [Fork and Edit][] feature that is pretty awesome.  It basically allows you to create your own fork of any Github project, edit files in a new branch of that fork, and create a pull request back to the original project, all from your web browser, and in about as much time as it's taken me to write this sentence.  This really lowers the barrier for contributing code to other projects.

For instance, I recently was working on a Clojure web application at work and generating some HTML with James Reeve's excellent [Hiccup][] library.  I was having some problems with a `<canvas>` tag being rendered improperly: Hiccup was rendering it as this:

``` html
<canvas id='spectrum' />
```

Apparently, canvases are "container tags" which need to be explicitly closed with the appropriate tag, like this:

``` html
<canvas id='spectrum'></canvas>
```

The fix in Hiccup is simple enough: add the string "canvas" to a private set of container tags.  It is literally adding one string to a data structure.  I made a fix in my own Clojure project so I could keep working (thank you, [clojure.core/in-ns][]!) and made a note to go back to formally and submit the change to Hiccup later.

But then I noticed the "Fork and edit this file" button at the top of the page.  "What the hell?  Let's give it a shot", I thought as I pressed it.  Instant fork and branch creation, and I'm in an editable view of the code in question.  I scroll down, add the magical "canvas" string at the right place, hit commit, and it's all done.  The [patch][] was submitted as a pull request and it all took about 2 minutes from start to finish, a large portion of that time taken up by me thinking "Damn, this is slick!".

Now, I wouldn't dream of doing this for any kind of involved coding (Emacs is a far better code editor than an HTML text field, thank you very much), but for minor fixes like this, it's golden.  Think how great this would be for documentation fixes!

And honestly, "Fork and Edit" is really what's needed for these kinds of fixes.  If I'm reading through some code on Github (which I actually kind of prefer, truth be told) and I see some confusing or unclear documentation or some other minor problem, I'm going to have to be _really_ motivated to create a fork, download that code to my computer, fire up Emacs, make the change, push the code back to my fork, _and_ issue a pull request.  However, if I can make the change right there while I'm thinking about it, without having to do anything else, then I'm probably going to do it.

Fork and Edit makes contributing to open source code about as easy as editing Wikipedia, and that's a very good thing.

[Fork and Edit]:https://github.com/blog/844-forking-with-the-edit-button
[Hiccup]:http://www.github.com/weavejester/hiccup
[clojure.core/in-ns]:http://clojure.github.com/clojure/clojure.core-api.html#clojure.core/in-ns
[patch]:https://github.com/weavejester/hiccup/commit/eb49d0ef63d529060863f17d9852f6bcc6f92009
