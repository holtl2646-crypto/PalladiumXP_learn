#!/usr/bin/env bash
set -o pipefail

TOP=tb_sc_idu_to_fxu_legacy \
TB_FILE=tb_sc_idu_to_fxu_legacy.v \
LOG_DIR="${LOG_DIR:-logs_hw_legacy}" \
./run_hw.sh
