---
name: llmdev-new-task
description: 开始跟踪一个新的长任务时使用——生成本任务的 PLAN/STATE/JOURNAL 三个文件。用户说"开始一个新任务"、"帮我建个 plan 跟踪"、或你判断当前工作值得用框架的状态外化机制跟踪时触发。
---

# llmdev-new-task

## 何时使用

- 用户明确要求开始跟踪一个新任务 / 建立 plan。
- 你判断接下来的工作是多步骤、可能跨对话窗口的，值得用
  PLAN/STATE/JOURNAL 三件套跟踪（参见 CLAUDE.md 中"共享核心方法论"一节）。

## 怎么做

1. 确定任务名（简短、kebab-case，例如 `add-auth`、`fix-payment-bug`）。
   如果用户没给，从对话内容里提炼一个，跟用户确认。
2. 运行：
   ```
   bash .llmdev/scripts/new-task.sh <任务名>
   ```
   （若当前不在项目根目录，加第二个参数指定项目根目录路径）
3. 脚本会在 `docs/plans/`、`docs/state/`、`docs/journal/` 下各生成一个文件，
   已存在的文件不会被覆盖（脚本会跳过并提示）。
4. 打开生成的 `docs/plans/PLAN-<任务名>.md`，把"目标/验收标准""涉及文件"
   "关键决策""步骤"这些占位内容替换成本次任务的实际规划——
   不要留着模板的占位符不填。
5. 向用户报告生成了哪些文件，并确认 PLAN 内容是否符合预期。
