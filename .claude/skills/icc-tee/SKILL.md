---
name: icc-tee
description: >-
  Create, list, and remove tees between paths in one container. A tee reads
  one path and writes every byte it gets to each of N other paths, in order,
  until removed. Made for icc-pipes lanes, but any path that opens will do.
  What the bytes are, and why they are being copied, is the caller's business.
---

# icc-tee

A tee is one inlet and N outlets. Every byte that goes in the inlet comes
out of every outlet, in the order it went in. It is a fitting: it joins
paths that already exist and makes nothing else. Lanes come from
icc-pipes; the tee only joins them.

    /tmp/icc-tee-XXXXXXXX/pid    the tee process
    /tmp/icc-tee-XXXXXXXX/src    the inlet
    /tmp/icc-tee-XXXXXXXX/dst    the outlets, one per line

## Operations

    scripts/create SRC DST...  start a tee from SRC to every DST, print
                               its directory. Every path must exist.
    scripts/list               one line per tee: DIR up|down SRC DST...
    scripts/remove DIR         stop the tee, delete DIR. SRC and every
                               DST are left as they were.

To use a tee, write the inlet and read the outlets. There is nothing
else to do.

## Facts about the tee

The tee is `tee(1)` with the inlet on its stdin. These are properties of
that and of the paths it opens. The skill adds nothing to them.

- The tee is the reader of SRC. Bytes it takes are gone from SRC and
  exist only on the outlets. Read the outlets, not the inlet.
- The tee is one more writer on each DST. Everything true of any writer
  on that path is true of it: PIPE_BUF, the buffer, interleaving with
  other writers.
- Each chunk the tee reads is written to every outlet, in argument
  order, before the next chunk is read. An outlet that is full and not
  being drained stalls the tee, and so every other outlet behind it.
- Order holds from the inlet to each outlet. Nothing is kept; an outlet
  nobody reads fills, then stalls the tee.
- A DST that is a regular file is appended to, never truncated.
- Opening SRC blocks until it has a writer; opening a DST blocks until it
  has a reader. An icc-pipes lane is held open on both sides, so neither
  blocks. A bare FIFO does, and list says down until it opens.
- The tee ends when SRC hits EOF or a write to any DST fails. A held lane
  never does either, so the tee runs until removed or until a pipe on
  either end goes away. Then list says down. remove it and create it
  again.
- The outlets are in the tee's argv; the inlet is not. `pkill -f` on a
  DST path finds the tee. On the SRC path it finds nothing.

## In Claude Code

Every Bash call is a fresh shell. The tee is its own process, so it
outlives calls. Seats in one session share the container and its /tmp;
sessions do not, so no tee crosses that line.
