#!/bin/bash
while true; do
  timestamp=$(date +%s)
  hits=$(redis-cli INFO | grep keyspace_hits | cut -d: -f2 | tr -d '\r')
  misses=$(redis-cli INFO | grep keyspace_misses | cut -d: -f2 | tr -d '\r')
  memory=$(redis-cli INFO | grep used_memory: | cut -d: -f2 | tr -d '\r')
  echo "$timestamp,$hits,$misses,$memory" >> redis_metrics.csv
  sleep 1
done