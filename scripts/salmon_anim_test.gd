extends Node3D

@onready var skel: Skeleton3D = $Armature/Skeleton3D
@onready var head_idx = skel.find_bone("Head")
@onready var cam = get_viewport().get_camera_3d()
#@onready var world_to_skel = skel.get_bone_pose(head_idx).affine_inverse()

func _ready() -> void:
	# skel.local_pose_override = true
	print("Head:")
	print(skel.get_bone_pose(head_idx))
	print(skel.get_bone_pose(head_idx).basis)
	print(skel.get_bone_global_pose(head_idx).basis)
	print("Tail:")
	print(skel.get_bone_pose(skel.find_bone("Tail")).basis)
	print(skel.get_bone_global_pose(skel.find_bone("Tail")).basis)
	print("Godot Node:")
	print(global_transform.basis)
	print(skel.transform.basis)
	pass


func _process(_delta: float) -> void:
	if Input.is_key_pressed(KEY_SPACE):
		look_head(get_head_dir().slerp(-cam.global_transform.basis.z, 0.05))
	pass
	

func get_head_dir() -> Vector3:
	return global_transform.basis * skel.get_bone_global_pose(head_idx).basis.y


func look_head(dir: Vector3) -> void:
	dir = global_transform.basis.inverse() * dir
	#dir = dir.normalized()
	
	var fwd = Vector3(1.0, 0.0, 0.0)

	# max angle allowed
	var max_angle = deg_to_rad(30)

	var angle = fwd.angle_to(dir)
	if angle > max_angle:
		dir = fwd.slerp(dir, max_angle / angle)

	var y = dir.normalized()
	var x = y.cross(Vector3(0, 1, 0)).normalized()
	if x.length() < 0.0001:
		x = Vector3(1,0,0)

	var z = x.cross(y).normalized()

	var look_basis = Basis(x, y, z)

	skel.set_bone_global_pose(head_idx, Transform3D(look_basis, Vector3.ZERO))
