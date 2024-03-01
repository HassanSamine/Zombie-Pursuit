extends CharacterBody2D

@onready var ray_cast_2d = $RayCast2D
@export var move_speed = 200
var dead = false
var has_won = false

func _process(delta):
	if Input.is_action_just_pressed("exit"):
		get_tree().quit()
	if Input.is_action_just_pressed("restart"):
		restart()
	if dead:
		return
	
	global_rotation = global_position.direction_to(get_global_mouse_position()).angle() + PI/2.0
	if Input.is_action_just_pressed("shoot"):
		shoot()

func _physics_process(delta):
	if dead or has_won:  # Stop player movement if dead or has won
		return
	
	var move_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = move_dir * move_speed
	move_and_slide()

	# Check for win condition
	if is_at_win_point():
		win()

func is_at_win_point() -> bool:
	# You need to define the conditions for the win point
	# For example, you can check if the player's global position is within a certain range of the win point
	var win_point_position = Vector2(547, -882)  # Example win point position
	var distance_to_win_point = global_position.distance_to(win_point_position)
	return distance_to_win_point < 50  # Adjust the threshold as needed

func win():
	has_won = true
	$CanvasLayer/VictoryScreen.show()

func kill():
	if dead or has_won:  # Prevent killing if already dead or has won
		return
	dead = true
	$DeathSound.play()
	$Graphics/Dead.show()
	$Graphics/Alive.hide()
	$CanvasLayer/DeathScreen.show()
	z_index = -1

func restart():
	get_tree().reload_current_scene()

func shoot():
	$MuzzleFlash.show()
	$MuzzleFlash/Timer.start()
	$ShootSound.play()
	if ray_cast_2d.is_colliding() and ray_cast_2d.get_collider().has_method("kill"):
		ray_cast_2d.get_collider().kill()
