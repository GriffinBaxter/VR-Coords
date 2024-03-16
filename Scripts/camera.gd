extends XRCamera3D

var capture_in_progress := false
var frame_time: float
var bvh_frames: PackedStringArray = []

@onready var camera = $"."
@onready
var start_and_stop_button: Button = $"../../Control/MarginContainer/VBoxContainer/StartAndStop"


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
	else:
		if bvh_frames.size():
			print(generate_bvh_string())
			bvh_frames = []


func _on_start_and_stop_pressed() -> void:
	capture_in_progress = !capture_in_progress
	start_and_stop_button.text = "Stop and Save" if capture_in_progress else "Start Recording"


func vector_to_bvh_format(vector: Vector3) -> String:
	var vector_array: PackedStringArray = []
	for index: int in range(3):
		vector_array.append("%.6f" % vector[index])
	return join_by_comma(vector_array)


func join_by_comma(array: PackedStringArray) -> String:
	return ", ".join(array)


func generate_bvh_string() -> String:
	var bvh_string := ""
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
		bvh_string += string + "\n"
	return bvh_string
