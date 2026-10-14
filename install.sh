#!/usr/bin/env bash
# 安裝 Agent 工作台：把程式放到 ~/.local/bin，設定放到 ~/.config/agent-ws，開啟燈號背景服務。
set -euo pipefail
cd "$(dirname "$0")"
missing=()
for c in tmux python3 xclip gnome-terminal fzf; do command -v "$c" >/dev/null || missing+=("$c"); done
if [ ${#missing[@]} -gt 0 ]; then
  echo "缺少：${missing[*]}"
  echo "Ubuntu／Debian：sudo apt install ${missing[*]}"
  exit 1
fi
mkdir -p ~/.local/bin ~/.config/agent-ws ~/.config/systemd/user ~/.local/share/applications ~/.local/state/agent-lights
install -m 755 bin/* ~/.local/bin/
install -m 644 config/tmux.conf ~/.config/agent-ws/tmux.conf
install -D -m 755 shim/claude ~/.config/agent-ws/bin/claude
grep -q 'agent-ws/bin' ~/.bashrc || cat >> ~/.bashrc <<'RC'

# Agent 工作台（tmux -L agents）裡的 claude 改用一般介面（~/.config/agent-ws/bin/claude）
case "$TMUX" in */agents,*) PATH="$HOME/.config/agent-ws/bin:$PATH" ;; esac
RC
install -m 644 systemd/agent-lights.service ~/.config/systemd/user/
install -m 644 desktop/agent-ws.desktop ~/.local/share/applications/
systemctl --user daemon-reload
systemctl --user enable --now agent-lights.service
echo "完成。打 ws 開工作台，或從應用程式選單找「Agent 工作台」。"
echo "燈號要接 Claude Code：把 hooks/claude-settings-hooks.json 的 hooks 合併進 ~/.claude/settings.json"
