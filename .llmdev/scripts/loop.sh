#!/usr/bin/env bash
# loop.sh —— Codex 编排循环
# 反复调用 codex，每轮都是新鲜上下文，用 STATE 账本接力，
# 模拟 Codex 缺失的"自动按阶段换窗口"。
#
# 用法：
#   .llmdev/scripts/loop.sh <PLAN文件> <STATE文件> [最大轮数]
# 例：
#   .llmdev/scripts/loop.sh docs/plans/PLAN-foo.md docs/state/STATE-foo.md 20
set -euo pipefail

PLAN="${1:?需要 PLAN 文件路径}"
STATE="${2:?需要 STATE 文件路径}"
MAX_ITERS="${3:-15}"

if ! command -v codex >/dev/null 2>&1; then
  echo "未找到 codex CLI。请先安装/配置 codex。" >&2
  exit 1
fi

read -r -d '' PROMPT <<EOF || true
你在一个长程任务的自动编排循环中。本轮请：
1. 重新定位：读 $PLAN 与 $STATE，并核对磁盘真实状态（git status、跑测试）。
2. 从 PLAN 中挑出"下一步未完成"的那一小步来做。
3. 做完后跑该步的验证；通过则 commit。
4. 更新 $STATE：勾掉已完成、写清下一步、记录坑与决策。
5. 若触发自主边界、或同一问题失败 2 次（卡住协议），停止并在 $STATE 的
   "阻塞/需要人介入"里写清原因，然后本轮结束。
遵守下方 AGENTS.md 的全部规则。只做 PLAN 里的事。
EOF

for ((i=1; i<=MAX_ITERS; i++)); do
  echo "=========== 循环 $i / $MAX_ITERS ==========="
  # exec 模式：非交互执行一轮。不同 codex 版本参数可能不同，按需调整。
  codex exec "$PROMPT" || { echo "codex 本轮返回非零，停止。" >&2; break; }

  # 提取"## 阻塞 / 需要人介入"标题后、下一个 "##" 标题或文件尾之间的内容，
  # 去除首尾空白后必须恰好是"无"才算不阻塞；其余任何写法（包括自然语言的
  # "没有阻塞"）都视为阻塞——结构化匹配，不做语义猜测。
  blocked_section="$(awk '
    /^## 阻塞/ { flag=1; next }
    /^## / && flag { flag=0 }
    flag { print }
  ' "$STATE" 2>/dev/null | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | grep -v '^$' || true)"

  if [[ -n "$blocked_section" && "$blocked_section" != "无" ]]; then
    echo ">> STATE 标记了需要人介入，停止循环。请查看 $STATE。"
    break
  fi
done
echo "编排循环结束。"
