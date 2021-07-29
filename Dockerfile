FROM adoptopenjdk/openjdk11:jre-11.0.11_9-alpine
LABEL org.opencontainers.image.authors="Joseph Gan <josephgan@live.com.sg>"

ENV TZ="Asia/Singapore" \
  SQLCL_DIR="/usr/local/sqlcl" \
  SQLCL_BIN_NAME="sqlcl" \
  PATH="/usr/local/sqlcl/bin:${PATH}" \
  SQLPATH="/oracle" \
  # #12 Fixes issue with 20.2
  LANG="en_US.utf8" \
  SH_SCRIPT_FILENAME=run.sh

COPY ["files/sqlcl-*.zip", "scripts/*", "/tmp/"]

# /oracle: to reference login.sql and sqlcl aliases
# VOLUME ["/sqlcl","/oracle"]
VOLUME ["/oracle"]
WORKDIR "/oracle"

RUN echo "" && \
  chmod +x /tmp/install-sqlcl.sh && \
  chmod +x /tmp/start-container.sh && \
  apk update && \
  apk upgrade && \
  # bash is required by sqlcl
  apk add bash && \
  # for tput which is required by sqlcl
  apk add ncurses && \
  /tmp/install-sqlcl.sh && \
  # debug
  # apk add ncurses
  echo ""

# #9: Used to be just sqlcl but caused an issue when $TNS_ADMIN was not set
ENTRYPOINT ["/tmp/start-container.sh"]
CMD ["/nolog"]

# debug
# ENTRYPOINT [ "/bin/bash" ]