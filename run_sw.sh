#!/usr/bin/env bash
set -o pipefail

TOP="${TOP:-tb_sc_idu_to_fxu_smoke}"
FILELIST="${FILELIST:-filelist}"
TB_FILE="${TB_FILE:-tb_sc_idu_to_fxu_smoke.v}"
DEFINE_ARGS="${DEFINE_ARGS:-+define+PIPE_INFO_FOR_TEST}"
EXTRA_ARGS="${EXTRA_ARGS:-}"
RUN_ARGS="${RUN_ARGS:-}"

LOG_DIR="${LOG_DIR:-logs_sw}"
mkdir -p "$LOG_DIR"

echo "[SW] Clean old irun output"
rm -rf ncowrk xc_ncwork .ncsim* .irun* snapshot .design

echo "[SW] Compile/elaborate only: TOP=$TOP FILELIST=$FILELIST TB_FILE=$TB_FILE"
/usr/bin/time -p irun -elaborate -ua -sv +incdir+. "$TB_FILE" +dut+sc_idu_to_fxu -f "$FILELIST" -top "$TOP" $DEFINE_ARGS $EXTRA_ARGS \
    2>&1 | tee "$LOG_DIR/compile_sw.log"

compile_status=${PIPESTATUS[0]}
if [ "$compile_status" -ne 0 ]; then
    echo "[SW] Compile failed: $compile_status"
    exit "$compile_status"
fi

echo "[SW] Run simulation"
/usr/bin/time -p irun -R $RUN_ARGS 2>&1 | tee "$LOG_DIR/run_sw.log"

run_status=${PIPESTATUS[0]}
echo "[SW] Runtime summary"
grep -E "^(real|user|sys) " "$LOG_DIR/run_sw.log" || true

exit "$run_status"
