# CodeBuddy 适配

> 本节是 CodeBuddy 专属约定，下方为共享核心方法论（自动拼入）。

## CodeBuddy 不会自动按阶段换窗口——用磁盘纪律补足

CodeBuddy 没有 skill/subagent 这类扩展机制，核心方法论完全靠这份
`CODEBUDDY.md` 承载。和 Codex 一样，补足"自动换窗口"缺口靠磁盘纪律，两种玩法：

1. **单进程扛压缩**：靠 STATE 账本 + 重新定位协议，在自身压缩里生还。
   适合中等长度任务。
2. **编排循环**（长任务推荐）：用 `.llmdev/scripts/loop.sh` 反复调用 CodeBuddy，
   每轮都是新鲜上下文，喂同一句"读 STATE → 核对真实状态 → 做下一步 → 更新 STATE"。
   CodeBuddy CLI 同样是无状态单轮调用模型，可直接复用这个脚本，不需要另写一份。

## 工作流

- 规划产出落 `docs/plans/PLAN-<任务>.md`；执行开工先做重新定位协议。
- 长任务维护 `docs/state/STATE-<任务>.md` 与 `docs/journal/JOURNAL-<任务>.md`。

## 与本框架的关系

本文件（CODEBUDDY.md）由 `.llmdev/scripts/sync.sh` 生成，**请勿手改**。
要改规则，改 `.llmdev/core/` 或 `.llmdev/adapters/codebuddy.md`，然后重跑 sync。
