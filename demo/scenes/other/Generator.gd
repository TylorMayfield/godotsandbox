extends Spatial

onready var screen_surface = $InteractiveItem/Model.mesh.surface_get_material(2)
onready var working_sound = $WorkingSound


func _ready():
	goat_interaction.connect("object_activated", self, "_on_object_activated")
	goat_interaction.connect("pressed", self, "_on_object_activated")


func _on_object_activated(object_name, _point):
	if object_name == "generator":
		if goat_state.get_value("power_on") == false:
			goat_voice.prevent_default()
			screen_surface.emission = Color("ff4848")
			working_sound.play()
			goat_state.set_value("power_on", true)
		else:
			goat_voice.prevent_default()
			screen_surface.emission = Color("ffffff")
			working_sound.stop()
			goat_state.set_value("power_on", false)
