#!/usr/bin/env python3
"""Import only the addon, without original import metadata or UID cache."""
import argparse
from pathlib import Path
import shutil
import subprocess
import tempfile
from run_tests import execute, ROOT


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--godot', required=True)
    args = parser.parse_args()
    engine = str(Path(args.godot).resolve())
    with tempfile.TemporaryDirectory(prefix='jigsawg-install-') as folder:
        host = Path(folder)
        shutil.copytree(ROOT/'addons/jigsawg', host/'addons/jigsawg',
                        ignore=shutil.ignore_patterns('*.import', '__pycache__'))
        (host/'project.godot').write_text('''config_version=5
[application]
config/name="Independent JigsawG installation"
[editor_plugins]
enabled=PackedStringArray("res://addons/jigsawg/plugin.cfg")
[rendering]
renderer/rendering_method="gl_compatibility"
''')
        if not execute([engine, '--headless', '--path', str(host), '--import'], 120):
            raise SystemExit(1)
        (host/'probe.gd').write_text('''extends SceneTree
const Board = preload("res://addons/jigsawg/src/jigsaw_board.gd")
func _initialize() -> void:
	call_deferred("_run")
func _run() -> void:
	var board = Board.new()
	root.add_child(board)
	assert(board.is_puzzle_ready(), "Default board must generate without host assets")
	var state = board.capture_state()
	assert(state != null)
	assert(board.restore_state(state))
	board.queue_free()
	print("JigsawG independent addon installation: PASS")
	quit()
''')
        if not execute([engine, '--headless', '--path', str(host), '--script',
                        'res://probe.gd'], 120, expect_pass=True):
            raise SystemExit(1)


if __name__ == '__main__':
    main()
