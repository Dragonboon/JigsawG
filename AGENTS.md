# JigsawG: agent entry point

Scope: entire repository. JigsawG is a self-contained **Godot 4.7** 2D puzzle
addon; CI pins **4.7.2-stable**. Only `addons/jigsawg/` is installed.
The host owns HUD, artwork, audio, progression, save slots and online services.

## Inspect and define the change

1. Check the authorized branch/HEAD, user edits, `README.md`, addon version and
   `.github/workflows/godot-regression.yml`. Source and current tests outrank old
   chat and roadmap claims. Use narrow searches rather than whole-tree dumps.
2. Record the player/developer outcome, existing owner, reused extension point,
   missing behavior, compatibility/defaults and a focused acceptance fixture.
3. Read the affected code, actual callers and applicable sections of the
   [detailed contract](docs/AGENT_CONTRACT.md); its constraints remain binding.

| Area | Owner under `addons/jigsawg/` | Evidence |
| --- | --- | --- |
| Seams, shape, UVs | `src/jigsaw_geometry.gd`, `src/jigsaw_piece.gd` | Geometry/organic tests; zoom on real artwork |
| Groups, snap, rotation | `src/jigsaw_group_model.gd`, `src/jigsaw_connection_resolver.gd` | Group integration and saved-state regressions |
| Config, state, generation | `resources/jigsaw_puzzle_config.gd`, `src/jigsaw_state_validator.gd` | [Resource API](docs/RESOURCE_API.md); batching/lifecycle tests |
| Input, camera, hints, trays, history | Board + relevant opt-in config Resource/helper | Focused tests from runner; mouse/keyboard/device observation |
| Motion, signals, reactions | `events/` | [Events](docs/EVENTS_AND_REACTIONS.md); event-order and motion tests |
| Host installation | `plugin.gd`, `plugin.cfg`, [advanced integration](docs/ADVANCED_INTEGRATION.md) | Clean addon-only installation |

## Non-negotiable contracts

- Board exposes one Inspector config: `puzzle_config: JigsawPuzzleConfig`.
  New options belong to the appropriate Resource; preserve Free and Mosaic modes,
  existing defaults, signals, saved formats and numeric enum/event-mask values.
- Generate each shared seam once; its neighbor uses the complementary contour.
  Local RNG and unchanged inputs provide repeatability. Never copy a full source
  bitmap per piece or claim tessellation creates absent image detail.
- GroupModel owns connectivity. Merges retain the dragged anchor root; connected
  pieces stay rigid. Snap/save transforms are exact; motion adapters affect display
  transforms only. Do not create parallel group/state authorities.
- Validate saves before mutation. Batched rebuilds cancel obsolete jobs, frame
  the full guide initially and respect caller camera settings. Host code waits for
  `puzzle_generated`; partial generation is not gameplay-ready.
- Touch/controller input, history, hints and trays remain opt-in. Preserve host UI
  input ownership, reduced-motion semantics and legacy mouse/keyboard behavior.
  Hints/organizer presentation cannot mutate authoritative puzzle state.
  Simultaneous interactive boards in one viewport are not guaranteed isolated.
- Keep game policy, networking and root examples outside the runtime contract.
  Never mutate shared Resource presets for per-session state or alter user artwork.
  Preserve license provenance and Godot-generated UIDs.

## Prove the affected behavior

From the repository root with the supported engine:

```sh
godot --version
python3 scripts/ci/run_tests.py --godot godot --list
python3 scripts/ci/run_tests.py --godot godot --test test_camera_selection_focus
python3 scripts/ci/run_tests.py --godot godot
```

Replace the focused test with the owning regression; the runner imports first,
applies timeouts and checks logs. Do not maintain a second hardcoded suite list.
Use [testing](docs/TESTING.md) for the complete release matrix. Packaging changes
also run `python3 scripts/ci/check_addon_installation.py --godot godot`.

Input/rendering changes require interactive `examples/puzzle_lab.tscn` checks:
zoom, snap, connected drag, cancel, focus, resize and affected device paths.
For large-puzzle claims measure 200/500/2000-piece scenarios on named hardware;
`tests/benchmark_large_puzzles.gd` is separate from the fast suite and headless
results do not establish GPU frame time or interaction quality.
Docs-only edits need path/link checks, not engine reruns.

## Complete the slice

Reproduce a defect before changing its owner. Test observable failure/cancel and
restore/lifetime cases where affected; trace actual scene instances, subscriptions
and teardown rather than counting symbol references. A new shared abstraction
needs two independent consumer scenarios. Native/existing adapters come first.
Review public declarations, defaults, saves and actual consumers against the base;
document migration/version decisions when changing compatibility.

Report owner → actual wiring → contract → executed checks → limitations.
Separate static, headless, visual/device and measured evidence. No invented FPS,
memory or AI-productivity gains. Preserve unrelated work, honor the requested
branch/publishing scope and protect concurrent main changes without force pushes.
