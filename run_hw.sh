#!/usr/bin/env bash
set -o pipefail

TOP="${TOP:-tb_sc_idu_to_fxu_smoke}"
FILELIST="${FILELIST:-filelist}"
TB_FILE="${TB_FILE:-tb_sc_idu_to_fxu_smoke.v}"
DEFINE_ARGS="${DEFINE_ARGS:-+define+PIPE_INFO_FOR_TEST}"
EXTRA_ARGS="${EXTRA_ARGS:-}"
RUN_ARGS="${RUN_ARGS:-}"

LOG_DIR="${LOG_DIR:-logs_hw}"
mkdir -p "$LOG_DIR"

echo "[HW] Clean old irun output"
rm -rf ncowrk xc_ncwork .ncsim* .irun* snapshot .design

echo "[HW] Hardware clean"
irun -hw -clean 2>&1 | tee "$LOG_DIR/clean_hw.log"

clean_status=${PIPESTATUS[0]}
if [ "$clean_status" -ne 0 ]; then
    echo "[HW] Hardware clean failed: $clean_status"
    exit "$clean_status"
fi

echo "[HW] Compile/elaborate only for hardware: TOP=$TOP FILELIST=$FILELIST TB_FILE=$TB_FILE"
/usr/bin/time -p irun -elaborate -hw -ua -sv +incdir+. "$TB_FILE" +dut+sc_idu_to_fxu -f "$FILELIST" -top "$TOP" $DEFINE_ARGS $EXTRA_ARGS \
    2>&1 | tee "$LOG_DIR/compile_hw.log"

compile_status=${PIPESTATUS[0]}
if [ "$compile_status" -ne 0 ]; then
    echo "[HW] Compile failed: $compile_status"
    exit "$compile_status"
fi

echo "[HW] Run simulation"
/usr/bin/time -p irun -R $RUN_ARGS 2>&1 | tee "$LOG_DIR/run_hw.log"

run_status=${PIPESTATUS[0]}
echo "[HW] Runtime summary"
grep -E "^(real|user|sys) " "$LOG_DIR/run_hw.log" || true

exit "$run_status"
