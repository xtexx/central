---
title: 'Database Preparation'
license: 'Apache-2.0'
origin_url: 'https://github.com/go-gitea/gitea/blob/abe8fe352711601fbcd24bf4505f7e0b81a93c5d/docs/content/installation/database-preparation.en-us.md'
---

You need a database to use Forgejo. Forgejo supports PostgreSQL (>=12), MySQL (>=8.0) or MariaDB (>=10.0), SQLite, and MSSQL (>=2012 SP4). This page will guide into preparing database. Only PostgreSQL and MySQL/MariaDB will be covered here since those database engines are widely-used in production. If you plan to use SQLite, you can ignore this chapter.

Database instance can be on same machine as Forgejo (local database setup), or on different machine (remote database).

Note: All steps below requires that the database engine of your choice is installed on your system. For remote database setup, install the server application on database instance and client program on your Forgejo server. The client program is used to test connection to the database from Forgejo server, while Forgejo itself use database driver provided by Go to accomplish the same thing. In addition, make sure you use same engine version for both server and client for some engine features to work. For security reason, protect `root` (MySQL/MariaDB) or `postgres` (PostgreSQL) database superuser with secure password. The steps assumes that you run Linux for both database and Forgejo servers.

## MySQL/MariaDB

1. For remote database setup, you will need to make MySQL/MariaDB listen to your IP address. Edit `bind-address` option on `/etc/mysql/my.cnf` on database instance to:

   ```ini
   bind-address = 203.0.113.3
   ```

2. On database instance, login to database console as root:

   ```
   mysql -u root -p
   ```

   Enter the password as prompted.

3. Create database user which will be used by Forgejo, authenticated by password. This example uses `'passw0rd'` as password. _Please use a secure password for your instance._

   For local database:

   ```sql
   SET old_passwords=0;
   CREATE USER 'forgejo'@'%' IDENTIFIED BY 'passw0rd';
   ```

   For remote database:

   ```sql
   SET old_passwords=0;
   CREATE USER 'forgejo'@'192.0.2.10' IDENTIFIED BY 'passw0rd';
   ```

   where `192.0.2.10` is the IP address of your Forgejo instance.

   Replace username and password above as appropriate.

4. Create database with UTF-8 charset and collation. Make sure to use `utf8mb4` charset instead of `utf8` as the former supports all Unicode characters (including emojis) beyond _Basic Multilingual Plane_. Also, collation chosen depending on your expected content. When in doubt, use either `unicode_ci` or `general_ci`.

   ```sql
   CREATE DATABASE forgejodb CHARACTER SET 'utf8mb4' COLLATE 'utf8mb4_unicode_ci';
   ```

   Replace database name as appropriate.

5. Grant all privileges on the database to database user created above.

   For local database:

   ```sql
   GRANT ALL PRIVILEGES ON forgejodb.* TO 'forgejo';
   FLUSH PRIVILEGES;
   ```

   For remote database:

   ```sql
   GRANT ALL PRIVILEGES ON forgejodb.* TO 'forgejo'@'192.0.2.10';
   FLUSH PRIVILEGES;
   ```

6. Quit from database console by `exit`.

7. On your Forgejo server, test connection to the database:

   ```
   mysql -u forgejo -h 203.0.113.3 -p forgejodb
   ```

   where `forgejo` is database username, `forgejodb` is database name, and `203.0.113.3` is IP address of database instance. Omit `-h` option for local database.

   You should be connected to the database.

## PostgreSQL

1. For remote database setup, configure PostgreSQL on database instance to listen to your IP address by editing `listen_addresses` on `postgresql.conf` to:

   ```ini
   listen_addresses = 'localhost, 203.0.113.3'
   ```

2. PostgreSQL uses `md5` challenge-response encryption scheme for password authentication by default. Nowadays this scheme is not considered secure anymore. Use SCRAM-SHA-256 scheme instead by editing the `postgresql.conf` configuration file on the database server to:

   ```ini
   password_encryption = scram-sha-256
   ```

   Restart PostgreSQL to apply the setting.

3. On the database server, login to the database console as superuser:

   ```
   su -c "psql" - postgres
   ```

