extends RigidBody

class_name Robot

onready var _player = get_tree().get_nodes_in_group("player")[0]
onready var LineDrawer = preload("res://Scripts/DrawLines3D.gd").new()

var debug = true

var paused = false

const player_range = 12
const dart_speed = 700
const robot_field_of_view = 15
var _rng = RandomNumberGenerator.new()
var _last_dart = 0
var _defeated = false
var _interested = false

var audio_robot_awake = ["Robot/Awaken/A"]
var audio_robot_shoot = ["Robot/Fire/A"]
var audio_robot_dead = ["Robot/Defeat/A"]

func _ready():
	add_child(LineDrawer)

func _process(delta):
	paused = get_tree().get_nodes_in_group("player")[0].paused
	if not _defeated:
		var a = _player.get_node("Head/Camera").global_transform.origin
			
		var b = $RayCast.global_transform.origin
		var dist_between_robot_and_player = (a - b).length()
		if dist_between_robot_and_player < player_range:
			var height_adjust = a
			height_adjust.y = height_adjust.y - 5

			if debug:
				LineDrawer.DrawLine(height_adjust, b, Color(0, 0, 1), 3)

func _physics_process(delta):
	if not paused:	
		if not _defeated:
			var time_since_dart = OS.get_ticks_msec() - _last_dart
			var a = _player.get_node("Head/Camera").global_transform.origin
			
			var b = $RayCast.global_transform.origin
			var dist_between_robot_and_player = (a - b).length()
			if dist_between_robot_and_player < player_range:
				$RayCast.cast_to = (a - b).rotated(Vector3.UP, -rotation.y)
				var height_adjust = a
				height_adjust.y = height_adjust.y - 5

				if $RayCast.is_colliding() and $RayCast.get_collider().is_in_group("player"):
					if not _interested:
						Audio.play(audio_robot_awake[randi() % audio_robot_awake.size()], translation)
						_interested = true
					var des_dir = PI - (Vector2(a.x, a.z) - Vector2(b.x, b.z)).angle() - rotation.y
					var angle_to_player = des_dir - $robot.rotation.y
					$robot.rotation.y += angle_to_player * delta
				
					if time_since_dart > dart_speed and abs(angle_to_player) < 0.5:
						_last_dart = OS.get_ticks_msec()
						Audio.play(audio_robot_shoot[randi() % audio_robot_shoot.size()], translation)
						var hit = _rng.randi_range(0,1)
						if hit:
							_player.hurt(2, translation)
				else:
					_interested = false
			else:
				_interested = false
				
			if _interested:
				$robot/Light.light_energy = 1
			else:
				$robot/Light.light_energy = 0
				
			if abs(rotation.x) > deg2rad(robot_field_of_view  * 2) or abs(rotation.z) > deg2rad(robot_field_of_view * 2):
				Audio.play(audio_robot_dead[randi() % audio_robot_dead.size()], translation)
				$robot/Light.light_energy = 0
				_defeated = true
			elif abs(rotation.x) > deg2rad(3) or abs(rotation.z) > deg2rad(3):
				$robot/Light.light_energy = int(Engine.get_frames_drawn() % 5 == 0)

func _detect_player():
	var player_location = _player.get_node("Head/Camera").global_transform.origin
	var robot_location = $RayCast.global_transform.origin
	var dist_between_robot_and_player = (player_location - robot_location).length()

