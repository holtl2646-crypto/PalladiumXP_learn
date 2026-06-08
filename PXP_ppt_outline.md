# PXP 鎶€鏈瘎瀹?PPT 椤电

鏁寸悊鏃ユ湡锛?026-06-08

## 绗?1 椤碉細鏍囬涓庣粨璁?
鏍囬锛歚sc_idu_to_fxu` PalladiumXP SA 纭欢鍔犻€熼獙璇?
椤甸潰瑕佺偣锛?
- PXP SA 閾捐矾宸叉墦閫氾紝涓嶈兘鍙湅 `irun -hw`锛岄渶瑕佺湡瀹?`xc on -run -xt0` 鎵ц璇佹嵁銆?- 1M / 5M / 10M deterministic stress 鍧?PASS銆?- 绔埌绔姞閫熸瘮绾?`2.11x / 3.27x / 3.66x`銆?- 褰撳墠鐡堕涓昏鏉ヨ嚜 IXCOM SA 杈圭晫鍚屾鍜屼簨浠朵紶杈撱€?
璁茬澶囨敞锛?
杩欓〉鐩存帴缁欑粨璁猴細鍔熻兘涓婂凡缁忚窇閫氾紝鎬ц兘涓婂凡缁忕湅鍒扮鍒扮鏀剁泭锛屼絾褰撳墠娴嬪埌鐨勯€熷害涓嶆槸 PXP 宄板€硷紝鑰屾槸杩欎釜 SA workload 鐨勭湡瀹炲伐绋嬭〃鐜般€?
鍥捐〃寤鸿锛?
- 涓変釜澶ф暟瀛楀崱鐗囷細`2.11x`銆乣3.27x`銆乣3.66x`銆?- 涓€涓煭缁撹鏉★細`True PXP SA execution verified`銆?
## 绗?2 椤碉細楠岃瘉鐩爣涓庣幆澧?
椤甸潰瑕佺偣锛?
- DUT锛歚sc_idu_to_fxu` 娴偣鎵ц鍗曞厓銆?- 杞欢鍩虹嚎锛欳adence `irun(64): 13.10-s010`銆?- 璁块棶璺緞锛歚Windows PC --VNC--> <jump-host> --SSH--> <pxp-host>`銆?- 瀹為檯缂栬緫/杩愯锛歅XP 缁堢鐜锛屼娇鐢?conservative Verilog legacy bench銆?
璁茬澶囨敞锛?
杩欓噷寮鸿皟鐜绾︽潫锛氫笉鏄櫘閫氭湰鍦颁豢鐪燂紝涔熶笉鏄洿鎺?SSH 鍒?PXP銆傛棫宸ュ叿绾︽潫鍐冲畾浜?testbench 蹇呴』淇濆畧銆?
鍥捐〃寤鸿锛?
- 璁块棶璺緞娴佺▼鍥俱€?- DUT / TB / SW baseline / PXP SA 鍥涗釜妯″潡妗嗐€?
## 绗?3 椤碉細PXP SA 鐪熷疄鎵ц璇佹嵁閾?
椤甸潰瑕佺偣锛?
- `run_hw_legacy.sh` 鎴?plain `irun -R` 缂栬瘧閫氳繃锛屼笉绛変簬鐪熸鍦?PXP 鎵ц銆?- 鐪熸纭欢鎵ц鍏抽敭鍛戒护锛歚xc on -run -xt0`銆?- 璇佹嵁鍖呮嫭 swap-in 鏃ュ織銆乣--- HW execs ...` 缁熻銆乣test_server` 鐪嬪埌 design 缁戝畾銆?- `RESERVED*` 鍙〃绀哄煙琚繚鐣欙紝涓嶄唬琛ㄨ璁″凡涓嬭浇杩愯銆?
璁茬澶囨敞锛?
杩欓〉鏄瘎瀹℃渶瀹规槗闂埌鐨勫湴鏂癸細鎬庝箞璇佹槑涓嶆槸杞欢鍦ㄨ窇銆傚洖绛旇钀藉埌涓夌被璇佹嵁锛氬懡浠ゃ€佹棩蹇椼€乨omain 鐘舵€併€?
鍥捐〃寤鸿锛?
- 涓夋璇佹嵁閾撅細reserve domain -> xeDebug hot swap -> HW exec stats銆?
## 绗?4 椤碉細鍔熻兘 bring-up 璺緞