4. Create database user (role in PostgreSQL terms) with login privilege and password. _Please use a secure, strong password instead of `'passw0rd'` below:_

   ```sql
   CREATE ROLE forgejo WITH LOGIN PASSWORD 'passw0rd';
   ```

   Replace username and password as appropriate.

5. Create database with UTF-8 charset and owned by the database user created earlier. Any `libc` collations can be specified with `LC_COLLATE` and `LC_CTYPE` parameter, depending on expected content:

   ```sql
   CREATE DATABASE forgejodb WITH OWNER forgejo TEMPLATE template0 ENCODING UTF8 LC_COLLATE 'en_US.UTF-8' LC_CTYPE 'en_US.UTF-8';
   ```

   Replace database name as appropriate.

6. Allow the database user to access the database created above by adding the following authentication rules to `pg_hba.conf`.

   For local database:

   ```ini
   local    forgejodb    forgejo                   scram-sha-256
   host     forgejodb    forgejo    127.0.0.1/32   scram-sha-256  # IPv4 local connections
   host     forgejodb    forgejo    ::1/128        scram-sha-256  # IPv6 local connections
   ```

   For remote database:

   ```ini
   host    forgejodb    forgejo    192.0.2.10/32    scram-sha-256
   ```

   Replace database name, user, and IP address of Forgejo instance with your own.

   Note: rules on `pg_hba.conf` are evaluated sequentially, that is the first matching rule will be used for authentication. Your PostgreSQL installation may come with generic authentication rules that match all users and databases. You may need to place the rules presented here above such generic rules if it is the case.

   Restart PostgreSQL to apply new authentication rules.

7. On your Forgejo server, test connection to the database.

   For local database:

   ```
   psql -U forgejo -d forgejodb -h localhost
   ```

   For remote database:

   ```
   psql "postgres://forgejo@203.0.113.3/forgejodb"
   ```

   where `forgejo` is database user, `forgejodb` is database name, and `203.0.113.3` is IP address of your database instance.

   You should be prompted to enter password for the database user, and connected to the database.

## Database Connection over TLS

If the communication between Forgejo and your database instance is performed through a private network, or if Forgejo and the database are running on the same server, this section can be omitted since the security between Forgejo and the database instance is not critically exposed. If instead the database instance is on a public network, use TLS to encrypt the connection to the database, as it is possible for third-parties to intercept the traffic data.

### Prerequisites

- You need two valid TLS certificates, one for the database instance (database server) and one for the Forgejo instance (database client). Both certificates must be signed by a trusted CA.
- The database certificate must contain `TLS Web Server Authentication` in the `X509v3 Extended Key Usage` extension attribute, while the client certificate needs `TLS Web Client Authentication` in the corresponding attribute.
- On the database server certificate, one of `Subject Alternative Name` or `Common Name` entries must be the fully-qualified domain name (FQDN) of the database instance (e.g. `db.example.com`). On the database client certificate, one of the entries mentioned above must contain the database username that Forgejo will be using to connect.
- You need domain name mappings of both Forgejo and database servers to their respective IP addresses. Either set up DNS records for them or add local mappings to `/etc/hosts` (`%WINDIR%\System32\drivers\etc\hosts` in Windows) on each system. This allows the database connections to be performed by domain name instead of IP address. See documentation of your system for details.

### PostgreSQL

The PostgreSQL driver used by Forgejo supports two-way TLS. In two-way TLS, both database client and server authenticate each other by sending their respective certificates to their respective opposite for validation. In other words, the server verifies client certificate, and the client verifies server certificate.

1. On the server with the database instance, place the following credentials:

   - `/path/to/postgresql.crt`: Database instance certificate
   - `/path/to/postgresql.key`: Database instance private key
   - `/path/to/root.crt`: CA certificate chain to validate client certificates

2. Add following options to `postgresql.conf`:

   ```ini
   ssl = on
   ssl_ca_file = '/path/to/root.crt'
   ssl_cert_file = '/path/to/postgresql.crt'
   ssl_key_file = '/path/to/postgresql.key'
   ssl_min_protocol_version = 'TLSv1.2'
   ```

