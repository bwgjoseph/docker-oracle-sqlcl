# Original source from https://github.com/lucassampsouza/ords_apex
FROM openjdk:8-jre-alpine
LABEL maintainer="Martin DSouza <martin@talkapex.com>"

ENV TZ="GMT" \
  SQLCL_DIR="/usr/local/sqlcl" \
  SQLCL_BIN_NAME="sqlcl" \ 
  PATH="/usr/local/sqlcl/bin:${PATH}" \
  SQLPATH="/oracle/"

COPY ["files/sqlcl-*.zip", "scripts/*", "/tmp/"]

# This is a dummy volume to reference user's custom scripts
# /sqlcl: For use of pwd
# /oracle: to reference login.sql and sqlcl aliases
VOLUME ["/sqlcl","/oracle"]
WORKDIR "/sqlcl"

RUN chmod +x /tmp/install-sqlcl.sh && \
  apk update && \
  apk upgrade && \
  # bash is required by sqlcl
  apk add bash && \
  # for tput which is required by sqlcl
  apk add ncurses && \
  /tmp/install-sqlcl.sh
  # debug
  # apk add ncurses

ENTRYPOINT ["sqlcl"]
CMD ["/nolog"]

# debug
# ENTRYPOINT [ "/bin/bash" ]