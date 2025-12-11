#!/bin/bash

TOPIC="persistent://public/default/sync-topic"
DURATION=60
RATE=10000
MSG_SIZE=1024
REPEATS=1

for i in $(seq 1 $REPEATS); do
  echo "======================================"
  echo "Run #$i"
  echo "======================================"

  PRODUCER_LOG="/tmp/producer_run_${i}.log"
  CONSUMER_LOG="/tmp/consumer_run_${i}.log"

  echo "Starting producer and consumer in parallel..."

  # Producer im Hintergrund starten
  pulsar-perf produce -r $RATE -s $MSG_SIZE --test-duration $DURATION $TOPIC > $PRODUCER_LOG 2>&1 &

  PRODUCER_PID=$!

  # Consumer im Hintergrund starten
  pulsar-perf consume \
   --subscription-type Shared \
   --subscription-position Earliest \
   --test-duration $DURATION \
   $TOPIC > $CONSUMER_LOG 2>&1 & 
 
  CONSUMER_PID=$!

  # Auf beide Prozesse warten
  wait $PRODUCER_PID
  wait $CONSUMER_PID

  echo "Run #$i finished. Logs saved as $PRODUCER_LOG and $CONSUMER_LOG"
  echo ""
done

echo "All $REPEATS runs completed."

