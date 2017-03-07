---
title: Blogging on Github with Jekyll
redirect_from:
  - /2010/04/25/blog-with-jekyll.html
  - /blog/2010/04/25/blog-with-jekyll/
---

As per the instructions on [the Jekyll install page][jekyll],

``` bash
gem install jekyll
```
then (since I didn't have this set already):

``` bash
export PATH=${PATH}:/Users/maier/.gem/ruby/1.8/bin
```

added to my Bash `~/.profile` file.

[Pygments](http://pygments.org/) is cool for syntax highlighting.  On
a Mac with MacPorts, it's as easy as this:

``` bash
sudo port install python25 py25-pygments
```

Running Jekyll with its standalone server is great for testing your
site locally:

``` bash
jekyll --auto --server
```

That'll run an embedded web server at
[http://localhost:4000](http://localhost:4000) (by default); anytime
you change any of your site files, Jekyll will reprocess them and make
them available immediately.  All you have to do is refresh your
browser.

[jekyll]:http://wiki.github.com/mojombo/jekyll/install
