# Agent 工作台（agent-workbench）

在 Linux（GNOME）上同時跑好幾個 AI coding agent（Claude Code、Codex、Grok…）的終端機工作台。
不是另外寫的 App，是用 **tmux＋幾支小腳本**拼起來的，任何在終端機裡跑的 agent 都能放進來。

靈感來自 macOS 的 [cmux](https://github.com/manaflow-ai/cmux)，這是給 Linux 用的輕量版。

```
┌────────┬──────────────────┬──────────────────┐
│工作列表 │ 1 🔴 等你         │ 2 Skool導流       │
│1 🔴等你 │                  │                  │
│ 終端面板│                  │                  │
│2 ·閒置  ├──────────────────┼──────────────────┤
│ Skool… │ 3 🟢 做完         │ 4 貓救主人         │
└────────┴──────────────────┴──────────────────┘
```

## 功能

- **等大格子**：依螢幕比例自動排成 2×2、3×2、4×2，空位補「空格」，關掉一格不會讓排版跳掉
- **左側欄**：每個工作一張卡片，有燈號、名稱、agent 和帳號、實際資料夾、git 分支、網路埠、最後一句話；點卡片就跳過去
- **燈號**：🔴＝在等你允許或回答，🟢＝做完還沒回；格子外框也會跟著變色。要等你送出下一句才會熄（看過不等於處理完），沒回會在 3／6／10 分鐘再提醒
- **接回對話**：側邊欄每 5 秒記一次每格開著哪個對話。終端機被整個關掉後，打 `ws restore` 就全部接回
- **Ctrl+C／Ctrl+V 不用加 Shift**：滾輪可以往上捲（不顯示行數時間，名牌出現「⤓ 跳到最底下」可點，捲回底部自動離開）；拖曳反白放開就複製，之後 5 秒內按 Ctrl+C 只提示已複製、不會中斷 agent；其他時候 Ctrl+C 照舊是中斷；Ctrl+V 遇到文字直接貼上，遇到圖片照舊交給 Claude 貼圖
- **防誤觸**：工作台裡停用 Ctrl+Z（會把 agent 整個暫停）；側邊欄不會被 Ctrl+C 弄掉，當掉會自己重開

## 安裝

需要：GNOME Terminal、tmux 3.3 以上、python3、xclip、fzf

```bash
git clone https://github.com/Ai110002/agent-workbench.git
cd agent-workbench
./install.sh
```

燈號要接上 Claude Code：把 `hooks/claude-settings-hooks.json` 裡的 `hooks` 合併進 `~/.claude/settings.json`。

工作台裡的 Claude 一律用一般介面（`shim/claude` 自動加 `--settings '{"tui":"default"}'`，一般終端機分頁不受影響）：往上捲時輸入框和狀態列會一起被捲下去，四格並排時才有空間看內容；點名牌上的「⤓ 跳到最底下」或捲回底部就回來。有自訂狀態列的話，可以在 `statusLine` 加 `"refreshInterval": 30`，閒置的格子也會定時更新。

## 使用

開工作台：打 `ws`，或從應用程式選單找「Agent 工作台」。

| 按鍵 | 做什麼 |
|---|---|
| 點一下格子／側邊欄卡片 | 切到那格 |
| Alt+數字 | 跳到第 N 個工作 |
| F2 | 幫這格取名 |
| F3 | 總覽所有工作，可以預覽畫面 |
| F4 | 切換「全部一起看」和「一次一格塞滿」 |
| F5 | 新增一格（先用空格） |
| F6 | 跳到下一個亮燈的格子（🔴 優先） |
| F7 | 收起／打開側邊欄 |
| F8 | 清空這格（格子留著變空格） |

| 指令 | 做什麼 |
|---|---|
| `ws` | 開啟或接回工作台 |
| `ws new 名稱` | 新增一格 |
| `ws restore` | 把上次開著的對話全部接回 |
| `ws grid` | 重新排成等大格子 |
| `ws side on/off` | 開關側邊欄 |
| `ws ls` | 列出所有工作 |

## 檔案

| 檔案 | 用途 |
|---|---|
| `bin/ws` | 工作台主程式 |
| `bin/ws-grid` | 排等大格子 |
| `bin/ws-sidebar` | 側邊欄（Python curses） |
| `bin/ws-clip` | Ctrl+C／Ctrl+V |
| `bin/agent-light` | 燈號、通知、跳分頁（也支援一般 GNOME Terminal 分頁） |
| `bin/agent-done-notify` | agent 做完時的 hook |
| `shim/claude` | 工作台裡的 claude 包裝（改用一般介面） |
| `config/tmux.conf` | 工作台專用的 tmux 設定（獨立的 `tmux -L agents`，不影響你原本的 tmux） |

## 已知限制

- 只在 GNOME（Wayland）＋GNOME Terminal 上測過
- 單格模式（F4）時側邊欄會被藏起來
- 每格都在同一個資料夾時，用 `claude -c` 接回對話可能接到別格正在跑的對話；建議用 `--resume <id>` 或 `ws restore`

## 授權

MIT
