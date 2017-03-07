---
title: Comparing Settings From Different PostgreSQL Databases
redirect_from:
  - /2010/04/27/compare-postgresql-configurations.html
  - /blog/2010/04/27/compare-postgresql-configurations/
---

I'm in the process of migrating from an older version of PostgreSQL to
a newer version.  I'd like to see what the differences are between the
configuration (`${PG_DATA}/postgresql.conf`) of both servers.  I
couldn't find an easy, ready-made solution, so I hacked up one using
plain old SQL, which turns out to be particularly well suited to
comparing sets of data :)

First, get the settings from the old server.  We'll use [`psql`][psql]
to execute the [`SHOW ALL`][showall] query and pipe the result
(stripped of all extraneous formatting) to the file
`old_settings.txt`.  (I'm using the long versions of the command
flags, as well as adding in lots of newlines, to aid in readability
and comprehensibility.)

``` bash
psql --username postgres \
     --dbname postgres \
     --host OLD_SERVER_ADDRESS \
     --port OLD_SERVER_PORT \
     --output old_settings.txt \
     --no-align \
     --quiet \
     --tuples-only \
     --command 'show all'
```

Now, we'll need the settings from the new server.  We use the same
trick, but pipe the output to the `new_settings.txt` file, instead.

``` bash
psql --username postgres \
     --dbname postgres \
     --host NEW_SERVER_ADDRESS \
     --port NEW_SERVER_PORT \
     --output new_settings.txt \
     --no-align \
     --quiet \
     --tuples-only \
     --command 'show all'
```

So now we have the data in a format that is easily loaded into a
PostgreSQL database!  On some other database, we create some simple
tables to hold the information; their format is that of the output of
the `SHOW ALL` command.

``` sql
CREATE TABLE old_server(parameter TEXT, value TEXT, description TEXT);
CREATE TABLE new_server(parameter TEXT, value TEXT, description TEXT);
```

Now copy the information into the tables using the `\copy` command:

``` sql
\copy old_server from ./old_settings.txt delimiter as '|'
\copy new_server from ./new_settings.txt delimiter as '|'
```

We'll create a view to massage this data into a nice report in order
to more easily see what's different:

``` sql
CREATE VIEW configurations AS
SELECT
    newer.parameter,
    older.value as original_value,
    newer.value AS current_value,
    (older.value != newer.value) AS "different?",
    (newer.parameter IS NULL) AS "removed?",
    (older.parameter IS NULL) AS "new?"
FROM new_server AS newer
LEFT JOIN old_server AS older  -- there might be some parameters that are no longer there
    ON newer.parameter = older.parameter
;
```

Finally, we can execute some simple queries on this view to show us
what's going on:

``` sql
-- What parameters are different?
SELECT parameter, original_value, current_value FROM configurations WHERE "different?";

-- What are the values of the parameters that are not present in the original configuration?
SELECT parameter, current_value FROM configurations WHERE "new?";

-- What are the values of the parameters that have been removed since the original database version?
SELECT parameter, original_value FROM configurations WHERE "removed?";
```

Problem solved!

[showall]:http://www.postgresql.org/docs/current/interactive/sql-show.html
[psql]:http://www.postgresql.org/docs/current/interactive/app-psql.html
