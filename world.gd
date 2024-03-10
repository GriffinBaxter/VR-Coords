extends Node3D

var interface : XRInterface

func _ready():
	print("test")
	interface = XRServer.find_interface("OpenXR")
	if interface and interface.is_initialized():
		get_viewport().use_xr = true
