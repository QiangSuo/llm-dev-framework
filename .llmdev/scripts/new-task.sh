#!/usr/bin/env bash
# new-task.sh —— 从模板生成一个新任务的 PLAN/STATE/JOURNAL
# 用法：
#   .llmdev/scripts/new-task.sh <任务名> [目标项目目录]
# 目标项目目录默认为当前目录。会在 docs/{plans,state,journal} 下生成三个文件，
# 并把模板里的 <任务名> 占位符替换成实际名字。
set -euo pipefail

TASK_NAME="${1:?用法：new-task.sh <任务名> [目标项目目录]}"
DEST="${2:-$(pwd)}"
DEST="$(cd "$DEST" && pwd)"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LLMDEV_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
TEMPLATES_DIR="$LLMDEV_DIR/templates"

mkdir -p "$DEST/docs/plans" "$DEST/docs/state" "$DEST/docs/journal"

render() {
  local template="$1" out="$2"
  if [[ -e "$out" ]]; then
    echo "跳过：$out 已存在，不覆盖。" >&2
    return
  fi
  sed "s/<任务名>/${TASK_NAME}/g" "$template" > "$out"
  echo "已生成 $out"
}

render "$TEMPLATES_DIR/PLAN.template.md" "$DEST/docs/plans/PLAN-${TASK_NAME}.md"
render "$TEMPLATES_DIR/STATE.template.md" "$DEST/docs/state/STATE-${TASK_NAME}.md"
render "$TEMPLATES_DIR/JOURNAL.template.md" "$DEST/docs/journal/JOURNAL-${TASK_NAME}.md"
