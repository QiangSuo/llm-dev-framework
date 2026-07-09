#!/usr/bin/env bash
# sync.sh —— 单一真源 → 各工具配置
# 从 .llmdev/core/ + .llmdev/adapters/<tool>.md 组装出 CLAUDE.md / AGENTS.md。
# 你只改 core/ 和 adapters/，跑本脚本，各工具配置同步更新。
set -euo pipefail

LLMDEV_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ROOT_DIR="$(cd "$LLMDEV_DIR/.." && pwd)"
CORE_DIR="$LLMDEV_DIR/core"
ADAPTERS_DIR="$LLMDEV_DIR/adapters"

# 生成目标：<输出文件>:<adapter 名>
TARGETS=(
  "CLAUDE.md:claude-code"
  "AGENTS.md:codex"
)

emit_header() {
  local tool="$1"
  printf '<!-- 本文件由 .llmdev/scripts/sync.sh 自动生成，请勿手改。 -->\n'
  printf '<!-- 要改规则：编辑 .llmdev/core/ 或 .llmdev/adapters/%s.md，然后重跑 sync.sh。 -->\n\n' "$tool"
}

build_one() {
  local out="$1" tool="$2"
  local adapter="$ADAPTERS_DIR/$tool.md"
  if [[ ! -f "$adapter" ]]; then
    echo "跳过 $out：找不到 adapter $adapter" >&2
    return
  fi
  {
    emit_header "$tool"
    cat "$adapter"
    printf '\n\n---\n\n# 共享核心方法论\n\n'
    # 按文件名排序拼接所有 core 文件
    for f in "$CORE_DIR"/*.md; do
      cat "$f"
      printf '\n\n'
    done
  } > "$ROOT_DIR/$out"
  echo "已生成 ${out}（adapter: ${tool}）"
}

for entry in "${TARGETS[@]}"; do
  build_one "${entry%%:*}" "${entry##*:}"
done
echo "sync 完成。"
