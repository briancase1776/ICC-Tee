# ICC-Tee

A Claude Code skill that tees paths between Claude instances. That is the
whole project.

Think of a tee fitting on a pipe. Water that comes in one end goes out both
others. The fitting has no idea what the water is or where the pipes lead.
This skill is the fitting. Nothing more.

## What this is

- A **tee**: one inlet path, N outlet paths, one process copying every byte
  from the inlet to each outlet, in order, until removed.
- The skill covers creating, listing, and removing tees. Using one is
  writing the inlet and reading the outlets. Nothing else.

## What this is not

Out of scope. Do not build, stub, or "leave room for" any of these:

- Pipes. Lanes come from the icc-pipes skill, which is its own project.
  This skill does not create, hold, list, or remove them, and does not
  restate how they work beyond the facts the tee itself depends on.
- Fan-in, merging, or joining. One inlet, many outlets, never the reverse.
- Filtering, transforming, splitting, or selecting what goes down each
  outlet. Every outlet gets every byte.
- Message formats, protocols, framing, or envelopes. Not even a line
  convention or a timestamp.
- Routing, brokers, discovery, registries, or topology.
- Persistence, replay, history, ledgers, or logging of what went through.
  An outlet may happen to be a file; that is the caller's business.
- Buffering, rate control, or backpressure beyond what tee(1) and the
  paths already give.
- Liveness, heartbeats, peer-death detection, or EOF markers.
- Auth, encryption, permissions, or multi-user anything.
- Config files, plugins, options, or extension points.

If a request touches any of the above, stop and say it is out of scope. Do
not add it. Before adding anything, ask: is this the fitting, or something
that plugs into the fitting? Only the fitting belongs here.

## Testing

A test harness is allowed **only to prove the tee works**: hold a few
FIFOs, tee one into the others, push bytes in, see them arrive on every
outlet in order, remove it. The harness holds its own FIFOs so it does not
depend on icc-pipes; that is setup, not a second pipes skill. If a test
needs more than a few lines of setup, the tee is too complicated, not the
test.

## Rules

- **KISS.** One way to do each thing. Prefer the OS primitive over a library.
  Prefer a shell script over a program. Prefer no dependency over one.
- **Small.** If a file is getting long, you are adding scope, not features.
- **No speculative work.** Build what is asked, not what might be asked later.
- **No abstraction until there are two real callers.**
- **Facts, not recipes.** SKILL.md states what tee(1) and the paths do. It
  does not tell the caller how to wait, poll, frame, or pick outlets.

## Layout

```
.claude/skills/icc-tee/SKILL.md     the skill definition Claude Code loads
.claude/skills/icc-tee/scripts/     create, list, remove. One script each.
tests/                              the minimal harness described above
```

Do not add directories without a reason that fits the scope above.
