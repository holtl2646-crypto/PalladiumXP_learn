#!/usr/bin/env bash
set -euo pipefail

TOP_HW="${TOP_HW:-xcva_top}"
CASE="${CASE:-stress}"
NUM_OPS="${NUM_OPS:-1000000}"
SEED="${SEED:-1}"
SA_HOST="${SA_HOST:-acc}"
BOARD_DOMAIN="${BOARD_DOMAIN:-0.0}"
RESERVE_TIMEOUT="${RESERVE_TIMEOUT:-300s}"
PRE_RUN_TIME="${PRE_RUN_TIME:-195ns}"
HW_RUN_TIME="${HW_RUN_TIME:-20ms}"
USE_XT0="${USE_XT0:-1}"
LOG_DIR="${LOG_DIR:-logs_pxp_legacy}"

mkdir -p "$LOG_DIR"

echo "[PXP] Reserve ${TOP_HW} on ${SA_HOST}, preferred domain ${BOARD_DOMAIN}"
echo "$BOARD_DOMAIN" > "${TOP_HW}.bp"
rm -f "dbFiles/${TOP_HW}.bp" 2>/dev/null || true

reserve_log="${LOG_DIR}/reserve.log"
test_server "$TOP_HW" -reserve -timeout "$RESERVE_TIMEOUT" | tee "$reserve_log"

reserve_key="$(
  sed -n 's/.*key \([0-9][0-9]*\).*/\1/p' "$reserve_log" | tail -1
)"

if [ -z "$reserve_key" ]; then
  echo "[PXP][ERROR] Failed to parse reserve key from $reserve_log" >&2
  exit 1
fi

echo "[PXP] Reserved key: $reserve_key"
test_server | tee "${LOG_DIR}/test_server_after_reserve.log"

xe_tcl="${LOG_DIR}/pxp_run.tcl"
{
  echo "xeset reserveKey $reserve_key"
  echo "run $PRE_RUN_TIME"
  echo "xc status"
  if [ "$USE_XT0" = "1" ]; then
    echo "xc on -run -xt0"
  else
    echo "xc on -run"
  fi
  echo "xc status"
  echo "host -location"
  echo "run $HW_RUN_TIME"
  echo "xc status"
  echo "exit"
} > "$xe_tcl"

echo "[PXP] xeDebug command script:"
cat "$xe_tcl"

echo "[PXP] Run irun/xeDebug. Watch hardware with: watch -n 1 test_server"
/usr/bin/time -p irun -R \
  "+case=${CASE}" "+num_ops=${NUM_OPS}" "+seed=${SEED}" \
  -xedebug \
  -xedebugargs "-input ${xe_tcl}" \
  2>&1 | tee "${LOG_DIR}/run_pxp.log"

run_status=${PIPESTATUS[0]}

echo "[PXP] Final test_server state:"
test_server | tee "${LOG_DIR}/test_server_after_run.log"

exit "$run_status"
