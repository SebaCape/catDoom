extends Area3D

@onready var raycast_3d: RayCast3D = $RayCast3D
@export var ball_speed = 25

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	translate(Vector3.BACK * ball_speed * delta)
	if raycast_3d.is_colliding():
		if raycast_3d.get_collider().has_method("kill"):
			raycast_3d.get_collider().kill()
		queue_free()
