extends Node3D

@export var sens := 0.005

var rot_x := 0.0
var rot_y := 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta: float) -> void:
	global_transform.origin = $"../Salmon".global_transform.origin

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rot_y -= event.relative.x * sens
		rot_x -= event.relative.y * sens
		rot_x = clamp(rot_x, deg_to_rad(-89), deg_to_rad(89))

		rotation = Vector3(rot_x, rot_y, 0)
