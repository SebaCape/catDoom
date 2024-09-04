extends CharacterBody3D

@onready var animated_sprite_2d: AnimatedSprite2D = $CanvasLayer/GunBase/AnimatedSprite2D
@onready var shoot_sound: AudioStreamPlayer = $ShootSound
@onready var death_sound: AudioStreamPlayer = $DeathSound
@onready var goal_area: Area3D = $"../Environment/Goal"
@onready var player_area: Area3D = $Area3D

var speed = 9.0
const MOUSE_SENS = .5

@onready var spawnLoc = $Marker3D
@onready var ball = preload("res://scenes/ball.tscn")
var canShoot = true
var isDead = false


func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	animated_sprite_2d.animation_finished.connect(doneShooting)
	#$DeathScreen/Panel/Button.button_up.connect(restart)

func _input(event):
	if isDead:
		return
	if event is InputEventMouseMotion:
		rotation_degrees.y -= event.relative.x * MOUSE_SENS

func _process(delta):
	if Input.is_action_just_pressed("exit"):
		get_tree().quit()
	if Input.is_action_just_pressed("restart"):
		restart()
	
	if goal_area.overlaps_area(player_area):
		win()
	
	if isDead:
		return
	if Input.is_action_just_pressed("shoot"):
		shoot()


func _physics_process(delta):
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("move_right", "move_left", "move_backwards", "move_forwards")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	move_and_slide()

func restart():
	get_tree().reload_current_scene()

func shoot():
	if !canShoot:
		return
	canShoot = false
	animated_sprite_2d.play("shoot")
	shoot_sound.play()
	launch()
	#if ray_cast_3d.is_colliding() and ray_cast_3d.get_collider().has_method("kill"):
	#	ray_cast_3d.get_collider().kill()

func launch():
	var new_ball = ball.instantiate()
	get_node("/root/World").add_child(new_ball)
	new_ball.global_transform = spawnLoc.global_transform

func doneShooting():
	canShoot = true

func win():
	$DeathScreen/Label.set_text("You Win")
	isDead = true
	$DeathScreen.show()
	animated_sprite_2d.hide()
	speed = 0
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func kill():
	isDead = true
	death_sound.play()
	$DeathScreen.show()
	animated_sprite_2d.hide()
	speed = 0
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
