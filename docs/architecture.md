# Conceptual architecture

This is a conceptual public reference, not a complete internal configuration for any
agent runtime.

```text
Human: goal, scope, approval boundaries
                  |
                  v
Planning: classify work and coordinate decisions
       +----------+-----------+
       |                      |
       v                      v
Research: evidence       Engineering: implement, test, review
       |                      |
       +----------+-----------+
                  v
Routine delivery: reversible handoff and verification
```

Work classification is deliberately multidimensional:

```text
environment ─┐
complexity  ─┼─> workflow choice ─> validation depth ─> delivery gate
risk        ─┤
delivery requirements ─┘
```

`environment` describes where the work runs, not its inherent difficulty.
`complexity` describes implementation and coordination effort. `risk` captures
reversibility and impact. `delivery requirements` capture whether a local result must
be handed to another system or person. Keeping these dimensions separate avoids
treating a task as safe merely because it is small, or complex merely because it runs
outside one machine.

> **繁中對照：** 此圖是公開概念參考，不是任何 agent runtime 的完整內部設定。人類設定目標、範圍與核准邊界；規劃負責分類與協調；研究提供證據；工程負責實作與驗證；例行交付只處理可回復的交接。工作流程同時考量環境、複雜度、風險與交付需求，而非單一快慢分類。
