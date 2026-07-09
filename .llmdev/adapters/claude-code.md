# Claude Code 适配

> 本节是 Claude Code 专属约定，下方为共享核心方法论（自动拼入）。

## 工作流

- **规划**用 plan mode；产出落成 `docs/plans/PLAN-<任务>.md`（用框架模板）。
- **执行**在新对话进行，开工先执行"重新定位协议"。
- 长任务维护 `docs/state/STATE-<任务>.md` 与 `docs/journal/JOURNAL-<任务>.md`。

## 善用 subagent 保持主窗口清爽

探索性、检索性的活（读一堆文件、跑一批检查、查证候选）派给 subagent，
让它在独立干净窗口里做完只返回结论，主窗口不被噪音污染。

## 与本框架的关系

本文件（CLAUDE.md）由 `.llmdev/scripts/sync.sh` 生成，**请勿手改**。
要改规则，改 `.llmdev/core/` 或 `.llmdev/adapters/claude-code.md`，然后重跑 sync。
