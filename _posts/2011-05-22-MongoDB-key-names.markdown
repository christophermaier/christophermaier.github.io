---
title: The Importance of MongoDB Key Names
redirect_from:
  - /2011/05/22/MongoDB-key-names.html
  - /blog/2011/05/22/MongoDB-key-names/
---

Coming from a relational database background, you might not devote a lot of thought to the names of your columns.  That is to say, while you make an effort to come up with a sensible and descriptive naming scheme for your columns, you probably don't think about the amount of _space_ those names take up.  And why should you?  In a relational databases, the column names are stored once, probably in a central metadata table.  Whether you call a column `sequence` or `seq` or `s`, it isn't going to make any practical difference in how much space your database uses.

In a schema-free database system like [MongoDB][], however, the key names you choose can have a sizable impact on the final size of a collection, depending on the relative size of the keys to the entire document size, as well as the number of documents in the collection.  This is due to the fact that the key names are stored in each document; this is a side effect of being schema-free.

Recently I was experimenting with a database at work with 1.6 billion documents (yes, that's with a _B_).  Each document looks like this:

``` json
{"sequence":"AHAHSPGPGSAVKLPAPHSVGKSALR",
 "location":{
     "chromosome":"19",
     "strand":"-",
     "begin":"51067007",
     "end":"51067085"
 }}
```

Once all the data were loaded up here's what the collection stats looked like:

    > db.peptides.stats()
    {
        "ns" : "haystack.peptides",
        "count" : 1602177119,
        "size" : 216603098452,
        "avgObjSize" : 135.1929795297495,
        "storageSize" : 243349563712,
        "numExtents" : 144,
        "nindexes" : 1,
        "lastExtentSize" : 2146426864,
        "paddingFactor" : 1,
        "flags" : 1,
        "totalIndexSize" : 66625226448,
        "indexSizes" : {
                "_id_" : 66625226448
        },
        "ok" : 1
    }

Total size is around 243 GB.

Then I did a little experiment and used the smallest keys possible; all my keys are now one letter long.  Now my documents look like this:

``` json
{"s":"AHAHSPGPGSAVKLPAPHSVGKSALR",
 "l":{
     "c":"19",
     "s":"-",
     "b":"51067007",
     "e":"51067085"
 }}
```

Now, when I reload all the data with this schema, I get these collection stats:

    > db.tinypeptides.stats()
    {
        "ns" : "haystack.tinypeptides",
        "count" : 1602177119,
        "size" : 155730331732,
        "avgObjSize" : 97.19919844392685,
        "storageSize" : 182977326080,
        "numExtents" : 118,
        "nindexes" : 1,
        "lastExtentSize" : 2146426864,
        "paddingFactor" : 1,
        "flags" : 1,
        "totalIndexSize" : 66625734352,
        "indexSizes" : {
                "_id_" : 66625734352
        },
        "ok" : 1
    }

Final size now is just shy of 183 GB, for a savings of about 60 GB.  Not too bad!

Of course, you shouldn't just go changing all your keys for the hell of it.  You'll need to consider how you use your data in applications; who knows, maybe constantly translating between space-saving short keys and human-readable long keys will be too expensive or unwieldy for your particular project.  But if it makes sense, using shorter keys can potentially save a lot of space and even increase performance (after all, more of a smaller database can fit into memory).

Granted, my documents are very small to begin with, so the amout of space devoted to the keys is relatively large.  The proportional space savings for collections with larger documents probably will not be as great; it all depends on your data.  In any event, it's good to be aware of this aspect of schema-free databases.

[MongoDB]:http://mongodb.org
