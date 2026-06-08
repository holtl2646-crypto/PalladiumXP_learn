# PalladiumXP (PXP) hardware acceleration report material

鏁寸悊鏃ユ湡锛?026-06-08

## 1. 姹囨姤鎽樿

鏈樁娈靛洿缁?`sc_idu_to_fxu` 娴偣鎵ц鍗曞厓锛屽畬鎴愪簡浠庤繙绋嬭闂€佷豢鐪熺幆澧冪‘璁ゃ€乴egacy testbench 閫傞厤銆佽蒋浠朵豢鐪熷熀绾匡紝鍒?PalladiumXP SA 纭欢鍔犻€熻繍琛岀殑瀹屾暣鎵撻€氥€?
褰撳墠缁撹锛?
- PXP SA 纭欢鍔犻€熼摼璺凡缁忚窇閫氾紝涓嶅彧鏄?`irun -hw` 缂栬瘧閫氳繃銆?- 鐪熸纭欢鎵ц闇€瑕佸湪 `xeDebug` 涓墽琛?`xc on -run -xt0`锛屽苟瑙傚療鍒?emulator swap-in 鍜岀‖浠舵墽琛屾棩蹇椼€?- `sc_idu_to_fxu` 鍦?1M銆?M銆?0M stress 涓嬪潎閫氳繃銆?- 绔埌绔姞閫熸瘮闅忚妯″彉澶ц€屾彁鍗囷細1M 绾?`2.11x`锛?M 绾?`3.27x`锛?0M 绾?`3.66x`銆?- 褰撳墠鐡堕涓昏涓嶆槸 PXP 宄板€艰兘鍔涳紝鑰屾槸 IXCOM SA 妯″紡涓嬭蒋浠?testbench 涓庣‖浠?DUT 涔嬮棿棰戠箒鍚屾銆?
## 2. 鑳屾櫙涓庣洰鏍?
鐩爣妯″潡锛?
```text
sc_idu_to_fxu
```

鐩爣宸ヤ綔锛?
- 寤虹珛鍙鐢ㄧ殑杞欢浠跨湡鍜?PXP 纭欢鍔犻€熻繍琛屾祦绋嬨€?- 鏋勯€犺兘鍦ㄦ棫 Cadence `irun 13.10` 鐜涓嬭繍琛岀殑 testbench銆?- 楠岃瘉鍩烘湰 FP32 FADD/FSUB/FMUL directed case銆?- 鏋勯€?deterministic stress case锛岀敤浜庢瘮杈冭蒋浠朵豢鐪熶笌 PXP 纭欢鎵ц鏁堢巼銆?- 杈撳嚭鍙鐢ㄨ剼鏈拰姹囨姤鏁版嵁銆?
## 3. 鐜涓庤闂矾寰?
褰撳墠璁块棶闄愬埗锛?
- 褰撳墠 Windows PC 涓嶈兘鐩存帴 SSH 鍒颁腑杞満銆?- Windows PC 鍙兘閫氳繃 VNC 璁块棶涓浆鏈恒€?- 涓浆鏈哄彲浠?SSH 鍒?PXP 涓绘満銆?
瀹為檯璁块棶璺緞锛?
```text
Current Windows PC --VNC--> jump workstation --SSH--> PXP host
```

瀹為檯缂栬緫鏂瑰紡锛?
```bash
ssh <pxp-user>@<pxp-host>
cd /path/to/pxp/case_directory
emacs -nw .
```

娉ㄦ剰浜嬮」锛?
- VS Code Remote SSH 鍒?PXP 浼氬洜 PXP 绯荤粺缂哄皯杈冩柊 `glibc` / `libstdc++` 鑰屽け璐ャ€?- 涓嶅缓璁负浜?VS Code Server 鍗囩骇 PXP 绯荤粺搴撱€?- 鍚庣画杩滅▼宸ヤ綔搴旈粯璁ゆ部鐢?VNC + SSH + terminal editor 鐨勮矾寰勩€?
## 4. 宸叉暣鐞嗙殑鏈湴璧勬枡

鏍稿績璁板繂鍜岃鏄庯細