椤甸潰瑕佺偣锛?
- Smoke PASS锛歠ilelist銆乣springcore_pkg.v`銆丏UT 渚嬪寲銆佽蒋浠?run flow 鍙敤銆?- Legacy bench 鐗堟湰锛歚2026-06-05-legacy-v3-fast-stress`銆?- Directed 鍒濇湡 quiet NaN 瀹氫綅涓?FP32 NaN-boxing 闂銆?- Stress bench 鎶戝埗 per-writeback 鏃ュ織锛岄伩鍏?I/O 骞叉壈鎬ц兘銆?
璁茬澶囨敞锛?
杩欓〉璇存槑涓轰粈涔堢幇鍦ㄧ殑鏁版嵁鍙俊锛氫笉鏄竴寮€濮嬪氨璺戝ぇ鍘嬪姏锛岃€屾槸鍏堝仛 smoke锛屽啀 directed锛屽啀 stress銆?
鍥捐〃寤鸿锛?
- 闃舵鍥撅細smoke -> directed -> NaN-boxing fix -> stress -> PXP matrix銆?
## 绗?5 椤碉細鎬ц兘缁撴灉鎬昏

椤甸潰瑕佺偣锛?
| label | num_ops | SW real (s) | PXP real (s) | HW exec (s) | End-to-end |
| --- | ---: | ---: | ---: | ---: | ---: |
| 1M | 1,000,000 | 281.85 | 133.67 | 38.17 | 2.109x |
| 5M | 5,000,000 | 922.95 | 282.66 | 187.13 | 3.265x |
| 10M | 10,000,000 | 1727.26 | 472.05 | 376.62 | 3.659x |

璁茬澶囨敞锛?
涓绘寚鏍囨槸 `SW real / PXP real`锛屽嵆鐢ㄦ埛绔埌绔瓑寰呮椂闂寸殑鏀剁泭銆俙SW real / HW exec` 鍙互灞曠ず纭欢鎵ц娼滃姏锛屼絾涓嶅簲浣滀负涓诲浼犳暟瀛椼€?
鍥捐〃寤鸿锛?
- 琛ㄦ牸 + 鍔犻€熸瘮鏉″舰鍥俱€?
## 绗?6 椤碉細鏁板鍒嗘瀽

椤甸潰瑕佺偣锛?
- 绔埌绔ā鍨嬶細`T_pxp = T_fixed + T_hw_exec + T_sync`銆?- 鍔犻€熸瘮锛歚speedup = T_sw / T_pxp`銆?- 褰?workload 鍙樺ぇ鏃讹紝`T_fixed / N` 琚憡钖勩€?- 褰撳墠 `HW exec` 绾?`26K-27K cycles/s` 鍩烘湰绋冲畾锛岃鏄庝富瑕佸彉鍖栨潵鑷浐瀹氬紑閿€鍜屽悓姝ュ崰姣斻€?
璁茬澶囨敞锛?
杩欓〉鐢ㄧ畝鍗曟ā鍨嬭В閲婁负浠€涔?10M 姣?1M 鍔犻€熸瘮鏇村ソ銆備笉鏄‖浠剁獊鐒跺彉蹇簡锛岃€屾槸鍥哄畾鎴愭湰琚洿澶氭搷浣滄憡钖勩€?
鍥捐〃寤鸿锛?
- 涓€涓叕寮忔銆?- 涓€涓€滃浐瀹氬紑閿€鍗犳瘮涓嬮檷鈥濈殑姘村钩鏉＄ず鎰忋€?
## 绗?7 椤碉細鐗╃悊/纭欢闄愬埗

