extends CharacterBody3D

@onready var animated_sprite_3d: AnimatedSprite3D = $AnimatedSprite3D
@export var move_speed = 5.0
@export var attack_range = 2.0

@onready var bark : AudioStreamPlayer3D = $AudioStreamPlayer3D
@onready var player : CharacterBody3D = $"/root/World/Player"
var isDead = false
static var playerDead = false

func _ready():
	playerDead = false

func _physics_process(delta):
	if isDead:
		return
	if playerDead == true:
		set_physics_process(false)
	
	var dir = player.global_position - global_position
	dir.y = 0.0
	dir = dir.normalized()
	
	velocity = dir * move_speed
	move_and_slide()
	attempt_to_kill_player()

func attempt_to_kill_player():
	var dist_to_player = global_position.distance_to(player.global_position)
	if dist_to_player > attack_range:
		return
	
	var eye_line = Vector3.UP * 1.5
	var query = PhysicsRayQueryParameters3D.create(global_position+eye_line, player.global_position+eye_line, 1)
	var result = get_world_3d().direct_space_state.intersect_ray(query)
	if result.is_empty() && isDead == false:
		player.kill()
		playerDead = true
		isDead = true

func kill():
	isDead = true
	bark.play()
	$CollisionShape3D.disabled = true
	hide()
