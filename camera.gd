extends XRCamera3D

var capture_complete := false
var capture_in_progress := true
var frame_time: float
var bvh_frames: PackedStringArray = []

@onready var camera = $"."


func _ready() -> void:
	await get_tree().create_timer(1).timeout

	capture_complete = true


func _physics_process(delta: float) -> void:
	if capture_in_progress:
		if !frame_time:
			frame_time = delta
		if capture_complete:
			capture_in_progress = false
			print(generate_bvh_string())
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
