#!/usr/bin/env bash
set -euo pipefail

SEED="${SEED:-1}"
PRE_RUN_TIME="${PRE_RUN_TIME:-1ns}"
USE_XT0="${USE_XT0:-1}"
RESULT_DIR="${RESULT_DIR:-pxp_stress_results}"

# Format: label:num_ops:hw_run_time
MATRIX="${MATRIX:-1M:1000000:20ms 5M:5000000:100ms 10M:10000000:200ms}"

mkdir -p "$RESULT_DIR"

summary="${RESULT_DIR}/summary.tsv"
printf "label\tnum_ops\tsw_real_s\tpxp_real_s\thw_exec_s\tend_to_end_speedup\tsw_to_hw_exec_ratio\tstatus\n" > "$summary"

extract_time_field() {
  local log_file="$1"
  local field="$2"
  awk -v key="$field" '$1 == key {v=$2} END {if (v != "") print v}' "$log_file"
}

extract_hw_exec_seconds() {
  local log_file="$1"
  awk '
    /--- HW execs [0-9]+ evals/ {
      for (i = 1; i <= NF; i++) {
        if ($i == "in") {
          v = $(i + 1)
        }
      }
    }
    END {if (v != "") print v}
  ' "$log_file"
}

calc_ratio() {
  local numerator="$1"
  local denominator="$2"
  awk -v n="$numerator" -v d="$denominator" 'BEGIN {
    if (d > 0) {
      printf "%.3f", n / d
    } else {
      printf "NA"
    }
  }'
}

copy_if_exists() {
  local src="$1"
  local dst="$2"
  if [ -e "$src" ]; then
    rm -rf "$dst"
    cp -a "$src" "$dst"
  fi
}

labels=""
for item in $MATRIX; do
  label="${item%%:*}"
  rest="${item#*:}"
  num_ops="${rest%%:*}"
  hw_run_time="${rest#*:}"
  case_dir="${RESULT_DIR}/${label}"

  mkdir -p "$case_dir"
  echo "[MATRIX][$label] num_ops=$num_ops seed=$SEED hw_run_time=$hw_run_time"

  echo "[MATRIX][$label][PXP] Run hardware acceleration"
  PRE_RUN_TIME="$PRE_RUN_TIME" USE_XT0="$USE_XT0" NUM_OPS="$num_ops" SEED="$SEED" HW_RUN_TIME="$hw_run_time" ./run_pxp_legacy.sh
  copy_if_exists logs_pxp_legacy "${case_dir}/logs_pxp_legacy"
  labels="${labels} ${label}:${num_ops}:${hw_run_time}"

  echo "[MATRIX][$label][PXP] Done"
done

for item in $labels; do
  label="${item%%:*}"
  rest="${item#*:}"
  num_ops="${rest%%:*}"
  case_dir="${RESULT_DIR}/${label}"

  echo "[MATRIX][$label][SW] Run software simulation"
  RUN_ARGS="+case=stress +num_ops=${num_ops} +seed=${SEED}" ./run_sw_legacy.sh
  copy_if_exists logs_sw_legacy "${case_dir}/logs_sw_legacy"

  sw_log="${case_dir}/logs_sw_legacy/run_sw.log"
  pxp_log="${case_dir}/logs_pxp_legacy/run_pxp.log"
  sw_real="$(extract_time_field "$sw_log" real)"
  pxp_real="$(extract_time_field "$pxp_log" real)"
  hw_exec="$(extract_hw_exec_seconds "$pxp_log")"

  status="PASS"
  if ! grep -q "\[TB_LEGACY\]\[PASS\]" "$sw_log"; then
    status="SW_FAIL"
  fi
  if ! grep -q "\[TB_LEGACY\]\[PASS\]" "$pxp_log"; then
    if [ "$status" = "PASS" ]; then
      status="PXP_FAIL"
    else
      status="${status}+PXP_FAIL"
    fi
  fi

  end_to_end="$(calc_ratio "$sw_real" "$pxp_real")"
  hw_exec_ratio="NA"
  if [ -n "$hw_exec" ]; then
    hw_exec_ratio="$(calc_ratio "$sw_real" "$hw_exec")"
  fi

  printf "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n" \
    "$label" "$num_ops" "$sw_real" "$pxp_real" "${hw_exec:-NA}" "$end_to_end" "$hw_exec_ratio" "$status" \
    | tee -a "$summary"

  echo "[MATRIX][$label] Done"
done

echo "[MATRIX] Summary:"
cat "$summary"
