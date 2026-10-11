extends SceneTree
## Host-facing lifecycle regression: loading, failure, cancellation and signal callbacks.
## Run with: godot --headless --path . --script res://tests/test_generation_lifecycle.gd

const BoardScript = preload("res://addons/jigsawg/src/jigsaw_board.gd")
var _failures: int = 0

func _initialize() -> void:
	call_deferred("_run")

func _check(condition: bool, message: String) -> void:
	if not condition:
		_failures += 1
		printerr("FAIL: " + message)

func _config(side: int, batch: int = 0) -> JigsawPuzzleConfig:
	var config: JigsawPuzzleConfig = JigsawPuzzleConfig.new()
	config.columns = side
	config.rows = side
	config.gameplay.initial_scatter = false
	config.gameplay.generation_batch_size = batch
	return config

func _test_reconfigure_on_progress() -> void:
	var board: BoardScript = BoardScript.new()
	board.configure(_config(2))
	var completions: Array[int] = []
	var starts: Array[int] = []
	board.puzzle_generated.connect(func(count: int) -> void: completions.append(count))
	board.puzzle_started.connect(func(event: JigsawPuzzleEvent) -> void:
		starts.append(int(event.metadata["piece_count"]))
	)
	board.generation_progress_changed.connect(func(done: int, total: int) -> void:
		if done == 4 and total == 4:
			board.configure(_config(3))
	)
	root.add_child(board)
	_check(completions == [9], "Reconfiguration at final progress must not complete the superseded build.")
	_check(starts == [9], "Only the replacement puzzle may start.")
	_check(board.get_piece_count() == 9, "Replacement grid must remain intact.")
	board.free()

func _test_readiness_and_failure() -> void:
	var board: BoardScript = BoardScript.new()
	_check(not board.is_puzzle_ready(), "Detached board is not ready.")
	_check(board.capture_state() == null, "Detached capture must not create an empty save.")
	_check(board.capture_resume_config() == null, "Detached resume capture must fail as a whole.")
	var failures: Array[String] = []
	board.generation_failed.connect(func(reason: String) -> void: failures.append(reason))
	board.configure(_config(80))
	root.add_child(board)
	_check(failures.size() == 1, "Invalid source/grid must notify the host once.")
	_check(not board.is_generating() and not board.is_puzzle_ready(), "Failed build must not appear busy or ready.")
	_check(not board.get_generation_error().is_empty(), "Late subscribers can query the failure.")
	_check(board.capture_resume_config() == null, "Failed build must not produce a save config.")
	board.configure(_config(2, 1))
	_check(board.is_generating() and not board.is_puzzle_ready(), "Batch begins in loading state.")
	_check(board.get_generation_error().is_empty(), "Retry clears previous error.")
	_check(board.capture_resume_config() == null, "A loading save must not silently become a fresh puzzle.")
	await _wait_for_board(board)
	_check(board.is_puzzle_ready(), "Finished board is ready for host integration.")
	var config: JigsawPuzzleConfig = board.capture_resume_config()
	_check(config != null and config.resume_state.get_piece_count() == 4, "Ready capture includes all pieces.")
	board.free()

func _wait_for_board(board: BoardScript) -> void:
	for frame: int in range(30):
		if not board.is_generating():
			return
		await process_frame
	_check(false, "Generation did not finish within 30 frames.")

func _test_detach_batch() -> void:
	var board: BoardScript = BoardScript.new()
	board.configure(_config(3, 1))
	root.add_child(board)
	root.remove_child(board)
	_check(not board.is_generating(), "Leaving the tree cancels loading immediately.")
	_check(not board.is_puzzle_ready(), "Detached board cannot be saved.")
	root.add_child(board)
	await _wait_for_board(board)
	_check(board.is_puzzle_ready() and board.get_piece_count() == 9, "Reattaching restarts only the cancelled build.")
	board.free()

func _test_reconfigure_before_first_batch() -> void:
	var board: BoardScript = BoardScript.new()
	var completions: Array[int] = []
	board.configure(_config(2, 1))
	board.puzzle_generated.connect(func(count: int) -> void: completions.append(count))
	board.generation_progress_changed.connect(func(done: int, total: int) -> void:
		if done == 0 and total == 4:
			board.configure(_config(3))
	)
	root.add_child(board)
	await process_frame
	await process_frame
	_check(completions == [9], "Replacing a build before its first yield emits one completion.")
	_check(board.is_puzzle_ready() and board.get_piece_count() == 9, "Old coroutine must not append pieces to the replacement.")
	board.free()

class CountingReaction extends JigsawReaction:
	var starts: int = 0
	func react(_board: Node2D, event: JigsawPuzzleEvent) -> void:
		if event.type == JigsawPuzzleEvent.Type.PUZZLE_STARTED:
			starts += 1

func _test_reaction_isolation() -> void:
	var board: BoardScript = BoardScript.new()
	var old_reaction: CountingReaction = CountingReaction.new()
	var new_reaction: CountingReaction = CountingReaction.new()
	var first: JigsawPuzzleConfig = _config(2)
	first.reactions.append(old_reaction)
	var replacement: JigsawPuzzleConfig = _config(3)
	replacement.reactions.append(new_reaction)
	board.configure(first)
	board.event_emitted.connect(func(event: JigsawPuzzleEvent) -> void:
		if event.type == JigsawPuzzleEvent.Type.PUZZLE_STARTED and int(event.metadata["piece_count"]) == 4:
			board.configure(replacement)
	)
	root.add_child(board)
	_check(old_reaction.starts == 0, "Superseded event reactions must stop after replacement.")
	_check(new_reaction.starts == 1, "Replacement reactions must not receive old puzzle events.")
	board.free()

func _test_staged_configuration() -> void:
	var board: BoardScript = BoardScript.new()
	board.configure(_config(2))
	root.add_child(board)
	var saved: JigsawPuzzleState = board.capture_state()
	saved.piece_positions[0] += Vector2(40, 50)
	var current: JigsawPuzzleConfig = _config(2, 1)
	current.resume_state = saved
	board.configure(current)
	var pending: JigsawPuzzleConfig = _config(3)
	board.configure(pending, false)
	await _wait_for_board(board)
	_check(board.get_configuration() == pending, "Getter exposes the staged Inspector configuration.")
	_check(board.get_piece_node(0).position == saved.piece_positions[0], "Staging a preset must not replace an active build's resume state.")
	var resume: JigsawPuzzleConfig = board.capture_resume_config()
	_check(resume.columns == 2 and resume.rows == 2, "Saving uses the applied preset, not an unbuilt staged preset.")
	_check(resume != current and resume.resume_state != saved, "Captured resources remain detached.")
	board.apply_configuration()
	_check(board.get_piece_count() == 9, "Apply explicitly activates the staged preset.")
	board.free()

func _run() -> void:
	_test_reconfigure_on_progress()
	await _test_readiness_and_failure()
	await _test_detach_batch()
	await _test_reconfigure_before_first_batch()
	_test_reaction_isolation()
	await _test_staged_configuration()
	await process_frame
	if _failures == 0:
		print("JigsawG generation lifecycle: PASS")
	quit(0 if _failures == 0 else 1)
