#!/usr/bin/env bash
# init.sh —— 把本框架应用到一个新项目
# 在新项目根目录运行（或指定目标目录）：
#   /path/to/.llmdev/scripts/init.sh [目标项目目录]
# 做两件事：1) 把 .llmdev 复制过去；2) 建好 docs 目录并跑一次 sync。
set -euo pipefail

SRC_LLMDEV="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEST="${1:-$(pwd)}"
DEST="$(cd "$DEST" && pwd)"

if [[ "$SRC_LLMDEV" == "$DEST/.llmdev" ]]; then
  echo "目标就是框架自身，无需复制，直接 sync。"
else
  echo "复制框架到 $DEST/.llmdev ..."
  cp -R "$SRC_LLMDEV" "$DEST/.llmdev"
fi

mkdir -p "$DEST/docs/plans" "$DEST/docs/state" "$DEST/docs/journal"
echo "已建 docs/{plans,state,journal}。"

echo "运行 sync 生成工具配置 ..."
bash "$DEST/.llmdev/scripts/sync.sh"

echo "完成。下一步：规划时用 .llmdev/templates/PLAN.template.md 起草 plan。"
