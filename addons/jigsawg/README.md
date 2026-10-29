# JigsawG

Portable 2D jigsaw addon for Godot 4.7 (reference: 4.7.2-stable).
Enable JigsawG in Project Settings > Plugins. Add JigsawBoard to a 2D scene,
assign a JigsawPuzzleConfig, choose artwork and a small initial grid, then run.
An active Camera2D enables built-in navigation. No Autoload or other addon is needed.

Free mode assembles connected groups; Mosaic locks pieces into the board.
Optional trays, hints, touch/controller input, history and feedback are configured
through Resources. The host game owns its HUD, progression, assets and save slots.
Wait for puzzle_generated / is_puzzle_ready() before capturing state; handle
generation_failed and failed restore_state calls. Source image detail limits
usable piece counts. Real performance and device behavior require target testing.

Documentation: https://github.com/Dragonboon/JigsawG/tree/main/docs
Start: docs/GETTING_STARTED.md; advanced: docs/ADVANCED_INTEGRATION.md;
exact contracts: docs/RESOURCE_API.md and docs/EVENTS_AND_REACTIONS.md.

Distribution remains preview, not a certification of production performance.
License: MIT; keep the included LICENSE. Version: plugin.cfg.
