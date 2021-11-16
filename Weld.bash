
#!/bin/bash
#set -e
#
#echo "==> Launching the Docker daemon..."
#CMD=$*
#if [ "$CMD" == '' ];then
#  dind dockerd $DOCKER_EXTRA_OPTS
#  check_docker
#else
#  dind dockerd $DOCKER_EXTRA_OPTS &
#  while(! docker info > /dev/null 2>&1); do
#      echo "==> Waiting for the Docker daemon to come online..."
#      sleep 1
#  done
#  echo "==> Docker Daemon is up and running!"
#  echo "==> Running CMD $CMD!"
#  exec "$CMD"
#fi
set -e
if [ $# -gt 0 ]
then
  DOCKER_OPTS="${DOCKER_OPTS:-"--bip=192.168.0.1/24"}"
  if [ "${DOCKER_STRG}" = "true" ]
  then
    if [ -f "/proc/filesystems" ]
    then
      if [ "$(grep overlay /proc/filesystems)" ]
      then
        STORAGE_DRIVER="overlay2"
      elif [ "$(grep aufs /proc/filesystems)" ]
      then
        STORAGE_DRIVER="aufs"
      else
        STORAGE_DRIVER="vfs"
      fi
      DOCKER_OPTS+=" --storage-driver ${STORAGE_DRIVER}"
    fi
  fi
  echo "== Starting Docker Engine with the following options: ${DOCKER_OPTS} =="
  dind dockerd ${DOCKER_OPTS} >/docker.log 2>&1 &
#  /usr/local/bin/dockerd-entrypoint.sh ${DOCKER_OPTS} >/docker.log 2>&1 &
   echo "== Waiting for Docker Engine process to start =="
  sleep 10
   curl -v -XGET -S -o /dev/null \
    --retry 10 --retry-delay 12 \
    --unix-socket /var/run/docker.sock \
    http://DOCKER/_ping || (cat /docker.log && exit 1)
   [ "$(curl -sS -X GET --unix-socket /var/run/docker.sock http:/images/_ping)" == "OK" ]
  echo "== Docker Engine started and ready =="
  if [ -n "${DOCKER_CACHE}" ] && [ -d "${DOCKER_CACHE}" ]
  then
    echo "== Variable 'DOCKER_CACHE' found and pointing to an existing Directory =="
    echo "== Loading following .tar files in Docker: =="
    find "${DOCKER_CACHE}" -type f -name "*.gz" -print \
      -exec sh -c 'gunzip --stdout "$1" | docker load' -- {} \;
  fi
  shift
  echo "== Launching the following user-provided command: ${*}"
  exec /bin/sh -c "$@"
fi
