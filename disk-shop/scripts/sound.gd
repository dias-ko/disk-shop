extends Node

var muted := false
var voices: Array[AudioStreamPlayer] = []
var music: AudioStreamPlayer
var samples: Dictionary = {}
var voice_index := 0
var last_played: Dictionary = {}
var synth_rng := RandomNumberGenerator.new()
const MUSIC_TRACKS = {
	"run": [
		preload("res://assets/music/Crate Smash Sprint.mp3"),
		preload("res://assets/music/Crate Smash Sprint (1).mp3"),
		preload("res://assets/music/Crate Smash Sprint (2).mp3"),
		preload("res://assets/music/Crate Smash Sprint (3).mp3")
	],
	"elevator": [
		preload("res://assets/music/Elevator Jazz.mp3"),
		preload("res://assets/music/Elevator Motif.mp3")
	]
}
var music_mode := ""
var music_rng := RandomNumberGenerator.new()
var music_bags: Dictionary = {}
var previous_tracks: Dictionary = {}

func _ready() -> void:
	muted = AudioServer.is_bus_mute(0)
	music_rng.randomize()
	synth_rng.seed = 7291
	for id in ["hit", "coin", "ability", "shop", "host", "win"]:
		samples[id] = load("res://assets/audio/%s.wav" % id)
	for id in ["hit1", "hit2", "hit3", "hit4", "break", "ui", "door", "bass", "pierce", "double", "dash", "rush", "remix", "feedback", "hat", "sub", "sample", "encore"]:
		samples[id] = synthesize(id)
	for i in range(8):
		var voice := AudioStreamPlayer.new()
		voice.volume_db = -19
		add_child(voice)
		voices.append(voice)
	music = AudioStreamPlayer.new()
	music.volume_db = -17
	add_child(music)
	music.finished.connect(play_next_track)

func start_music() -> void:
	set_music_mode("elevator")

func set_music_mode(mode: String) -> void:
	if not MUSIC_TRACKS.has(mode): return
	if music_mode == mode and music.playing: return
	music_mode = mode
	play_next_track()

func next_track(mode: String) -> AudioStream:
	var bag: Array = music_bags.get(mode, [])
	if bag.is_empty():
		bag = range(MUSIC_TRACKS[mode].size())
		for i in range(bag.size() - 1, 0, -1):
			var j := music_rng.randi_range(0, i)
			var swap: int = bag[i]
			bag[i] = bag[j]
			bag[j] = swap
		# Every variation plays once; the next cycle cannot repeat the last track.
		if bag.size() > 1 and bag.back() == previous_tracks.get(mode, -1):
			var swap: int = bag[0]
			bag[0] = bag[bag.size() - 1]
			bag[bag.size() - 1] = swap
	var index: int = bag.pop_back()
	music_bags[mode] = bag
	previous_tracks[mode] = index
	return MUSIC_TRACKS[mode][index]

func play_next_track() -> void:
	if not is_inside_tree() or music_mode.is_empty(): return
	music.stream = next_track(music_mode)
	music.play()

func play_sound(id: String) -> void:
	if not is_inside_tree() or muted or not samples.has(id): return
	var time := Time.get_ticks_msec() / 1000.0
	if time - float(last_played.get(id, -1.0)) < 0.065: return
	last_played[id] = time
	var voice := voices[voice_index % voices.size()]
	voice_index += 1
	voice.stream = samples[id]
	voice.volume_db = -24 if id == "ui" else -19
	voice.pitch_scale = randf_range(0.94, 1.06) if id.begins_with("hit") else 1.0
	voice.play()

func synthesize(id: String) -> AudioStreamWAV:
	var rate := 22050
	var length := 0.22 if id.begins_with("hit") or id == "ui" else 0.65
	var bytes := PackedByteArray()
	bytes.resize(int(rate * length) * 2)
	for i in range(bytes.size() / 2):
		var t := float(i) / rate
		var n := synth_rng.randf_range(-1, 1)
		var s := 0.0
		match id:
			"hit1": s = n * exp(-t * 36) * 0.55 + sin(TAU * 175 * t) * exp(-t * 30) * 0.25
			"hit2": s = sin(TAU * 95 * t) * exp(-t * 24) * 0.65 + n * exp(-t * 45) * 0.3
			"hit3": s = (sin(TAU * 130 * t) + sin(TAU * 373 * t) * 0.3) * exp(-t * 25) * 0.5 + n * exp(-t * 32) * 0.2
			"hit4": s = (sin(TAU * 280 * t) + sin(TAU * 731 * t) * 0.45) * exp(-t * 20) * 0.45 + n * exp(-t * 35) * 0.25
			"ui": s = sin(TAU * (720 * t + 500 * t * t)) * exp(-t * 45) * 0.3
			"door": s = n * sin(PI * t / length) * 0.13 + sin(TAU * 72 * t) * sin(PI * t / length) * 0.1
			"break": s = n * exp(-t * 17) * 0.4 + sin(TAU * 55 * t) * exp(-t * 13) * 0.3
			"bass", "sub": s = sin(TAU * (46 * t + 4 * (1 - exp(-t * 28)))) * exp(-t * 9) * 0.72 + n * exp(-t * 65) * 0.2
			"pierce", "hat": s = (sin(TAU * (800 * t - 500 * t * t)) * 0.4 + n * 0.3) * exp(-t * 15)
			"dash", "rush": s = (n * 0.5 + sin(TAU * (90 * t + 700 * t * t)) * 0.25) * sin(PI * minf(t / 0.3, 1)) * exp(-t * 7)
			_:
				var freq := 220 + posmod(id.hash(), 5) * 55
				s = (sin(TAU * freq * t) + sin(TAU * freq * 1.5 * t) * 0.4) * exp(-t * 10) * 0.4
		s *= minf(t * 1200, 1.0) * minf((length - t) * 200, 1.0)
		bytes.encode_s16(i * 2, int(clampf(s, -0.85, 0.85) * 32767))
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = rate
	stream.data = bytes
	return stream
