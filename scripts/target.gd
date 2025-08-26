extends MeshInstance3D

func _ready():
	GlobalSignals.new_target_location.connect(_on_new_target_location)


func _on_new_target_location(new_loc:Vector3):
	global_position = new_loc


func set_new_random_location():
	print("set_new_random_location")
	var offset_x:float = randf_range(2.5, 4.5) * (-1 if randf() < 0.5 else 1)
	var offset_z:float = randf_range(2.5, 4.5) * (-1 if randf() < 0.5 else 1)
	global_position = global_position + Vector3(offset_x, 0, offset_z)
