extends XRCamera3D

var interface: XRInterface
var waiting_to_capture := false
var capture_in_progress := false
var frame_time: float
var bvh_frames: PackedStringArray = []
var bvh_string: String

@onready var camera = $"."
@onready var start_button: Button = $"../../Control/MarginContainer/VBoxContainer/StartButton"
@onready var file_dialog: FileDialog = $"../../FileDialog"
@onready var beep: AudioStreamPlayer = $"../../BeepAudio"


func _ready() -> void:
	interface = XRServer.find_interface("OpenXR")
	if interface and interface.is_initialized():
		get_viewport().use_xr = true
	file_dialog.filters = ["*.bvh ; BVH"]


func _physics_process(delta: float) -> void:
	if capture_in_progress:
		if !frame_time:
			frame_time = delta
		else:
			(
				bvh_frames
				. append(
					join_by_comma(
						[
							vector_to_bvh_format(camera.position),
							vector_to_bvh_format(camera.rotation_degrees),
						]
					)
				)
			)
	elif bvh_frames.size():
		bvh_string = generate_bvh()
		bvh_frames = []
		file_dialog.current_file = Time.get_datetime_string_from_system().replace(":", ".") + ".bvh"
		file_dialog.visible = true


func _on_start_button_pressed() -> void:
	if !waiting_to_capture and !capture_in_progress:
		waiting_to_capture = true
		start_button.text = "Recording in 3 seconds... (sound will play once started)"
		await get_tree().create_timer(3).timeout

		beep.play()
		waiting_to_capture = false
		capture_in_progress = !capture_in_progress
		start_button.text = "Capture in Progress... (press to stop)"
	elif !waiting_to_capture and capture_in_progress:
		capture_in_progress = !capture_in_progress
		start_button.text = "Start Recording"


func _on_file_dialog_file_selected(path: String) -> void:
	var save_path = path if path.ends_with(".bvh") else path + ".bvh"
	var save_file = FileAccess.open(save_path, FileAccess.WRITE)
	save_file.store_string(bvh_string)


func vector_to_bvh_format(vector: Vector3) -> String:
	var vector_array: PackedStringArray = []
	for index: int in range(3):
		vector_array.append("%.6f" % vector[index])
	return join_by_comma(vector_array)


func join_by_comma(array: PackedStringArray) -> String:
	return ", ".join(array)


func generate_bvh() -> String:
	var bvh := ""
	for string: String in [
		"HIERARCHY",
		"ROOT Point",
		"{",
		" OFFSET 0.000000 0.000000 0.000000",
		" CHANNELS 6 Xposition Yposition Zposition Xrotation Yrotation Zrotation",
		" End Site",
		" {",
		"  OFFSET 0.000000 0.000000 0.000000",
		" }",
		"}",
		"MOTION",
		"Frames: " + str(bvh_frames.size()),
		"Frame Time: " + "%.6f" % frame_time,
		"\n".join(bvh_frames)
	]:
		bvh += string + "\n"
	return bvh
