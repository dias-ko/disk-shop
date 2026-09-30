extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var sound := Node.new()
	sound.set_script(load("res://scripts/sound.gd"))
	root.add_child(sound)
	var failures := 0
	for mode in ["run", "elevator"]:
		sound.set_music_mode(mode)
		var track: AudioStream = sound.music.stream
		sound.music.seek(track.get_length() - 0.15)
		await create_timer(0.65).timeout
		var advanced: bool = sound.music.playing and sound.music.stream != track
		print("MUSIC END: %s / duration %.2fs / advanced %s" % [mode, track.get_length(), advanced])
		if not advanced: failures += 1
	sound.music.stop()
	await create_timer(0.2).timeout
	sound.queue_free()
	await process_frame
	await create_timer(0.2).timeout
	call_deferred("quit", 1 if failures else 0)
