# Integrate JigsawG into a game

## Ownership and compatibility

JigsawBoard coordinates the existing pure geometry, connection, group, layout,
state and spatial-picking helpers. JigsawPuzzleConfig is its single public
Inspector entry. Extend behavior through child Resources, public Board methods,
signals, JigsawReaction and presentation-only JigsawMotionAdapter implementations.
The host owns HUD, progression, art, save slots and network services.

Preserve the meaning of enum values, event masks and quarter turns when extending
the addon. Do not mutate a shared config or use piece drawing transforms as the
logical puzzle state. Multiple simultaneously interactive Boards in one viewport
are not guaranteed input-isolated; integration must choose an input owner.

## Generation and host UI

Connect puzzle_generated and generation_failed before configure(config), because
small puzzles can generate synchronously. Batched generation is cancellable and
a new configuration supersedes the old job. Use is_puzzle_ready() before capture
or interaction-dependent work; get_generation_progress() supports loading UI.
See the exact [loading/failure/save example](RESOURCE_API.md#loading-failure-and-saving).
A successful configure call alone is not a readiness notification.

## Persistence

Use capture_state() for a session snapshot or capture_resume_config() for a
configuration with resumable state. Store snapshots under user:// with the
host's save-slot policy. Handle a null capture before writing files and check
the boolean result of restore_state(). The validator rejects incompatible
snapshots before modifying the live puzzle. Keep the matching artwork, grid,
mode and optional tray configuration available when resuming.

Only load trusted Godot Resource files: Resources can reference scripts. For
network/cloud or user-provided data, validate through a host-owned serialization
boundary; do not expose arbitrary Resource loading as an untrusted save importer.
Undo history and virtual pointer positions are not persisted. Presentation-only
hints and category browsing must not change authoritative puzzle state.

## Events and custom presentation

Use the [event contract](EVENTS_AND_REACTIONS.md) for typed semantic events and
reactions. Shared Resource reactions should remain stateless; store session
scores in the host. Honor reduced motion in custom effects. Keep local gameplay
signals distinct from authoritative networking messages; no transport or lobby
is supplied by the addon.

## Scale and release

Enable generation batches for large boards and test representative artwork.
Planner/headless timings are not frame-time or input-latency measurements. Use
[TESTING](TESTING.md) for real 200/500/2000-piece visual, device and memory checks.
Pin a tested version and review CHANGELOG before replacing addons/jigsawg.

Maintainers can build an addon-only ZIP with `python3 scripts/package_release.py`
from a clean tracked checkout. It includes the addon README/LICENSE and a SHA-256
sidecar. The repository archive also excludes development material; clone the
repository when contributing or running the demo/tests.
