<!-- graft:start -->
## Graft — repo context graph

This repo is indexed in `graft/`: small linked markdown nodes that explain each
system and carry exact file:line spans, kept in sync with the code through git.

For ANY task here — understanding how something works, finding where code lives,
or scoping a change — get context from the graph before grepping or opening
source files. Re-ask freely (it's cheap) and reuse literal identifiers you
already have (symbol, error string, file name) as the query. New to this repo?
Run `graft map` first — a token-budgeted orientation (dir clusters, hubs,
hotspots), no LLM, no key.

- Run `graft ask "<your question>" --source` → ranked nodes with the relevant
  code spans inlined (each hit's ≤8-line crux by default; `--full` for whole
  definitions when the crux isn't enough). Match the tool to the task shape:
  for understanding or editing, the top node IS the answer — cite its
  `covers:` file:line spans and edit straight from `--source`. For
  exhaustive tasks ("every occurrence / every caller of this pattern"), ranked
  results are top-N, not complete — run `graft grep "<literal>"` instead
  (exhaustive over indexed files, grouped by enclosing symbol), falling back
  to raw `grep -rn` only for unindexed files.
- `graft skeleton <file>` → every definition's signature + span, ~10× cheaper
  than reading the file; use it to skim an API surface.
- `graft callers <symbol>` gives precomputed, exact edges — who calls this.
  Add `--direction out` for what it calls, or `--depth N` to walk
  transitively for the full blast radius. For structural questions, skip
  ranking and use this directly.
- Or browse: `graft/INDEX.md` lists every node; follow the links.
- Monorepos and folders of multiple repos rank fairly across sub-projects —
  hits carry `[scope/]` labels naming which one they're from. Narrow with
  `graft ask "<task>" --in <scope>/` once you know where you're working.

If a returned span is truncated ("+N more lines"), open the file at that exact
range before finalizing. Only open source files when a node genuinely lacks a
needed detail, and then at the exact file:line the node points to — never
re-read whole files.

After big code changes, refresh the graph with `graft build` (deterministic,
no API key, $0).
<!-- graft:end -->

## The Agency — specialist agent catalog

273 specialist agent personas are installed at `~/.claude/agents/*.md`, one
file per specialist, covering 18 divisions: academic, design, engineering,
finance, game-development, gis, healthcare, marketing, paid-media, product,
project-management, research, sales, security, spatial-computing,
specialized, strategy, support, testing. Each file has an identity,
workflow, deliverables, and success metrics for one specific kind of
expertise (e.g. backend-architect, seo-specialist, penetration-tester,
ux-researcher).

When a task calls for a specific kind of expertise, find the matching file
(list or grep `~/.claude/agents/` for the relevant division/slug — file
names are `<division>-<role>.md`), read only that one file, and adopt its
identity/workflow/deliverables for the task instead of a generic approach.
Don't read the whole directory — read only the one file that matches the
task.

## Operational constraints — apply to every task

1. **Minimal viable solution first.** Execute simple tasks with the minimum
   required logic and code. Do not add unsolicited architecture,
   abstractions, or premature optimizations.
2. **Ambiguity handling (zero-assumption policy).** If requirements,
   parameters, or intent are ambiguous or incomplete, stop immediately and
   ask targeted clarifying questions before executing. Never guess or
   interpolate missing specifications.
3. **Strict scope adherence.** Modify only the exact files, functions, or
   text explicitly requested. Do not refactor adjacent code, update styles,
   or alter working dependencies unless instructed.
4. **Pre-delivery verification checklist.** Before returning the final
   output, review it step-by-step against the original request. Validate
   syntax, logic, and edge cases so the solution is complete, functional,
   and strictly scoped.
