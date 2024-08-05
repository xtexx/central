---
title: Recommended Settings and Tips
license: 'CC-BY-SA-4.0'
---

Although the default settings are appropriate for a general Forgejo instance, not every instance has the same purpose, aim, or user size. As a result, this is a list of suggested settings that you could use if they relate to your situation. The list aims to describe what it changes, what it does, and when it makes sense to make the adjustment.

## Recommended Settings

After this, you will see headings being named such as `[section.part].ENABLE_FEATURE_XY`. This describes what setting it's talking about; in this case, it would be a setting in the section called `section.part`, while the setting name is `ENABLE_FEATURE_XY`. So if you wanted to change that setting in your `app.ini`, it would look like:

```ini
[section.part]
ENABLE_FEATURE_XY = new_value
```

Please bear in mind that you don't have to create new sections for every value; you can have multiple settings in the same section, such as:

```ini
[section.part]
ENABLE_FEATURE_XY = new_value
DISABLE_FEATURE_Z = other_new_value
```

The recommended settings are sorted alphabetically rather than by importance.

### `[database].DB_TYPE`

For every action, operation or page you visit, Forgejo must query a database for data. The database is an important part of the Forgejo stack and therefore must be configured with care to ensure proper operation. However, it is difficult to give a recommendation due to its general nature and the many factors that affect the use of the database. So keep the following text in mind when configuring and choosing the database and always test carefully if the configuration suits your situation and [ask for assistance](../seek-assistance/) if needed.

If your instance sees a low to moderate amount of activity, it is recommended to change this value to **sqlite3**. [SQLite3](https://www.sqlite.org/index.html) is a simple, non-maintenance requirement and one file on disk database. It is by far the easiest database to configure and has many other advantages over the other databases, but it becomes a poor choice once you see a lot of concurrent activity in which case performance may decrease, but SQLite can go a long way in the early years of an instance. It is also recommended to change `[database].SQLITE_JOURNAL_MODE` to `WAL`, which allows for a modern and faster way of tracking SQL queries.

If your instances see a high amount of activity, it is recommended to change this value to **mysql** or **postgres**. There is no best managed database server, and it mainly depends on your previous experience and knowledge about the database you want to use, both can handle large amounts of activity, please refer to the [database-configuration](../config-cheat-sheet#database-database/) about what other values should be configured to connect to the database server.

**Warning:** Keep in mind that transitioning to another database with an existing database is not a trivial task and must be done carefully.

### `[cache].ADAPTER`

Forgejo uses caching to avoid doing expensive work multiple times in multiple places. The default cache is a simple cache mechanism that deletes items after x time, regardless of whether they are used often or not used at all and not deleted if there are many items in the cache, this is clearly not a good cache. To give you an idea if your instance relies heavily on the caching code, a few examples where it is used: commit count of a repository, branch or only where x file was modified (requires a lot of IO work), user settings (frequent database lookup) and avatar hash (hash computation) are the most common usage of the caching code.

If your instance does not see much activity, it is recommended to change this value to **twoqueue**. This will use a size-limited [LRU cache](<https://en.wikipedia.org/wiki/Cache_replacement_policies#Least_recently_used_(LRU)>), which will keep frequently used items and remove the ones that are not used often. It is also recommended to change `[cache].HOST` to `{"size":100, "recent_ratio":0.25, "ghost_ratio":0.5}` because the default value has a limit of 50,000 items and since by default it will keep items for 16 hours, it is not memory efficient to possibly keep so many items for a small instance.

If your instance sees a lot of activity, it is recommended to change this value to **redis** or **memcache**. In that case, caching is outsourced to third-party software designed to cache items. Keep in mind that you will probably also need to modify `[cache].HOST` to configure the use of this software.

The **redis** adapter should support most software that works with a limited subset of the [Redis Go Client](https://github.com/redis/go-redis) APIs. In particular, Forgejo has integration tests against:

- [Redis](https://redis.io/) v7.2; higher versions will not be officially supported due to licensing concerns,
- [Redict](https://redict.io/), a fork of Redis v7.2 licensed under the Lesser GNU General Public license (`LGPL-3.0-only`),
- [Valkey](https://valkey.io/), a fork of Redis v7.2 stewarded by the Linux Foundation, and
- [Garnet](https://microsoft.github.io/garnet), an independently implemented cache-store using [Redis's RESP](https://redis.io/docs/latest/develop/reference/protocol-spec/).

### `[repository.signing].DEFAULT_TRUST_MODEL`

When Forgejo needs to verify a GPG or SSH signed commit on a repository, it checks who it can trust to have a verified commit on that repository. The default value for this setting is that Forgejo trusts only contributors to that repository to have signed commits, this can cause unexpected behavior for those used to GitHub when hosting repositories that anyone can contribute to, because non-collaborators with signed commits on that repository are shown as unverified.

If your instance expects users to contribute to other repositories within your instance, it is recommended that you change this value to **committer**. In that case, signed commits will appear as verified even if they are not collaborators.

### `[security].LOGIN_REMEMBER_DAYS`

When a user logs in with the remember option enabled, they receive a long-term authentication cookie that is remembered for a number of days, determined by this setting. The default setting is seven days, which is much less than other major services and can be frustrating for the user to log in every week.

If your instance does not need to adhere to a security policy that mandates a different value, it is recommended that you change this value to **365**. In that case, the long-term authentication cookie will be stored on the user's device for one year.

### `[service].ENABLE_CAPTCHA`

In recent years, spam bots have gotten smarter and have automated more than ever. A simple register form such as in Forgejo is a simple task for bots to register a new user and comment wherever they can about their favorite scam website. Forgejo provides the option to enable captcha on the register form.

If your instance has an open registration, it is recommended to change this value to **true**. You also need to choose which captcha you want to use, you can find more about that in the [service configuration](../config-cheat-sheet#service-service/). Keep in mind that certain types of captcha limit the accessibility of registering new users because they often use images that are difficult to see.

### `[ui].ONLY_SHOW_RELEVANT_REPOS`

The explore page is a good way to quickly check what is happening with an instance because it shows the most recent repositories on which action has been taken. If your instance sees a lot of activity, such as with a large user base, this explore page can quickly become a cluttered place where most of the repositories may not be relevant, such as a test repository or someone's personal dotconfig repository, which does not necessarily add to the effect of seeing what is happening on that instance.

If you have an instance with a lot of activity, it is recommended to change this value to **true**. In that situation, the explore page will filter out repositories that are likely to be less relevant in order to see what interesting projects are available on that instance.

## Tips

### Git over SSH

If you have configured to allow Git over SSH (enabled by default), and decided not to use the built-in SSH server, then you need to configure your SSH server to allow a specific environment. Git will tell the server over SSH that it is able to use [a newer version of the Git Wire Protocol](https://www.git-scm.com/docs/protocol-v2), but by default, SSH servers like OpenSSH will not pass the environment to Forgejo. You have to tell the SSH server to pass the `GIT_PROTOCOL` environment. You can configure that with the OpenSSH server in the sshd config as follows:

```
AcceptEnv GIT_PROTOCOL
```

### Database performance

When trying to understand poor database performance in conjunction with Forgejo, it is useful to set `[database].SLOW_QUERY_THRESHOLD` to a value lower than the default (5 seconds). This ensures that SQL queries that are slow, but not too slow to meet the default value, are logged and can provide insight into what kind of SQL queries are slow, moreover, this is useful information for Forgejo contributors to find the code where this SQL query is executed and understand the context.
