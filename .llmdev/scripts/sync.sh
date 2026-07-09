#!/usr/bin/env bash
# sync.sh —— 单一真源 → 各工具配置
# 从 .llmdev/core/ + .llmdev/adapters/<tool>(.md|/adapter.md) 组装出 CLAUDE.md / AGENTS.md。
# 对支持 skill/subagent 的工具（当前：claude-code），还会把
# .llmdev/adapters/<tool>/skills|agents 分发到项目根的 .claude/skills|agents
# （只清理/覆盖 llmdev- 前缀的产物，不动用户自己的 skill/agent）。
# 你只改 core/ 和 adapters/，跑本脚本，各工具配置同步更新。可重复运行（幂等）。
set -euo pipefail

LLMDEV_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ROOT_DIR="$(cd "$LLMDEV_DIR/.." && pwd)"
CORE_DIR="$LLMDEV_DIR/core"
ADAPTERS_DIR="$LLMDEV_DIR/adapters"

# 生成目标：<输出文件>:<adapter 名>
TARGETS=(
  "CLAUDE.md:claude-code"
  "AGENTS.md:codex"
  "CODEBUDDY.md:codebuddy"
)

# adapter 可以是 adapters/<tool>.md（单文件）或 adapters/<tool>/adapter.md（目录形态）。
resolve_adapter() {
  local tool="$1"
  if [[ -f "$ADAPTERS_DIR/$tool/adapter.md" ]]; then
    echo "$ADAPTERS_DIR/$tool/adapter.md"
  elif [[ -f "$ADAPTERS_DIR/$tool.md" ]]; then
    echo "$ADAPTERS_DIR/$tool.md"
  fi
}

emit_header() {
  local tool="$1" adapter_rel="$2"
  printf '<!-- 本文件由 .llmdev/scripts/sync.sh 自动生成，请勿手改。 -->\n'
  printf '<!-- 要改规则：编辑 .llmdev/core/ 或 %s，然后重跑 sync.sh。 -->\n\n' "$adapter_rel"
}

# 生成内容写到 stdout，供 build_one（写现网文件）和 check 模式（写临时文件后 diff）共用，
# 避免生成逻辑在两条路径上各写一份、彼此漂移。
render_one() {
  local out="$1" tool="$2"
  local adapter
  adapter="$(resolve_adapter "$tool")"
  if [[ -z "$adapter" ]]; then
    echo "跳过 ${out}：找不到 ${tool} 的 adapter" >&2
    return 1
  fi
  local adapter_rel="${adapter#"$LLMDEV_DIR"/}"
  emit_header "$tool" ".llmdev/$adapter_rel"
  cat "$adapter"
  printf '\n\n---\n\n# 共享核心方法论\n\n'
  # 按文件名排序拼接所有 core 文件
  for f in "$CORE_DIR"/*.md; do
    cat "$f"
    printf '\n\n'
  done
}

build_one() {
  local out="$1" tool="$2"
  local adapter
  adapter="$(resolve_adapter "$tool")"
  if [[ -z "$adapter" ]]; then
    echo "跳过 ${out}：找不到 ${tool} 的 adapter" >&2
    return
  fi
  local adapter_rel="${adapter#"$LLMDEV_DIR"/}"
  render_one "$out" "$tool" > "$ROOT_DIR/$out"
  echo "已生成 ${out}（adapter: ${adapter_rel}）"
}

check_one() {
  local out="$1" tool="$2"
  local adapter
  adapter="$(resolve_adapter "$tool")"
  if [[ -z "$adapter" ]]; then
    echo "跳过 ${out}：找不到 ${tool} 的 adapter" >&2
    return 0
  fi
  local tmp
  tmp="$(mktemp)"
  render_one "$out" "$tool" > "$tmp"
  if [[ ! -f "$ROOT_DIR/$out" ]] || ! diff -q "$tmp" "$ROOT_DIR/$out" >/dev/null 2>&1; then
    echo "漂移：${out} 与源文件（core/adapter）不一致，请重跑 sync.sh" >&2
    rm -f "$tmp"
    return 1
  fi
  rm -f "$tmp"
  return 0
}

# 分发 <tool>/skills、<tool>/agents 到 $ROOT_DIR/.claude/{skills,agents}。
# 只清理/覆盖 llmdev- 前缀的产物，保留用户自己的 skill/agent。
distribute_claude_extras() {
  local tool_dir="$ADAPTERS_DIR/claude-code"
  local skills_src="$tool_dir/skills" agents_src="$tool_dir/agents"
  local skills_dest="$ROOT_DIR/.claude/skills" agents_dest="$ROOT_DIR/.claude/agents"

  if [[ -d "$skills_src" ]]; then
    mkdir -p "$skills_dest"
    find "$skills_dest" -maxdepth 1 -mindepth 1 -name 'llmdev-*' -exec rm -rf {} +
    for d in "$skills_src"/*/; do
      [[ -d "$d" ]] || continue
      local name
      name="$(basename "$d")"
      cp -R "$d" "$skills_dest/$name"
      echo "已分发 skill：.claude/skills/${name}"
    done
  fi

  if [[ -d "$agents_src" ]]; then
    mkdir -p "$agents_dest"
    find "$agents_dest" -maxdepth 1 -name 'llmdev-*.md' -delete
    for f in "$agents_src"/*.md; do
      [[ -f "$f" ]] || continue
      cp "$f" "$agents_dest/"
      echo "已分发 subagent：.claude/agents/$(basename "$f")"
    done
  fi
}

MODE="${1:-build}"

case "$MODE" in
  check)
    drifted=0
    for entry in "${TARGETS[@]}"; do
      check_one "${entry%%:*}" "${entry##*:}" || drifted=1
    done
    if [[ "$drifted" -eq 0 ]]; then
      echo "CLAUDE.md/AGENTS.md/CODEBUDDY.md 与源文件一致。"
      exit 0
    else
      exit 1
    fi
    ;;
  build)
    for entry in "${TARGETS[@]}"; do
      build_one "${entry%%:*}" "${entry##*:}"
    done
    distribute_claude_extras
    echo "sync 完成。"
    ;;
  *)
    echo "未知模式：$MODE（支持：build（默认）、check）" >&2
    exit 1
    ;;
esac
