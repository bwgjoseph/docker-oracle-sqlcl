# Oracle SQLcl Docker Image

This is based heavily on [docker-oracle-sqlcl](https://github.com/martindsouza/docker-oracle-sqlcl) and made modification for own usage

The container will start-up and run `/oracle/run.sh` script. This allow flexibility to run custom code without restriction. The container only provides `sqlcl` as a tool to achieve our goal

## Key Changes

The key changes are

- Upgrade to `adoptopenjdk/openjdk11:jre-11.0.11_9-alpine`
- Invoke a shell script (default to `run.sh`) passed in via `/oracle` mounted path in `start-container.sh`.
  - Supports passing different shell script filename via `SH_SCRIPT_FILENAME` environment variable

### Build

```sh
docker build -t bwgjoseph/oracle-sqlcl:21.2.1.195.1252 -t bwgjoseph/oracle-sqlcl:latest .
```

### Push

```sh
docker push bwgjoseph/oracle-sqlcl:latest
docker push bwgjoseph/oracle-sqlcl:21.2.1.195.1252
```

---

- [Oracle SQLcl Docker Image](#oracle-sqlcl-docker-image)
  - [Key Changes](#key-changes)
    - [Build](#build)
    - [Push](#push)
  - [Build Image](#build-image)
  - [Run](#run)
  - [Volumes](#volumes)
  - [`/oracle/` Folder](#oracle-folder)
    - [`login.sql`](#loginsql)
    - [Aliases](#aliases)
    - [Oracle Wallet / Oracle OCI ATP](#oracle-wallet--oracle-oci-atp)
      - [Updating `sqlnet.ora` file](#updating-sqlnetora-file)


## Build Image

[Download Oracle SQLcl](http://www.oracle.com/technetwork/developer-tools/sqlcl/downloads/index.html)

```bash
git clone https://github.com/martindsouza/docker-oracle-sqlcl
cd docker-oracle-sqlcl

# *** Copy the downloaded sqlcl.zip file into the files directory ***
cp ~/Downloads/sqlcl-.*.zip files/

# Build the image
docker build \
  -t oracle-sqlcl:20.2.0 \
  -t oracle-sqlcl:latest \
  .
```

## Run

The following is focused on MacOS / Linux users.

- Create alias
  - *Note: the wrapping single quotes `'` instead of a double quote `"` which prevents `pwd` from being evaluated during the alias definition*

```bash
alias sqlcl='docker run -it --rm \
  --network="host" \
  -v `pwd`:/sqlcl \
  -v ~/Documents/Oracle/:/oracle \
  -e TNS_ADMIN=$TNS_ADMIN \
  oracle-sqlcl:latest'
```

To persist add the `alias` command to `~/.bash_profile`. If using [zsh](https://ohmyz.sh/) then add to `~/.zshrc`.

A few things about the parameters:


Parameter | Description
---------|----------
`--network="host"` |  This will mimic the current host networking (with the goal of acting like a binary)
`-v ``pwd``:/sqlcl` | This will set the current directory that `sqlcl` is run to the one that the container is looking at
`-v ~/Documents/Oracle/:/oracle` | _(optional)_ for `login.sql` to load startup scripts

- To execute: `sqlcl <connection string>`


**Note:** For the `<connection string>` it usually looks something like `sqlcl giffy/giffy@localhost:32118/xepdb1`. If you're referencing a port that is being tunneled by host machine (i.e. laptop) `localhost` doesn't seem to work. Instead use `host.docker.internal` to reference the host machine. Ex: `sqlcl giffy/giffy@host.docker.internal:32118/xepdb1`.

## Volumes

Volume | Description
---------|----------
`/sqlcl` | This is the folder that SQLcl will reference
`/oracle` | This is the folder that you will put `login.sql` and can load `alias` from here. Ex: `alias load /oracle/sqlcl-alias.xml`. Note the reference is to the container's local `/oracle` folder and not your full path.


## `/oracle/` Folder

The container has a mapped volume called `/oracle/`. In it you can add files for SQLcl to reference. The listings below cover each type of file.

### `login.sql`

`login.sql` allows you to store commands that you'd like SQLcl to run on init. An example is:

```sql
-- Add a reminder where to find this file on your laptop
-- Again in the Container it's mapped to /oracle/login.sql
prompt Settings in ~/Documents/Oracle/login.sql
prompt Remember this is in a Container and all referenced files must be from Containers point of view

set serveroutput on
set sqlformat ansiconsole

-- Alias will be covered below
prompt To manage aliases: ~/Documents/Oracle/sqlcl-alias.xml
alias load /oracle/sqlcl-alias.xml
```

### Aliases

SQLcl allow for aliases (not to be confused with Bash based aliases). Theres' lots of great examples on how to use them and one of the better ones is found [here](https://mikesmithers.wordpress.com/2019/06/25/sqlcl-alias-because-you-cant-remember-everything/).

To load an alias see the previous `login.sql` file example. You should store aliases in the same folder as `login.sql` as it is all mapped to the `/oracle/` folder in the Container

### Oracle Wallet / Oracle OCI ATP

When connecting to an Oracle Cloud (OCI) Autonomous Transaction Processing (ATP) database you'll need to reference a folder that contains the wallet information provided by the ATP instance [docs](https://docs.cloud.oracle.com/iaas/Content/Database/Tasks/adbconnecting.htm).

In the examples above we've mapped `~/Documents/Oracle/` (laptop) to `/oracle` (container) volume. To handle the OCI wallet requirement do the following.

On your laptop:

- Put the wallet files in `~/Documents/Oracle/wallets/atp01` (where `atp01` is the folder container the wallet files for a given ATP instance. Note that the folder name is entirely what you want to call it)
- Set the `TNS_ADMIN` variable. **This needs to be how the container will reference the folder**. In this example it would be: `TNS_ADMIN=/oracle/wallets/atp01`
- Connect to the ATP instance using the `sqlcl` alias.

Full example:

```bash
TNS_ADMIN=/oracle/wallets/atp01
sqlcl admin/myatp_password@atp01_high

SQL>
```

#### Updating `sqlnet.ora` file
When you try to run `sqlcl` using the Oracle Wallet you may get the error `ORA-28759: failure to open file` (see [#13](https://github.com/martindsouza/docker-oracle-sqlcl/issues/13) for more info). This is because of a mapping in the `sqlnet.ora` file that is provided with it. *Note in our example `sqlnet.ora` would be in the unzipped file: `~/Documents/Oracle/wallets/atp01/sqlnet.ora`* You need to change the following in the file:

From: `?/network/admin`
To: `$TNS_ADMIN`

You can also script this using `sed`:

```bash
sed -i .bak "s|?/network/admin|\$TNS_ADMIN|g" $TNS_ADMIN/sqlnet.ora
```

You only need to change this once
