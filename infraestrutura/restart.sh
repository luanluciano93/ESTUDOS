#!/bin/bash

# dar permissão para o arquivo restart.sh: $ chmod +x restart.sh&

# Permitir despejos de núcleo
ulimit -c unlimited

# Definir diretório de trabalho
cd /home/otsmanager/forgottenserver

# Laço principal
while true; do
  ./tfs >> /home/otsmanager/forgottenserver/relatorio.log &
  PID=$!
  echo $PID > tfs.pid
  wait $PID
  sleep 5
done
