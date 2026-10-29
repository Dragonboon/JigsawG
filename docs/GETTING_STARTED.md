# Your first JigsawG puzzle

JigsawG is a Godot 4.7 addon for 2D jigsaw games. You need basic familiarity with
scenes and the Inspector; you do not need to edit the geometry or Board script.
Use the 4.7.2-stable reference build when reproducing the project's tests.

## Install into an existing project

Copy `addons/jigsawg/` into your project, then enable JigsawG in Project Settings
> Plugins. Keep the host project's project.godot, input mappings and main scene.
The addon has no Autoload or external addon requirement. Its own README and MIT
license travel with the installation. Examples, tests and root docs are for the
development checkout and are not required at runtime.

No verified store listing is documented here. Use the repository or a published
versioned addon ZIP; do not assume a similarly named catalog entry is JigsawG.

## Make a scene

1. Create a Node2D scene and add JigsawBoard.
2. Add a Camera2D and enable it for built-in camera navigation.
3. Create a JigsawPuzzleConfig in the Board's Puzzle Config field.
4. Save the config as a .tres, then set its Puzzle Texture to your own image.
5. Start with a small Manual grid, such as 5 columns and 4 rows.
6. Run the scene. Drag pieces together in Free mode; choose Mosaic in the
   gameplay resource if pieces should lock into the assembly board instead.

The default checkerboard is a diagnostic fallback, not production artwork.
Increase source image resolution before increasing piece count. Auto mode picks
an approximate count that fits image proportions; it does not promise exactly
500 pieces when requested. Begin with defaults before enabling trays or hints.

## Controls and assistance

Use the README control table for the default mouse/keyboard actions. Touch,
controller cursor, trays, hints and history are explicitly enabled through the
configuration's child Resources. The demo may enable features that are disabled
in a fresh configuration. Your game supplies menus, sounds and save-slot UI.

## Common problems

- No JigsawBoard in Add Node: verify the folder path and enable the plugin;
  inspect Godot's Output for import errors and use the supported engine.
- Blurry pieces: use higher resolution artwork; filtering cannot create detail.
- Generation fails: connect generation_failed and display get_generation_error().
- Saving returns null: generation is not complete. Wait for puzzle_generated and
  check is_puzzle_ready(), especially when frame batching is enabled.
- Camera shortcuts appear inactive: use an active Camera2D, check the camera
  Resource settings and ensure a host UI control is not consuming the input.
- Optional shortcuts do nothing: check the relevant feature is enabled and read
  its configuration contract before modifying the Board implementation.

Next: [advanced integration](ADVANCED_INTEGRATION.md),
[Resource API](RESOURCE_API.md), [events and reactions](EVENTS_AND_REACTIONS.md).
