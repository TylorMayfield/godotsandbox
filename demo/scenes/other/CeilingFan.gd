extends Spatial


func _physics_process(delta):
	$Blades.rotate_y(6.4*delta)