| 鏂囦欢 | 鐢ㄩ€?|
| --- | --- |
| `PXP_project_memory.md` | 椤圭洰涓昏蹇嗭紝璁板綍璁块棶璺緞銆佽剼鏈€侀獙璇佺粨鏋溿€丳XP SA 杩愯鏂规硶鍜屾€ц兘鏁版嵁 |
| `PXP_remote_access.md` | 杩滅▼璁块棶鏂瑰紡銆侀檺鍒跺拰鍙€?SSH 鏂规 |
| `sc_idu_to_fxu_case_plan.md` | testcase 鍒嗗眰璁″垝锛屼粠 smoke 鍒?stress |
| `tb_sc_idu_to_fxu_usage.md` | testbench 浣跨敤鏂规硶銆乸lusargs銆乺untime 姣旇緝鏂瑰紡 |

鍏抽敭鑴氭湰锛?
| 鏂囦欢 | 鐢ㄩ€?|
| --- | --- |
| `run_sw.sh` | 杞欢浠跨湡 smoke 榛樿鍏ュ彛 |
| `run_hw.sh` | `irun -hw` 纭欢缂栬瘧/杩愯鍏ュ彛 |
| `run_sw_legacy.sh` | legacy testbench 杞欢浠跨湡鍏ュ彛 |
| `run_hw_legacy.sh` | legacy testbench 纭欢缂栬瘧鍏ュ彛 |
| `run_pxp_legacy.sh` | 鑷姩 reserve domain銆佺敓鎴?xeDebug 鍛戒护銆佽Е鍙?PXP SA 杩愯 |
| `run_pxp_stress_matrix.sh` | 鎵归噺杩愯 PXP/SW stress matrix 骞剁敓鎴?summary.tsv |

鍏抽敭 testbench锛?
| 鏂囦欢 | 鐢ㄩ€?|
| --- | --- |
| `tb_sc_idu_to_fxu_smoke.v` | 鏈€灏?smoke bench锛岄獙璇?filelist銆乸ackage 鍜?DUT 渚嬪寲 |
| `tb_sc_idu_to_fxu_legacy.v` | 褰撳墠涓诲姏 legacy bench锛屽吋瀹规棫 irun锛屾敮鎸?directed/stress/VCD |
| `tb_sc_idu_to_fxu.sv` | 鏇村畬鏁寸殑 SystemVerilog 鐗堟湰锛岄€傚悎鍚庣画澧炲己 |
| `tb_fxu_opcode_map.svh` | opcode mapping 榛樿瀹氫箟 |

鍙傝€冩墜鍐岋細

| 鏂囦欢 | 鐢ㄩ€?|
| --- | --- |
| `uxeUserGuide.pdf` | UXE/PXP 浣跨敤鎵嬪唽 |
| `uxecmdref.pdf` | UXE/PXP 鍛戒护鍙傝€?|

## 5. Testbench 涓庣敤渚嬭璁?
褰撳墠涓诲姏 bench锛?
```text
tb_sc_idu_to_fxu_legacy.v
```

鐗堟湰鏍囪锛?
```text
[TB_LEGACY] version 2026-06-05-legacy-v3-fast-stress
```

宸插鐞嗙殑鏃у伐鍏峰吋瀹归棶棰橈細

