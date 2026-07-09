# Claude Code 适配

> 本节是 Claude Code 专属约定，下方为共享核心方法论（自动拼入）。

## 工作流

- **规划**用 plan mode；产出落成 `docs/plans/PLAN-<任务>.md`（用框架模板）。
- **执行**在新对话进行，开工先执行"重新定位协议"。
- 长任务维护 `docs/state/STATE-<任务>.md` 与 `docs/journal/JOURNAL-<任务>.md`。

## 善用 subagent 保持主窗口清爽

探索性、检索性的活（读一堆文件、跑一批检查、查证候选）派给 subagent，
让它在独立干净窗口里做完只返回结论，主窗口不被噪音污染。

## 本框架提供的 skill / subagent

- **skill `llmdev-new-task`**：开始跟踪一个新任务时用，生成
  PLAN/STATE/JOURNAL 三个文件（调用 `.llmdev/scripts/new-task.sh`）。
- **skill `llmdev-reorient`**：执行"重新定位协议"的入口；
  它会派发 `llmdev-state-checker` subagent 去核对真实状态，
  只把摘要带回主对话。
- **subagent `llmdev-state-checker`**（只读）：读 PLAN/STATE、
  跑 git/测试命令，压缩成摘要返回，不做任何修改。
- **subagent `llmdev-stuck-diagnoser`**（只读）：触发"卡住协议"时用
  （同一问题失败 2 次）。以独立、不受此前失败框住的视角重新诊断，
  给出根因和一个本质不同的思路，或建议直接停下问人。它不动手改代码。

## 与本框架的关系

本文件（CLAUDE.md）由 `.llmdev/scripts/sync.sh` 生成，**请勿手改**。
要改规则，改 `.llmdev/core/` 或 `.llmdev/adapters/claude-code/adapter.md`，然后重跑 sync。
skill/subagent 的源文件在 `.llmdev/adapters/claude-code/{skills,agents}/`，
同样由 sync 分发到 `.claude/`，不要手改 `.claude/skills/llmdev-*` 或 `.claude/agents/llmdev-*`。
