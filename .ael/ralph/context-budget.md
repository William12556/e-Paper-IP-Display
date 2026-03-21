# AEL Context Budget Report

Generated: 2026-03-20 13:39:22
Model: Devstral-Small-2-24B-Instruct-2512
Context window: 393,216 tokens

## Initial task load
Estimated tokens at task start: 255 tokens (0.1% of window)
Headroom available: 392,961 tokens

## Budget thresholds
Warn at:  314,572 tokens (80%)
Abort at: 373,555 tokens (95%)

## Iteration estimates
Estimated accumulation per iteration: ~300 tokens
Iterations before warn threshold:  ~1047
Iterations before abort threshold: ~1244

## Guidance for Strategic Domain
When authoring the next tactical_brief or T04 prompt:

- Current initial load is 0.1% of context window
- Each Ralph Loop phase iteration accumulates ~300 tokens
- Recommended tactical_brief size: ≤1,000 tokens
- Avoid embedding large design documents or code blocks in the brief
- Context pressure symptoms: duplicate tool calls, repeated reads, verbose responses
- If symptoms appear, reduce brief size and restart with --mode reset