- 閬垮厤 `string`銆?- 閬垮厤 `void'(...)`銆?- 閬垮厤 `$fatal`銆?- 閬垮厤 SystemVerilog `'0`銆乣'd4` 绛夋柊璇硶銆?- 灏介噺浣跨敤 Verilog-2001 椋庢牸銆?- directed/stress 椹卞姩鏀瑰埌 `negedge`锛屽噺灏戝悓杈规部绔炰簤銆?
褰撳墠 opcode mapping锛?
```verilog
`define TB_OP_FADD_S {20'b1, 1'b0}
`define TB_OP_FSUB_S {20'b10, 1'b0}
`define TB_OP_FMUL_S {20'b100, 1'b0}
`define TB_OP_FEQ_S  {20'b100000, 1'b0}
`define TB_OP_FLT_S  {20'b1000000, 1'b0}
`define TB_OP_FLE_S  {20'b10000000, 1'b0}
`define TB_ROUND_RNE 0
```

宸查獙璇?瑙勫垝鐨勭敤渚嬪眰娆★細

| 灞傜骇 | 鐢ㄤ緥 | 鐩殑 |
| --- | --- | --- |
| Case 0 | smoke reset/idle | 楠岃瘉澶嶄綅銆佺┖闂插拰 DUT 渚嬪寲 |
| Case 1 | directed FADD/FSUB/FMUL | 楠岃瘉鍩烘湰 FP32 FMA datapath 鍜?FRF writeback |
| Case 2 | compare/sign/minmax | 鎵╁睍 XRF/FRF 鍐欏洖璺緞 |
| Case 3 | IEEE-754 special values | 楠岃瘉 NaN銆乮nf銆乻ubnormal銆亃ero sign 绛夎竟鐣?|
| Case 4 | rounding/conversion | 楠岃瘉 rounding mode 鍜?fflags |
| Case 5 | back-to-back issue | 楠岃瘉 pipeline scheduling 鍜?pending |
| Case 6 | deterministic stress | 鐢ㄤ簬闀胯窇鍜?SW/PXP runtime 瀵规瘮 |
| Case 7 | compile once, replay many tests | 灞曠ず PXP 缂栬瘧澶嶇敤浠峰€?|

## 6. 鍔熻兘楠岃瘉缁撴灉

Smoke test 宸查€氳繃锛?
```text
[TB_SMOKE] version 2026-06-03-smoke-v1
[TB_SMOKE][PASS]
```

璇存槑锛?
- filelist 鍙敤銆?- `springcore_pkg.v` 鍙壘鍒般€?- `sc_idu_to_fxu` 椤跺眰绔彛渚嬪寲鍙€氳繃銆?- 杞欢 `irun` compile/elaboration/run 娴佺▼鍙敤銆?
Directed case 鍒濇湡鍑虹幇 quiet NaN锛?
```text
0xffffffff7fc00000
```

瀹氫綅缁撹锛?
- DUT 鎺ュ彈 opcode 骞朵骇鐢?FRF writeback銆?- 缁撴灉涓?quiet NaN锛屽師鍥犳槸 FP32 鎿嶄綔鏁伴渶瑕佹寜 64-bit FP register 鏍煎紡鍋?NaN-boxing銆?
淇鏂瑰紡锛?
```text
upper 32 bits = 0xffffffff
lower 32 bits = fp32 value
```

鏈熸湜 directed 姝ｇ‘缁撴灉锛?
```text
0xffffffff40400000
```

鍏朵腑浣?32 bits `0x40400000` 琛ㄧず FP32 `3.0`銆?
## 7. PXP SA 纭欢鍔犻€熻繍琛屾柟娉?
鍏抽敭淇锛?
浠?`run_hw_legacy.sh` 鎴?plain `irun -R` 缂栬瘧閫氳繃锛屼笉瓒充互璇佹槑 DUT 宸茬粡鍦?PalladiumXP 涓婃墽琛屻€傜湡姝ｇ‖浠舵墽琛岄渶瑕佽繘鍏?`xeDebug` 骞惰Е鍙?hot swap锛?
```text
xc on -run -xt0
```

纭欢鎵ц璇佹嵁锛?
```text
Starting swap into the emulator.
Finished swap into the emulator.
--- HW execs swapin in ...
--- HW execs ... evals ... in ... sec
```

domain 涔熼渶瑕佹樉绀虹湡瀹?design锛岃€屼笉鏄粎 `RESERVED*`锛?
```text
Domain 0  Owner ...  Design SA:tb_sc_idu_to_
```

鎺ㄨ崘鑷姩鍖栧叆鍙ｏ細

```bash
./run_pxp_legacy.sh
```

甯哥敤鍙傛暟锛?
```bash
PRE_RUN_TIME=1ns USE_XT0=1 NUM_OPS=1000000 HW_RUN_TIME=20ms ./run_pxp_legacy.sh
NUM_OPS=10000000 HW_RUN_TIME=200ms ./run_pxp_legacy.sh
```

鎵归噺 stress 鍏ュ彛锛?
```bash
MATRIX="1M:1000000:20ms 5M:5000000:100ms" ./run_pxp_stress_matrix.sh
```

榛樿 matrix锛?
```text
1M:1000000:20ms
5M:5000000:100ms
10M:10000000:200ms
```

## 8. 鎬ц兘缁撴灉

宸查獙璇?stress matrix锛?
| label | num_ops | SW real (s) | PXP real (s) | HW exec (s) | 绔埌绔姞閫熸瘮 | SW/HW exec 姣?| 鐘舵€?|
| --- | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| 1M | 1,000,000 | 281.85 | 133.67 | 38.17 | 2.109x | 7.384x | PASS |
| 5M | 5,000,000 | 922.95 | 282.66 | 187.13 | 3.265x | 4.932x | PASS |
| 10M | 10,000,000 | 1727.26 | 472.05 | 376.62 | 3.659x | 4.586x | PASS |

鎸囨爣瀹氫箟锛?
- `SW real`锛氱函杞欢 `irun/ncsim` wall-clock runtime銆?- `PXP real`锛歅XP 绔埌绔?runtime锛屽寘鎷?reserve銆亁eDebug startup銆乭ost connection銆乻wap-in銆佺‖浠舵墽琛屽拰娓呯悊銆?- `HW exec`锛歅XP 鏃ュ織涓?`--- HW execs ... in ... sec` 鎶ュ憡鐨勭‖浠舵墽琛屾銆?- 涓昏姹囨姤鎸囨爣浣跨敤 `SW real / PXP real`锛屽嵆绔埌绔姞閫熸瘮銆?- `SW real / HW exec` 鍙睍绀虹‖浠舵墽琛屾綔鍔涳紝浣嗕笉鏄畬鏁寸敤鎴蜂晶鑰楁椂銆?
缁撹锛?
- 1M stress锛氱鍒扮绾?`2.11x`銆?- 5M stress锛氱鍒扮绾?`3.27x`銆?- 10M stress锛氱鍒扮绾?`3.66x`銆?- workload 瓒婂ぇ锛宺eserve銆亁eDebug銆乻wap 绛夊浐瀹氬紑閿€瓒婂鏄撹鎽婅杽銆?
## 9. cycles/s 浼扮畻

鍋囪锛?
```text
CLK_PERIOD_NS = 10
cycles ~= simulation_time_ns / 10
```

浼扮畻缁撴灉锛?
| label | cycles 浼扮畻 | SW cycles/s | PXP HW exec cycles/s |
| --- | ---: | ---: | ---: |
| 1M | 1,002,019 | 3.56K | 26.25K |
| 5M | 5,002,019 | 5.42K | 26.73K |
| 10M | 10,002,019 | 5.79K | 26.56K |

瑙傚療锛?
- 绾蒋浠朵豢鐪熺害 `3.5K-5.8K cycles/s`銆?- PXP 纭欢鎵ц娈电ǔ瀹氬湪 `26K-27K cycles/s`銆?- PXP 鎵ц閫熷害璺?1M/5M/10M 鍩烘湰绋冲畾銆?
## 10. 鐡堕涓庨檺鍒?
PXP 缂栬瘧鎶ュ憡涓?emulator 鏈€澶ч€熷害鍙揪 MHz 绾э紝浣嗗綋鍓嶅疄娴嬪彧鏈夌害 `26K-27K cycles/s`锛屼富瑕佸師鍥犳槸锛?
- 褰撳墠鏄?IXCOM SA 妯″紡锛屼笉鏄畬鏁?testbench-on-hardware emulation銆?- `sc_idu_to_fxu` 鍦ㄧ‖浠朵笂锛屼絾 Verilog testbench 浠嶅湪杞欢渚с€?- testbench 姣忓懆鏈熼┍鍔ㄦ搷浣滐紝瀵艰嚧杞欢鍜?PXP 涔嬮棿棰戠箒鍚屾銆?- 鏃ュ織涓彲瑙佸ぇ閲?`tbsyncs`銆乮nput events銆乷utput events銆?- 鍙鎬фā寮忋€乸robe銆丗ullVision銆佹尝褰笂浼犵瓑閮戒細杩涗竴姝ュ奖鍝嶉€熷害銆?
鍥犳锛屽綋鍓嶆暟鎹簲瑙ｈ涓猴細

- 鍔熻兘涓婏細PXP SA 閾捐矾宸茬粡鎵撻€氥€?- 鎬ц兘涓婏細宸茬粡鏈夌鍒扮鍔犻€燂紝浣嗕粛鍙?SA 杈圭晫鍚屾闄愬埗銆?- 鍚庣画鑻ヨ鎺ヨ繎 PXP 宄板€硷紝搴斿噺灏?host/testbench 浜や簰鎴栨妸鏇村婵€鍔?妫€鏌ラ€昏緫涓嬫矇鍒扮‖浠朵晶銆?
## 11. 甯歌闂涓庡鐞?
| 闂 | 鐜拌薄 | 澶勭悊 |
| --- | --- | --- |
| `.design` 涓㈠け | `xeDebug` 鎶?`Failed to read file ./.design` | 閲嶆柊璺戠‖浠?compile/elaborate |
| 鍙?reserve 鏈笅杞借璁?| `test_server` 鍙樉绀?`RESERVED*` | 闇€瑕佹墽琛?`xc on -run -xt0` |
| `xc on -run` 澶辫触 | `Back to SIM: found x values` | 浣跨敤 `xc on -run -xt0` |
| `download` 鍛戒护涓嶅彲鐢?| manual command 鏃犳晥 | SA 妯″紡涓?download 闅?`xc on` 闅愬紡瑙﹀彂 |
| `xeDebug -key` 鏃犳晥 | option ignored | 鍦?XE prompt 涓墽琛?`xeset reserveKey <key>` |
| `10M` timeout | SW/PXP 閮芥姤 timeout | 灏?`TIMEOUT_CYCLES` 鎻愰珮鍒?`20000000` |
| `test_server` top 鍚嶉敊璇?| 鏌ヤ笉鍒?design/location | 浣跨敤纭欢鏁版嵁搴?top `xcva_top` |

## 12. 鍚庣画璁″垝

寤鸿鍚庣画鎸変笁鏉＄嚎鎺ㄨ繘锛?
1. 鍔熻兘瑕嗙洊澧炲己

缁х画琛ラ綈 compare銆乻ign/minmax銆乻pecial values銆乺ounding/conversion 绛夌敤渚嬶紝骞跺鍔犵簿纭?result/fflags 妫€鏌ャ€?
2. 鎬ц兘璺緞浼樺寲

鍑忓皯姣忓懆鏈?host/PXP 鍚屾锛屽皾璇曟壒閲?stimulus銆佺‖浠朵晶 driver/checker 鎴栨洿浣庝氦浜掔殑 replay 妯″紡锛涙€ц兘璺戜繚鎸佹渶灏?visibility銆?
3. 宸ョ▼鍖栧鐢?
淇濈暀 `run_pxp_legacy.sh` 鍜?`run_pxp_stress_matrix.sh` 浣滀负鏍囧噯鍏ュ彛锛屽浐瀹氭棩蹇楃洰褰曞拰 summary.tsv 杈撳嚭鏍煎紡锛屼究浜庡悗缁噸澶嶈窇鍜屾í鍚戞瘮杈冦€?
## 13. PPT 椤电翰寤鸿

绗?1 椤碉細椤圭洰鐩爣

- `sc_idu_to_fxu` 娴偣鎵ц鍗曞厓 PXP 鍔犻€熼獙璇?- 鐩爣锛氳窇閫氶摼璺€侀獙璇佸姛鑳姐€侀噺鍖?SW/PXP 鎬ц兘

绗?2 椤碉細鐜涓庤闂害鏉?
- Windows PC -> VNC -> 涓浆鏈?-> SSH -> PXP
- VS Code Remote SSH 涓嶉€傜敤锛岄噰鐢?terminal workflow

绗?3 椤碉細楠岃瘉鏋舵瀯

- DUT锛歚sc_idu_to_fxu`
- testbench锛歭egacy Verilog bench
- 杞欢 baseline锛歚irun/ncsim`
- 纭欢璺緞锛欼XCOM SA + `xc on -run -xt0`

绗?4 椤碉細鐢ㄤ緥璁捐

- smoke
- directed FP32 FADD/FSUB/FMUL
- deterministic stress
- 鍚庣画 corner/rounding/conversion

绗?5 椤碉細鍏抽敭 bring-up 闂

- old irun 鍏煎
- FP32 NaN-boxing
- `xc on -run -xt0`
- `.design` 鍜?`xcva_top`

绗?6 椤碉細鍔熻兘缁撴灉

- smoke PASS
- directed writeback 璺緞鎵撻€?- stress 1M/5M/10M PASS

绗?7 椤碉細鎬ц兘缁撴灉

- 灞曠ず 1M/5M/10M 琛ㄦ牸
- 绔埌绔姞閫熸瘮锛?.11x / 3.27x / 3.66x

绗?8 椤碉細鎬ц兘瑙ｈ

- PXP HW exec 绋冲畾绾?26K-27K cycles/s
- SA 杈圭晫鍚屾鏄綋鍓嶄富瑕侀檺鍒?- workload 瓒婂ぇ锛屽浐瀹氬紑閿€鎽婅杽瓒婃槑鏄?
绗?9 椤碉細涓嬩竴姝?
- 鎵╁姛鑳借鐩?- 闄嶅悓姝ュ紑閿€
- 鍥哄寲 matrix 鍜屾棩蹇楃粺璁℃祦绋?
## 14. 鍙洿鎺ュ彛澶存眹鎶ョ増鏈?
杩欐宸ヤ綔涓昏瀹屾垚浜?`sc_idu_to_fxu` 鍦?PalladiumXP 涓婄殑纭欢鍔犻€?bring-up銆傚墠鏈熷厛瑙ｅ喅浜嗚闂矾寰勫拰鏃?Cadence 宸ュ叿鍏煎闂锛屾瀯閫犱簡涓€涓?legacy Verilog testbench锛屽厛閫氳繃 smoke 纭 filelist銆乸ackage 鍜?DUT 渚嬪寲锛屽啀閫氳繃 directed case 楠岃瘉 FP32 FADD/FSUB/FMUL 鐨?writeback 璺緞銆?
杩囩▼涓彂鐜?FP32 鎿嶄綔鏁伴渶瑕佹寜鐓?64-bit FP register 鏍煎紡鍋?NaN-boxing锛屽惁鍒欑粨鏋滀細鍙樻垚 quiet NaN銆備慨姝ｅ悗 testbench 鍙互浣滀负鍚庣画 directed 鍜?stress 鐨勪富鍔涘叆鍙ｃ€?
纭欢渚ф渶鍏抽敭鐨勭粨璁烘槸锛宲lain `irun -R` 鎴?`run_hw_legacy.sh` 缂栬瘧閫氳繃骞朵笉绛変簬鐪熸璺戝湪 PXP 涓娿€傜湡姝ｇ殑 SA 纭欢鎵ц闇€瑕佸湪 `xeDebug` 涓缃?reserve key锛屽苟鎵ц `xc on -run -xt0`銆傛垚鍔熸椂鏃ュ織浼氬嚭鐜?swap into emulator 鍜?`--- HW execs ...` 鐨勭‖浠舵墽琛岀粺璁°€?
鎬ц兘鏂归潰锛屽綋鍓?1M銆?M銆?0M stress 鍧?PASS銆傜鍒扮鍔犻€熸瘮鍒嗗埆绾︿负 2.11x銆?.27x銆?.66x锛岃鏄?workload 鍙樺ぇ鍚庡浐瀹氬紑閿€琚憡钖勶紝PXP 鐨勬敹鐩婃洿鏄庢樉銆傜‖浠舵墽琛屾绋冲畾鍦ㄧ害 26K-27K cycles/s锛屼絾杩樹綆浜?PXP 鐞嗚鑳藉姏锛屼富瑕佸彈 IXCOM SA 妯″紡涓嬭蒋浠?testbench 涓庣‖浠?DUT 棰戠箒鍚屾闄愬埗銆?
涓嬩竴姝ュ缓璁噸鐐瑰仛涓や欢浜嬶細涓€鏄ˉ榻?corner銆乺ounding銆乧onversion 绛夊姛鑳借鐩栧拰绮剧‘ result/fflags 妫€鏌ワ紱浜屾槸浼樺寲鎬ц兘娴嬭瘯缁撴瀯锛屽噺灏?host/PXP 鍚屾锛屾妸鏇村 stimulus/checker 涓嬫矇鎴栨壒閲忓寲锛屼粠鑰屾洿鎺ヨ繎 PXP 纭欢鎵ц鑳藉姏銆?
