param(
  [string]$OutputPath = "PXP_hardware_acceleration_report.pptx"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$scriptDir = $PSScriptRoot
if ([string]::IsNullOrWhiteSpace($scriptDir)) {
  $scriptDir = (Get-Location).Path
}
$outFile = Join-Path $scriptDir $OutputPath

function Rgb([int]$r, [int]$g, [int]$b) {
  return ($r + ($g * 256) + ($b * 65536))
}

$colors = @{
  Navy = Rgb 20 44 72
  Blue = Rgb 42 111 176
  Cyan = Rgb 42 157 188
  Green = Rgb 62 150 104
  Orange = Rgb 220 132 51
  Red = Rgb 188 77 77
  Ink = Rgb 31 41 55
  Muted = Rgb 99 111 130
  Line = Rgb 216 222 232
  Pale = Rgb 245 247 250
  White = Rgb 255 255 255
  Dark = Rgb 15 23 42
}

function Set-TextStyle($shape, [double]$size, [int]$color, [bool]$bold = $false) {
  $range = $shape.TextFrame.TextRange
  $range.Font.Name = "Microsoft YaHei"
  $range.Font.Size = $size
  $range.Font.Color.RGB = $color
  if ($bold) { $range.Font.Bold = -1 } else { $range.Font.Bold = 0 }
}

function Add-TextBox($slide, [string]$text, [double]$x, [double]$y, [double]$w, [double]$h, [double]$size = 18, [int]$color = $colors.Ink, [bool]$bold = $false) {
  $shape = $slide.Shapes.AddTextbox(1, $x, $y, $w, $h)
  $shape.TextFrame.MarginLeft = 8
  $shape.TextFrame.MarginRight = 8
  $shape.TextFrame.MarginTop = 5
  $shape.TextFrame.MarginBottom = 5
  $shape.TextFrame.WordWrap = -1
  $shape.TextFrame.TextRange.Text = $text
  Set-TextStyle $shape $size $color $bold
  return $shape
}

function Add-Title($slide, [string]$title, [string]$kicker = "") {
  if ($kicker -ne "") {
    Add-TextBox $slide $kicker 52 28 860 24 11 $colors.Cyan $true | Out-Null
  }
  Add-TextBox $slide $title 50 50 860 52 26 $colors.Navy $true | Out-Null
  $line = $slide.Shapes.AddShape(1, 52, 108, 64, 3)
  $line.Fill.ForeColor.RGB = $colors.Orange
  $line.Line.Visible = 0
}

function Add-Footer($slide, [int]$num) {
  Add-TextBox $slide "PXP technical review | $num" 734 512 180 20 8 $colors.Muted $false | Out-Null
}

function Add-Bullets($slide, [string[]]$items, [double]$x, [double]$y, [double]$w, [double]$h, [double]$size = 16) {
  $text = [string]::Join("`r", $items)
  $shape = Add-TextBox $slide $text $x $y $w $h $size $colors.Ink $false
  $range = $shape.TextFrame.TextRange
  $range.ParagraphFormat.Bullet.Visible = -1
  $range.ParagraphFormat.Bullet.Type = 1
  $range.ParagraphFormat.SpaceAfter = 6
  return $shape
}

function Add-Card($slide, [string]$title, [string]$body, [double]$x, [double]$y, [double]$w, [double]$h, [int]$accent = $colors.Blue) {
  $box = $slide.Shapes.AddShape(1, $x, $y, $w, $h)
  $box.Fill.ForeColor.RGB = $colors.White
  $box.Line.ForeColor.RGB = $colors.Line
  $bar = $slide.Shapes.AddShape(1, $x, $y, 5, $h)
  $bar.Fill.ForeColor.RGB = $accent
  $bar.Line.Visible = 0
  Add-TextBox $slide $title ($x + 14) ($y + 10) ($w - 24) 26 14 $accent $true | Out-Null
  Add-TextBox $slide $body ($x + 14) ($y + 39) ($w - 24) ($h - 44) 12 $colors.Ink $false | Out-Null
}

function Add-Flow($slide, [string[]]$steps, [double]$x, [double]$y, [double]$w, [double]$h) {
  $gap = 18
  $boxW = ($w - (($steps.Count - 1) * $gap)) / $steps.Count
  for ($i = 0; $i -lt $steps.Count; $i++) {
    $left = $x + ($i * ($boxW + $gap))
    $shape = $slide.Shapes.AddShape(1, $left, $y, $boxW, $h)
    $shape.Fill.ForeColor.RGB = $colors.Pale
    $shape.Line.ForeColor.RGB = $colors.Line
    Add-TextBox $slide $steps[$i] ($left + 6) ($y + 8) ($boxW - 12) ($h - 16) 12 $colors.Navy $true | Out-Null
    if ($i -lt $steps.Count - 1) {
      $arr = $slide.Shapes.AddShape(33, ($left + $boxW + 2), ($y + ($h / 2) - 6), ($gap - 4), 12)
      $arr.Fill.ForeColor.RGB = $colors.Orange
      $arr.Line.Visible = 0
    }
  }
}

function Add-Table($slide, [string[][]]$rows, [double]$x, [double]$y, [double]$w, [double]$h, [double]$fontSize = 11) {
  $rowCount = $rows.Count
  $colCount = $rows[0].Count
  $tblShape = $slide.Shapes.AddTable($rowCount, $colCount, $x, $y, $w, $h)
  $tbl = $tblShape.Table
  for ($r = 1; $r -le $rowCount; $r++) {
    for ($c = 1; $c -le $colCount; $c++) {
      $cell = $tbl.Cell($r, $c)
      $cell.Shape.TextFrame.TextRange.Text = $rows[$r - 1][$c - 1]
      $cell.Shape.TextFrame.MarginLeft = 4
      $cell.Shape.TextFrame.MarginRight = 4
      $cell.Shape.TextFrame.MarginTop = 3
      $cell.Shape.TextFrame.MarginBottom = 3
      $cell.Shape.TextFrame.TextRange.Font.Name = "Microsoft YaHei"
      $cell.Shape.TextFrame.TextRange.Font.Size = $fontSize
      $cell.Shape.TextFrame.TextRange.Font.Color.RGB = $colors.Ink
      $cell.Borders.Item(1).ForeColor.RGB = $colors.Line
      $cell.Borders.Item(2).ForeColor.RGB = $colors.Line
      $cell.Borders.Item(3).ForeColor.RGB = $colors.Line
      $cell.Borders.Item(4).ForeColor.RGB = $colors.Line
      if ($r -eq 1) {
        $cell.Shape.Fill.ForeColor.RGB = $colors.Navy
        $cell.Shape.TextFrame.TextRange.Font.Color.RGB = $colors.White
        $cell.Shape.TextFrame.TextRange.Font.Bold = -1
      } elseif (($r % 2) -eq 0) {
        $cell.Shape.Fill.ForeColor.RGB = $colors.Pale
      } else {
        $cell.Shape.Fill.ForeColor.RGB = $colors.White
      }
    }
  }
  return $tblShape
}

function Add-BarChart($slide, [object[]]$data, [double]$x, [double]$y, [double]$w, [double]$h, [string]$labelField, [string]$valueField, [double]$maxValue, [string]$suffix = "x") {
  $rowH = $h / $data.Count
  for ($i = 0; $i -lt $data.Count; $i++) {
    $item = $data[$i]
    $label = [string]$item[$labelField]
    $value = [double]$item[$valueField]
    Add-TextBox $slide $label $x ($y + $i * $rowH + 3) 58 24 12 $colors.Navy $true | Out-Null
    $track = $slide.Shapes.AddShape(1, ($x + 64), ($y + $i * $rowH + 7), ($w - 150), 20)
    $track.Fill.ForeColor.RGB = $colors.Pale
    $track.Line.Visible = 0
    $barW = [Math]::Max(4, ($w - 150) * $value / $maxValue)
    $bar = $slide.Shapes.AddShape(1, ($x + 64), ($y + $i * $rowH + 7), $barW, 20)
    $bar.Fill.ForeColor.RGB = $colors.Blue
    if ($i -eq 1) { $bar.Fill.ForeColor.RGB = $colors.Cyan }
    if ($i -eq 2) { $bar.Fill.ForeColor.RGB = $colors.Green }
    $bar.Line.Visible = 0
    Add-TextBox $slide ("{0:N2}{1}" -f $value, $suffix) ($x + $w - 78) ($y + $i * $rowH + 2) 70 26 12 $colors.Ink $true | Out-Null
  }
}

function Add-Slide($ppt, [string]$title, [string]$kicker = "") {
  $slide = $ppt.Slides.Add($ppt.Slides.Count + 1, 12)
  $slide.Background.Fill.ForeColor.RGB = $colors.White
  Add-Title $slide $title $kicker
  Add-Footer $slide $slide.SlideIndex
  return $slide
}

$performance = @(
  @{Label="1M"; Ops="1,000,000"; Sw="281.85"; Pxp="133.67"; Hw="38.17"; Speed=2.109; Status="PASS"},
  @{Label="5M"; Ops="5,000,000"; Sw="922.95"; Pxp="282.66"; Hw="187.13"; Speed=3.265; Status="PASS"},
  @{Label="10M"; Ops="10,000,000"; Sw="1727.26"; Pxp="472.05"; Hw="376.62"; Speed=3.659; Status="PASS"}
)

$ppType = [type]::GetTypeFromProgID("PowerPoint.Application")
if ($null -eq $ppType) {
  throw "PowerPoint COM is not available on this machine."
}

$app = [Activator]::CreateInstance($ppType)
$app.Visible = -1
$ppt = $app.Presentations.Add()
$ppt.PageSetup.SlideWidth = 960
$ppt.PageSetup.SlideHeight = 540

try {
  $s = Add-Slide $ppt "`"sc_idu_to_fxu`" PalladiumXP SA 硬件加速验证" "技术评审"
  Add-TextBox $s "结论：PXP SA 链路已真实跑通，1M/5M/10M stress 均 PASS；端到端收益随 workload 增大而提升。" 54 130 840 44 18 $colors.Navy $true | Out-Null
  Add-Card $s "1M stress" "End-to-end speedup`n2.11x`nPASS" 70 212 235 118 $colors.Blue
  Add-Card $s "5M stress" "End-to-end speedup`n3.27x`nPASS" 362 212 235 118 $colors.Cyan
  Add-Card $s "10M stress" "End-to-end speedup`n3.66x`nPASS" 654 212 235 118 $colors.Green
  Add-Bullets $s @("关键证据不是 `irun -hw`，而是 `xc on -run -xt0` 后的 swap-in 与 HW exec 日志。", "当前瓶颈来自 IXCOM SA 边界同步、事件传输和 visibility 开销。") 70 368 820 82 15 | Out-Null

  $s = Add-Slide $ppt "验证目标与环境" "DUT / tool / access path"
  Add-Flow $s @("Windows PC", "VNC`n<jump-host>", "SSH`n<pxp-host>", "PXP case`nsc_idu_to_fxu") 64 140 832 76
  Add-Card $s "DUT" "`"sc_idu_to_fxu`" 浮点执行单元" 70 252 190 92 $colors.Blue
  Add-Card $s "Software baseline" "Cadence irun(64): 13.10-s010" 282 252 190 92 $colors.Cyan
  Add-Card $s "Testbench" "Conservative Verilog legacy bench" 494 252 190 92 $colors.Green
  Add-Card $s "PXP mode" "IXCOM SA + xeDebug hot swap" 706 252 190 92 $colors.Orange
  Add-Bullets $s @("VS Code Remote SSH 受 PXP glibc/libstdc++ 限制，实际采用 terminal workflow。", "旧工具约束决定 testbench 要避免现代 SystemVerilog 写法。") 80 384 780 72 14 | Out-Null

  $s = Add-Slide $ppt "PXP SA 真实执行证据链" "不是编译通过，而是真硬件运行"
  Add-Flow $s @("Reserve domain`ntest_server", "Set key`nxeset reserveKey", "Hot swap`nxc on -run -xt0", "Observe`nHW exec stats") 58 142 844 86
  Add-Bullets $s @("plain `irun -R` 或 `run_hw_legacy.sh` 不能单独证明 DUT 已跑在 PalladiumXP。", "成功证据：Starting/Finished swap into the emulator。", "运行证据：`--- HW execs ... evals ... in ... sec`。", "`test_server` 需要看到 design 绑定；只有 `RESERVED*` 还不够。") 80 268 800 132 15 | Out-Null
  Add-TextBox $s "关键命令：xc on -run -xt0" 164 430 632 42 24 $colors.White $true | Out-Null
  $cmdBox = $s.Shapes.Item($s.Shapes.Count)
  $cmdBox.Fill.ForeColor.RGB = $colors.Navy
  $cmdBox.Line.Visible = 0

  $s = Add-Slide $ppt "功能 bring-up 路径" "从可编译到可测量"
  Add-Flow $s @("Smoke PASS", "Legacy bench", "NaN-boxing fix", "Directed result", "Stress matrix") 52 150 856 82
  Add-Card $s "Smoke" "filelist / springcore_pkg.v / DUT ports / run flow" 72 272 245 94 $colors.Blue
  Add-Card $s "Directed" "FP32 operands require NaN-boxing:`nupper32 = 0xffffffff" 358 272 245 94 $colors.Cyan
  Add-Card $s "Stress" "Suppress per-writeback logs to avoid I/O dominated timing" 644 272 245 94 $colors.Green
  Add-Bullets $s @("主力 bench：`tb_sc_idu_to_fxu_legacy.v`。", "版本标记：`2026-06-05-legacy-v3-fast-stress`。", "10M timeout 已通过 `TIMEOUT_CYCLES = 20000000` 处理。") 94 404 760 80 14 | Out-Null

  $s = Add-Slide $ppt "性能结果总览" "1M / 5M / 10M deterministic stress"
  $rows = @(
    @("label", "num_ops", "SW real (s)", "PXP real (s)", "HW exec (s)", "E2E", "status"),
    @("1M", "1,000,000", "281.85", "133.67", "38.17", "2.109x", "PASS"),
    @("5M", "5,000,000", "922.95", "282.66", "187.13", "3.265x", "PASS"),
    @("10M", "10,000,000", "1727.26", "472.05", "376.62", "3.659x", "PASS")
  )
  Add-Table $s $rows 50 136 860 132 10 | Out-Null
  Add-TextBox $s "端到端加速比：SW real / PXP real" 64 292 360 28 15 $colors.Navy $true | Out-Null
  Add-BarChart $s $performance 72 334 760 112 "Label" "Speed" 4.0 "x"
  Add-TextBox $s "主指标使用端到端 runtime；HW exec 只展示硬件执行潜力。" 94 472 780 28 13 $colors.Muted $false | Out-Null

  $s = Add-Slide $ppt "数学分析：固定开销摊薄模型" "why larger workloads look better"
  Add-TextBox $s "T_pxp = T_fixed + T_hw_exec + T_sync" 112 144 740 48 26 $colors.White $true | Out-Null
  $formula = $s.Shapes.Item($s.Shapes.Count)
  $formula.Fill.ForeColor.RGB = $colors.Navy
  $formula.Line.Visible = 0
  Add-TextBox $s "speedup = T_sw / T_pxp" 238 212 480 36 21 $colors.Navy $true | Out-Null
  Add-Bullets $s @("workload 变大时，T_fixed / N 下降，reserve、xeDebug、swap 等固定成本被摊薄。", "HW exec 稳定约 26K-27K cycles/s，说明硬件执行段相对稳定。", "1M -> 10M 的加速比提升，主要来自固定开销占比下降和同步占比变化。") 90 296 780 112 15 | Out-Null
  Add-BarChart $s $performance 160 430 620 70 "Label" "Speed" 4.0 "x"

  $s = Add-Slide $ppt "物理/硬件限制与优化" "hardware capability vs system measurement"
  Add-Flow $s @("Software TB", "SA sync boundary", "PXP hardware DUT", "Event / visibility feedback") 54 146 852 84
  Add-Card $s "优势" "DUT 在 PXP 硬件侧执行，可脱离纯软件事件仿真的低速。" 72 270 250 114 $colors.Green
  Add-Card $s "限制" "当前是 IXCOM SA；testbench 仍在软件侧，事件需跨 host/emulator 边界。" 354 270 250 114 $colors.Orange
  Add-Card $s "优化" "性能跑保持最小 visibility；减少 waveform/probe；把激励和检查靠近硬件侧。" 636 270 250 114 $colors.Blue
  Add-TextBox $s "结论：PXP 的硬件能力存在，但当前 workload 的实测速率被边界交互限制。" 94 426 760 36 16 $colors.Navy $true | Out-Null

  $s = Add-Slide $ppt "计算机科学限制" "event-driven simulation meets hardware boundary"
  Add-Card $s "事件驱动" "软件仿真按事件调度；跨边界事件会放大调度和通信开销。" 72 142 250 112 $colors.Blue
  Add-Card $s "高交互 workload" "每周期驱动一个 operation，会产生频繁 tbsync。" 354 142 250 112 $colors.Orange
  Add-Card $s "I/O 污染" "`$display`、`tee`、log file I/O 会影响 runtime，因此 stress 默认低打印。" 636 142 250 112 $colors.Green
  Add-TextBox $s "1M log evidence" 92 306 220 24 15 $colors.Cyan $true | Out-Null
  Add-TextBox $s "--- HW execs 2002000 evals ... 2002000 tbsyncs ...`n--- HW execs 52646856 input events`n--- HW execs 3568441 output events" 92 336 760 76 16 $colors.White $true | Out-Null
  $logBox = $s.Shapes.Item($s.Shapes.Count)
  $logBox.Fill.ForeColor.RGB = $colors.Dark
  $logBox.Line.Visible = 0
  Add-TextBox $s "优化方向：批处理、减少同步点、复用 snapshot/hardware database、固定低打印 stress path。" 92 450 770 34 15 $colors.Navy $true | Out-Null

  $s = Add-Slide $ppt "优化可能性矩阵" "risk / benefit view"
  $rows = @(
    @("优化方向", "风险", "收益", "说明"),
    @("减少日志/可见性", "低", "中", "性能跑默认策略"),
    @("批量 stimulus", "中", "高", "减少每周期 host/PXP 同步"),
    @("硬件侧 driver/checker", "中高", "高", "把交互下沉到 emulator 侧"),
    @("compile once replay", "中", "中高", "摊薄编译与 swap 固定成本"),
    @("更多 seeds/longer workload", "低", "中", "提升可信度和趋势稳定性")
  )
  Add-Table $s $rows 62 138 836 244 10 | Out-Null
  Add-TextBox $s "推荐顺序：先低风险工程化，再做结构性同步优化。" 102 424 740 38 18 $colors.Navy $true | Out-Null

  $s = Add-Slide $ppt "风险与可信度" "what the numbers mean"
  Add-Card $s "主指标" "使用 PXP real：包含 reserve、xeDebug、host connection、swap、HW exec、cleanup。" 70 148 392 120 $colors.Blue
  Add-Card $s "避免过度乐观" "HW exec 展示硬件潜力，但不是完整用户等待时间。" 500 148 392 120 $colors.Orange
  Add-Card $s "实测边界" "26K-27K cycles/s 是当前 SA workload 实测，不是 PXP 峰值。" 70 304 392 120 $colors.Green
  Add-Card $s "脱敏" "汇报材料使用 <pxp-host>、<jump-host>、<pxp-user> 等占位符。" 500 304 392 120 $colors.Cyan

  $s = Add-Slide $ppt "下一步计划" "coverage / performance / automation"
  Add-Card $s "功能覆盖" "compare、sign/minmax、special values、rounding/conversion。" 72 148 250 126 $colors.Blue
  Add-Card $s "正确性检查" "补精确 result、fflags、writeback order。" 354 148 250 126 $colors.Cyan
  Add-Card $s "性能优化" "减少 tbsync；尝试批量 stimulus 或硬件侧 driver/checker。" 636 148 250 126 $colors.Green
  Add-Card $s "工程化复用" "固定 matrix、summary.tsv、低 visibility 性能模式。" 214 326 250 112 $colors.Orange
  Add-Card $s "数据扩展" "更多 seeds 和更长 workload，增强趋势可信度。" 496 326 250 112 $colors.Red

  $s = Add-Slide $ppt "备份页：常见问题" "debug checklist"
  $rows = @(
    @("问题", "现象", "处理"),
    @(".design 丢失", "xeDebug 读不到设计", "重跑硬件 compile/elaborate"),
    @("只 reserve 未下载", "RESERVED*", "执行 xc on -run -xt0"),
    @("xc on -run 失败", "X values", "使用 -xt0"),
    @("xeDebug -key 无效", "option ignored", "用 xeset reserveKey <key>"),
    @("10M timeout", "[ERROR] timeout", "TIMEOUT_CYCLES = 20000000"),
    @("top 名错误", "查不到 location", "使用 xcva_top")
  )
  Add-Table $s $rows 64 136 832 288 10 | Out-Null
  Add-TextBox $s "这页用于评审答疑，尤其是 reservation、hot swap、timeout 和 top name 问题。" 94 462 760 32 14 $colors.Muted $false | Out-Null

  if (Test-Path $outFile) {
    Remove-Item -LiteralPath $outFile -Force
  }
  $ppt.SaveAs($outFile, 24)
}
finally {
  if ($null -ne $ppt) {
    $ppt.Close()
  }
  if ($null -ne $app) {
    $app.Quit()
  }
}

Write-Host "Generated: $outFile"

