# Usage

Update or remove `networks` portion in `docker-compose.yaml` if required. In this case, I have a `oracledb` instance running on `orcl` network, hence, setting the network allow this instance to be able to hit `oracledb`

Supply whatever custom code you wish to run in `/oracle/run.sh` then run `docker-compose up`

Alternatively, run `docker run -it --rm -v /path/to/oracle:/oracle bwgjoseph/oracle-sqlcl:21.2.1.195.1252` without `docker-compose`