3. Adjust credentials ownership and permission, as required by PostgreSQL:

   ```
   chown postgres:postgres /path/to/root.crt /path/to/postgresql.crt /path/to/postgresql.key
   chmod 0600 /path/to/root.crt /path/to/postgresql.crt /path/to/postgresql.key
   ```

4. Edit `pg_hba.conf` rule to only allow Forgejo database user to connect over SSL, and to require client certificate verification.

   For PostgreSQL 12:

   ```ini
   hostssl    forgejodb    forgejo    192.0.2.10/32    scram-sha-256    clientcert=verify-full
   ```

   For PostgreSQL 11 and earlier:

   ```ini
   hostssl    forgejodb    forgejo    192.0.2.10/32    scram-sha-256    clientcert=1
   ```

   Replace database name, user, and IP address of Forgejo instance as appropriate.

5. Restart PostgreSQL to apply configurations above.

6. On the server running the Forgejo instance, place the following credentials under the home directory of the user who runs Forgejo (e.g. `git`):

   - `~/.postgresql/postgresql.crt`: Database client certificate
   - `~/.postgresql/postgresql.key`: Database client private key
   - `~/.postgresql/root.crt`: CA certificate chain to validate server certificate

   Note: Those file names above are hardcoded in PostgreSQL and it is not possible to change them.

7. Adjust credentials, ownership and permission as required:

   ```
   chown git:git ~/.postgresql/postgresql.crt ~/.postgresql/postgresql.key ~/.postgresql/root.crt
   chown 0600 ~/.postgresql/postgresql.crt ~/.postgresql/postgresql.key ~/.postgresql/root.crt
   ```

8. Test the connection to the database:

   ```
   psql "postgres://forgejo@example.db/forgejodb?sslmode=verify-full"
   ```

   You should be prompted to enter password for the database user, and then be connected to the database.

### MySQL/MariaDB

While the MySQL/MariaDB driver used by Forgejo also supports two-way TLS, Forgejo currently supports only one-way TLS. See the "Add TLS File Path Options for MySQL/MariaDB Database Connection](https://github.com/go-gitea/gitea/issues/10828)" issue for details.

In one-way TLS, the database client verifies the certificate sent from server during the connection handshake, and the server assumes that the connected client is legitimate, since client certificate verification doesn't take place.

1. On the database instance, place the following credentials:

   - `/path/to/mysql.crt`: Database instance certificate
   - `/path/to/mysql.key`: Database instance key
   - `/path/to/ca.crt`: CA certificate chain. This file isn't used on one-way TLS, but is used to validate client certificates on two-way TLS.

2. Add following options to `my.cnf`:

   ```ini
   [mysqld]
   ssl-ca = /path/to/ca.crt
   ssl-cert = /path/to/mysql.crt
   ssl-key = /path/to/mysql.key
   tls-version = TLSv1.2,TLSv1.3
   ```

3. Adjust credentials ownership and permission:

   ```
   chown mysql:mysql /path/to/ca.crt /path/to/mysql.crt /path/to/mysql.key
   chmod 0600 /path/to/ca.crt /path/to/mysql.crt /path/to/mysql.key
   ```

4. Restart MySQL/MariaDB to apply the setting.

5. The database user for Forgejo may have been created earlier, but it would authenticate only against the IP addresses of the server running Forgejo. To authenticate against its domain name, recreate the user, and this time also set it to require TLS for connecting to the database:

   ```sql
   DROP USER 'forgejo'@'192.0.2.10';
   CREATE USER 'forgejo'@'example.forgejo' IDENTIFIED BY 'passw0rd' REQUIRE SSL;
   GRANT ALL PRIVILEGES ON forgejodb.* TO 'forgejo'@'example.forgejo';
   FLUSH PRIVILEGES;
   ```

   Replace database user name, password, and Forgejo instance domain as appropriate.

6. Make sure that the CA certificate chain required to validate the database server certificate is on the system certificate store of both the database and Forgejo servers. Consult your system documentation for instructions on adding a CA certificate to the certificate store.

7. On the server running Forgejo, test connection to the database:

   ```
   mysql -u forgejo -h example.db -p --ssl
   ```

   You should be connected to the database.
