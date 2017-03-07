---
title: MongoDB Query Tricks, or "Why Don't MongoDB Doesn't Not have $and?"
redirect_from:
  - /2010/12/21/mongodb-query-tricks.html
  - /blog/2010/12/21/mongodb-query-tricks/
---

Pardon the atrocious grammar; there is a point!

I recently had a tricky time formulating a particular query in
MongoDB.  As you probably know, MongoDB has a number of [query
operators][] to use.  It's got stuff like `$in`, `$nin`, `$or`, and
others, but no `$and`.  Normally, you don't need something like
`$and`, since the capability is there implicitly; you just list off
all your conditions on your different document fields, and MongoDB
finds all the documents that satisfy them all.  However, there _is_ a
situation that I've come across lately where something like `$and`
would be very helpful; declaring multiple conditions _on a single
field_.

Let's set up some test data to illustrate a scenario:

``` javascript
db.people.save({name: "Xavier", friends: ["Bob","Fred","Sam"]});
db.people.save({name: "Yorick", friends: ["Elmer","Alice"]});
db.people.save({name: "Zelda", friends: ["David","Erica","Walt"]});
```

Say I have one group of interesting people:

```javascript
["Alice","Bob","Charlie"]
```

And then I have *another* group of interesting people:

``` javascript
["David","Erica","Fred"]
```

Now I want to find everybody in my database that is friends with at
least one person from *each* of these groups.  That is to say, I would
want to find Xavier, but not Yorick or Zelda.  I want to specify two
conditions on my "friends" field.  (This isn't the real situation I
was dealing with, but I'll spare you the scientific background.)

You might think, "That's easy, you just use the `$in` query
operator!".  Well, that's what I thought.  There's a problem with
that, though.  Conceptually, you want a query like this, to take
advantage of MongoDB's implicit `$and` for conditions:

``` javascript
db.people.find({
    friends: {$in: ["Alice","Bob","Charlie"]},
    friends: {$in: ["David","Erica","Fred"]}
});
```

However, this is going to find Xavier and Zelda!

``` javascript
{ "_id": ObjectId("4d11deb1a95769443d8dd7c4"),
  "name": "Xavier",
  "friends": [ "Bob", "Fred", "Sam" ] }
{ "_id": ObjectId("4d11deb2a95769443d8dd7c6"),
  "name": "Zelda",
  "friends": [ "David", "Erica", "Walt" ] }
```

You've duplicated your keys!  The implicit `$and` only really works on
different fields; you can't combine conditions on the same field this
way.  Here your're actually only looking for friends of David, Erica,
or Fred instead of finding people that could bridge these two cliques.
It seems that the last condition declared "wins".  Note that we didn't
find Yorick in that last query; he's not friends with David, Erica, or
Fred.

My next thought was to try `$all`:

``` javascript
db.people.find({
    friends: {
        $all: [
            {$in: ["Alice","Bob","Charlie"]},
            {$in: ["David","Erica","Fred"]}
        ]
    }
});
```

That doesn't work either; it looks like `$all` only accepts a list of
values, not additional conditions.

So how do you ask this query?  You need to be a little more tricky in
your formulation.  After a quick fling with a truth table, here's my
solution:

``` javascript
db.people.find({
    $nor: [
        {friends: {$not: {$in: ["Alice","Bob","Charlie"]}}},
        {friends: {$not: {$in: ["David","Erica","Fred"]}}}
    ]
});
```

That gives you what you want

``` javascript
{ "_id": ObjectId("4d11deb1a95769443d8dd7c4"),
  "name": "Xavier",
  "friends": [ "Bob", "Fred", "Sam" ] }
```

It looks confusing at first, but just step through it.  You are
saying, "find everybody that **isn't not** friends with Alice, Bob, or
Charlie, _and_ **isn't not** friends with David, Erica, or Fred".  The
`$nor` gives you the `$and` capabilities (albeit negated), and the
`$not`s reverse the meanings of your tests to be compatible with
`$nor`.  It would be easier if MongoDB actually had an `$and`
operator, but this will do in a pinch.

Since discovering this trick, I've actually had to use it a number of
times, particularly when dealing with array fields that contain
objects instead of plain values.

Double negatives can be handy, no matter what your middle school
English teacher says.

[query operators]:http://www.mongodb.org/display/DOCS/Advanced+Queries
