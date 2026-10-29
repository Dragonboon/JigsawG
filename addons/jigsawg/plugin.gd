@tool
extends EditorPlugin
## Fresh installs may enable the plugin before the SVG import has completed.

const Board = preload("res://addons/jigsawg/src/jigsaw_board.gd")
const ICON_PATH: String = "res://addons/jigsawg/icon.svg"
var _registered: bool = false
var _icon_ready: bool = false


func _enter_tree() -> void:
	EditorInterface.get_resource_filesystem().filesystem_changed.connect(_register_board)
	_register_board()


func _register_board() -> void:
	if _icon_ready:
		return
	var icon: Texture2D
	var metadata := ConfigFile.new()
	if FileAccess.file_exists(ICON_PATH + ".import") and metadata.load(
		ICON_PATH + ".import") == OK:
		var imported: String = metadata.get_value("remap", "path", "")
		if not imported.is_empty() and FileAccess.file_exists(imported):
			icon = load(ICON_PATH) as Texture2D
	if _registered and icon == null:
		return
	_icon_ready = icon != null
	if _registered:
		remove_custom_type("JigsawBoard")
	add_custom_type("JigsawBoard", "Node2D", Board, icon)
	_registered = true


func _exit_tree() -> void:
	var filesystem: EditorFileSystem = EditorInterface.get_resource_filesystem()
	if filesystem.filesystem_changed.is_connected(_register_board):
		filesystem.filesystem_changed.disconnect(_register_board)
	if _registered:
		remove_custom_type("JigsawBoard")
	_registered = false
	_icon_ready = false