椤甸潰瑕佺偣锛?
- 浼樺娍锛欴UT 鍦?PXP 纭欢渚ф墽琛岋紝閬垮厤绾蒋浠朵簨浠朵豢鐪熺殑浣庨€熴€?- 闄愬埗锛氬綋鍓嶆槸 IXCOM SA 妯″紡锛屼笉鏄畬鏁?testbench-on-hardware emulation銆?- DUT 鍦ㄧ‖浠朵晶锛宼estbench 鍦ㄨ蒋浠朵晶锛屼簨浠堕渶瑕佽法 host/emulator 杈圭晫銆?- Visibility銆乸robe銆丗ullVision銆佹尝褰笂浼犻兘浼氬鍔犲閲忓拰杩愯寮€閿€銆?
璁茬澶囨敞锛?
杩欓噷瑕佹妸鈥滅‖浠跺緢蹇€濆拰鈥滅郴缁熷疄娴嬫病鍒?MHz鈥濆尯鍒嗗紑銆侾XP 鐨勭墿鐞嗘墽琛岃兘鍔涘瓨鍦紝浣嗚繖涓祴璇曞舰鎬佽杈圭晫浜や簰闄愬埗銆?
鍥捐〃寤鸿锛?
- Software TB -> sync boundary -> Hardware DUT 鐨勭粨鏋勫浘銆?
## 绗?8 椤碉細璁＄畻鏈虹瀛﹂檺鍒?
椤甸潰瑕佺偣锛?
- 杞欢浠跨湡鏄簨浠堕┍鍔紝璺ㄨ竟鐣屼簨浠朵細鏀惧ぇ璋冨害寮€閿€銆?- 姣忓懆鏈熷彂涓€涓?operation锛屽睘浜庨珮浜や簰 workload銆?- 1M 鏃ュ織绀轰緥鏄剧ず澶ч噺 `tbsyncs`銆乮nput events銆乷utput events銆?- `$display`銆乣tee`銆乴og I/O 浼氭薄鏌?runtime锛屽洜姝?stress 榛樿浣庢墦鍗般€?
璁茬澶囨敞锛?
杩欓〉浠庤绠楁ā鍨嬭В閲婄摱棰堬細涓嶆槸绠楁湳鍗曞厓鏈韩鎱紝鑰屾槸绯荤粺涓嶆柇鍚屾灏忎簨浠讹紝瀵艰嚧鍚炲悙鍙楅檺銆?
鍥捐〃寤鸿锛?
- 鈥滄瘡鍛ㄦ湡鍚屾鈥濅笌鈥滄壒閲忓悓姝モ€濈殑瀵规瘮绀烘剰銆?
## 绗?9 椤碉細浼樺寲鍙兘鎬х煩闃?
椤甸潰瑕佺偣锛?
| 浼樺寲鏂瑰悜 | 椋庨櫓 | 棰勬湡鏀剁泭 | 璇存槑 |
| --- | --- | --- | --- |
| 鍑忓皯鏃ュ織/鍙鎬?| 浣?| 涓?| 宸插紑濮嬪仛锛岄€傚悎鎬ц兘璺戦粯璁ょ瓥鐣?|
| 鎵归噺 stimulus | 涓?| 楂?| 鍑忓皯姣忓懆鏈?host/PXP 鍚屾 |
| 纭欢渚?driver/checker | 涓珮 | 楂?| 鎶婃洿澶氫氦浜掍笅娌夊埌 emulator 渚?|
| compile once replay many tests | 涓?| 涓珮 | 鎽婅杽缂栬瘧鍜?swap 鍥哄畾鎴愭湰 |
| 鏇村 seeds/longer workload | 浣?| 涓?| 鎻愬崌鏁版嵁鍙俊搴﹀拰瓒嬪娍绋冲畾鎬?|

璁茬澶囨敞锛?
寤鸿鎶婁紭鍖栧垎灞傦細鍏堝仛浣庨闄╁伐绋嬪寲锛屽啀鍋氱粨鏋勬€т紭鍖栥€備笉瑕佷竴寮€濮嬪氨澶ф敼 testbench 鏋舵瀯銆?
鍥捐〃寤鸿锛?
- 椋庨櫓/鏀剁泭鐭╅樀銆?
## 绗?10 椤碉細椋庨櫓涓庡彲淇″害

椤甸潰瑕佺偣锛?
- 涓绘寚鏍囬€夋嫨绔埌绔?`PXP real`锛岄伩鍏嶅彧鐪?`HW exec` 閫犳垚杩囧害涔愯銆?- `26K-27K cycles/s` 鏄綋鍓?SA workload 瀹炴祴锛屼笉鏄?PXP 宄板€笺€?- `PXP real` 鍖呭惈 reserve銆亁eDebug銆乭ost connection銆乻wap銆佺‖浠舵墽琛屽拰娓呯悊銆?- 鏁版嵁鏈寘鍚湡瀹?IP/鐢ㄦ埛鍚?鍐呴儴璺緞锛屾眹鎶ユ潗鏂欎娇鐢ㄥ崰浣嶇銆?
璁茬澶囨敞锛?
杩欓〉涓诲姩璇存槑杈圭晫锛岃兘澧炲己鎶€鏈瘎瀹″彲淇″害銆傝瘎瀹￠€氬父鏇翠俊浠烩€滅煡閬撹嚜宸遍檺鍒跺湪鍝噷鈥濈殑姹囨姤銆?
鍥捐〃寤鸿锛?
- `PXP real` 鎷嗗垎绀烘剰锛歠ixed + sync + hw exec銆?
## 绗?11 椤碉細涓嬩竴姝ヨ鍒?
椤甸潰瑕佺偣锛?
- 鍔熻兘瑕嗙洊锛歝ompare銆乻ign/minmax銆乻pecial values銆乺ounding/conversion銆?- 姝ｇ‘鎬ф鏌ワ細琛ョ簿纭?result銆乫flags銆亀riteback order銆?- 鎬ц兘浼樺寲锛氬噺灏?tbsync锛屽皾璇曟壒閲?stimulus 鎴栫‖浠朵晶 driver/checker銆?- 宸ョ▼鍖栵細鍥哄畾 matrix銆乻ummary.tsv銆佷綆 visibility 鎬ц兘妯″紡銆?
璁茬澶囨敞锛?
涓嬩竴姝ユ棦瑕佽ˉ鍔熻兘瑕嗙洊锛屼篃瑕佷紭鍖栨€ц兘娴嬭瘯缁撴瀯銆備袱鏉＄嚎骞惰鎺ㄨ繘锛岄伩鍏嶅彧杩芥€ц兘鏁板瓧銆?
鍥捐〃寤鸿锛?
- 涓夋潯 roadmap锛歝overage / performance / automation銆?
## 绗?12 椤碉細澶囦唤椤碉細甯歌闂

椤甸潰瑕佺偣锛?
| 闂 | 鐜拌薄 | 澶勭悊 |
| --- | --- | --- |
| `.design` 涓㈠け | xeDebug 璇讳笉鍒拌璁?| 閲嶈窇纭欢 compile/elaborate |
| 鍙?reserve 鏈笅杞?| `RESERVED*` | 鎵ц `xc on -run -xt0` |
| `xc on -run` 澶辫触 | X values | 浣跨敤 `-xt0` |
| `xeDebug -key` 鏃犳晥 | option ignored | 鐢?`xeset reserveKey <key>` |
| 10M timeout | `[ERROR] timeout` | `TIMEOUT_CYCLES = 20000000` |
| top 鍚嶉敊璇?| 鏌ヤ笉鍒?location | 浣跨敤 `xcva_top` |

璁茬澶囨敞锛?
澶囦唤椤电敤浜庣瓟鐤戯紝灏ゅ叾鏄伐鍏峰懡浠ゃ€乺eservation 鍜?10M timeout 鐩稿叧闂銆?
鍥捐〃寤鸿锛?
- 绠€娲侀棶棰樿〃锛屼笉鏀惧ぇ娈垫枃瀛椼€?
