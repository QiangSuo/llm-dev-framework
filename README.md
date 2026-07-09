# 大模型通用开发框架

一个把"用大模型跑开发任务"反复遇到的问题沉淀成可复用方法论、模板与脚本的框架，
目标是覆盖 Codex / Claude Code / CodeBuddy 等工具。核心解决一个问题：

> **让开发状态外化到磁盘，从而不受单个对话窗口寿命（会满、会被压缩）的限制。**

**当前真实覆盖范围**（不是三个工具对等支持，请按实际情况使用）：

- **Claude Code**：完整支持，含 skill（`llmdev-new-task`、`llmdev-reorient`）与
  subagent（`llmdev-state-checker`、`llmdev-stuck-diagnoser`）。
- **Codex**：支持核心方法论（`AGENTS.md`）与编排循环脚本 `loop.sh`，
  没有 skill/subagent 这类扩展机制。
- **CodeBuddy**：仅有 adapter 占位文件，尚未深度适配，不能直接使用。

## 核心理念

对话窗口是 RAM（易失、会退化），文件系统是硬盘（真源）。
任何重要的东西，都必须在离开窗口前写进磁盘。详见 `.llmdev/core/00-principles.md`。

## 目录结构

```
.llmdev/
├── core/         工具无关的方法论（单一真源）
├── adapters/     各工具薄壳（claude-code / codex / codebuddy）
│   └── claude-code/   adapter.md + skills/（llmdev-new-task, llmdev-reorient）
│                      + agents/（llmdev-state-checker, llmdev-stuck-diagnoser）
├── templates/    可复制的产物模板（PLAN / STATE / JOURNAL）
└── scripts/      sync / loop（Codex 编排循环）/ init（应用到新项目）/ new-task
CLAUDE.md         生成物，勿手改
AGENTS.md         生成物，勿手改
.claude/skills/、.claude/agents/  由 sync.sh 分发的 llmdev-* 产物，勿手改
```

## 用法

**改规则**：编辑 `.llmdev/core/` 或 `.llmdev/adapters/`，然后：

```bash
bash .llmdev/scripts/sync.sh
```

会重新生成 `CLAUDE.md`（Claude Code）、`AGENTS.md`（Codex），
并把 Claude Code 的 skill/subagent 分发到 `.claude/skills/`、`.claude/agents/`。

**开始跟踪一个新任务**（生成 PLAN/STATE/JOURNAL 三件套）：

```bash
.llmdev/scripts/new-task.sh <任务名>
```

在 Claude Code 里对应 skill `llmdev-new-task`；恢复/核对任务进度对应
skill `llmdev-reorient`（会派发 `llmdev-state-checker` subagent 核对真实状态）。

**应用到新项目**：

```bash
/path/to/框架/.llmdev/scripts/init.sh /path/to/新项目
```

**用 Codex 跑长任务**（编排循环，补足其不自动换窗口的短板）：

```bash
.llmdev/scripts/loop.sh docs/plans/PLAN-x.md docs/state/STATE-x.md 20
```

## 工作流（工具无关）

1. **规划**（单独窗口）→ 用 `templates/PLAN.template.md` 产出自包含 plan。
2. **执行**（新窗口）→ 开工先做"重新定位协议"；维护 STATE 账本，小步 commit。
   同一问题失败 2 次 → 卡住协议（Claude Code 中派发 `llmdev-stuck-diagnoser`）。
3. **复盘** → 读 JOURNAL 审计日志，确认该信任什么、该复查什么。

## 状态

- ✅ 核心方法论、模板、sync/loop/init/new-task 脚本
- ✅ Claude Code 适配（含 skill/subagent）、Codex 适配
- ⬜ CodeBuddy 深度适配（当前占位）
