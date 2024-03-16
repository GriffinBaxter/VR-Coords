extends XRCamera3D

var capture_in_progress := false
var frame_time: float
var bvh_frames: PackedStringArray = []
var bvh_string: String

@onready var camera = $"."
@onready
var start_and_stop_button: Button = $"../../Control/MarginContainer/VBoxContainer/StartAndStop"
@onready var file_dialog: FileDialog = $"../../FileDialog"


func _ready() -> void:
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


func _on_start_and_stop_pressed() -> void:
	capture_in_progress = !capture_in_progress
	start_and_stop_button.text = "Stop and Save" if capture_in_progress else "Start Recording"


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
