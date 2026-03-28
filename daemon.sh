#!/bin/bash
# OpenClaw Control Center daemon script
PIDFILE="/home/danniel-c/openclaw-control-center/control-center.pid"
LOGFILE="/home/danniel-c/openclaw-control-center/runtime/daemon.log"
cd /home/danniel-c/openclaw-control-center

start() {
  if [ -f "$PIDFILE" ] && kill -0 $(cat "$PIDFILE") 2>/dev/null; then
    echo "Control Center already running (PID $(cat $PIDFILE))"
    return 0
  fi
  echo "Starting OpenClaw Control Center..."
  nohup /usr/bin/node --import tsx src/index.ts >> "$LOGFILE" 2>&1 &
  echo $! > "$PIDFILE"
  sleep 2
  if kill -0 $(cat "$PIDFILE") 2>/dev/null; then
    echo "Started (PID $(cat $PIDFILE))"
  else
    echo "Failed to start - check $LOGFILE"
    return 1
  fi
}

stop() {
  if [ -f "$PIDFILE" ]; then
    PID=$(cat "$PIDFILE")
    if kill -0 "$PID" 2>/dev/null; then
      kill "$PID" && echo "Stopped PID $PID"
      rm -f "$PIDFILE"
    else
      echo "Process $PID not running"
      rm -f "$PIDFILE"
    fi
  else
    echo "No PID file found"
  fi
}

case "${1:-start}" in
  start) start ;;
  stop)  stop ;;
  restart) stop; start ;;
  status)
    if [ -f "$PIDFILE" ] && kill -0 $(cat "$PIDFILE") 2>/dev/null; then
      echo "Running (PID $(cat $PIDFILE))"
    else
      echo "Not running"
    fi
    ;;
esac
