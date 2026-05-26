#!/bin/bash
LOG=/opt/clones/clara/bot/logs/scrape-claro-weekly.log
TS=$(date -Iseconds)
echo "[$TS] start" >> $LOG
cd /opt/clones/clara/workspace
node scripts/scrape-claro.mjs >> $LOG 2>&1
echo "[$TS] done" >> $LOG
