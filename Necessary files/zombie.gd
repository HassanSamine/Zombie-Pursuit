extends CharacterBody2D

@onready var ray_cast_2d = $RayCast2D

@export var move_speed = 100
@export var chase_distance = 200  # Adjust the default chase distance
@export var start_chase_distance = 400  # Adjust how close the player needs to be before zombie starts chasing
@onready var player : CharacterBody2D = get_tree().get_first_node_in_group("player")

var dead = false
var should_chase = false

func _physics_process(delta):
	if dead:
		return
	
	# Calculate distance to the player
	var distance_to_player = global_position.distance_to(player.global_position)
	
	# Check if player is within the start_chase_distance
	if distance_to_player <= start_chase_distance:
		should_chase = true

	# If should_chase is true, start chasing the player
	if should_chase:
		var dir_to_player = global_position.direction_to(player.global_position)
		velocity = dir_to_player * move_speed
		move_and_slide()

		global_rotation = dir_to_player.angle() + PI/2.0

		# Check if player is within the chase distance and kill if collided
		if distance_to_player <= chase_distance:
			if ray_cast_2d.is_colliding() and ray_cast_2d.get_collider() == player:
				player.kill()

func kill():
	if dead:
		return
	dead = true
	$DeathSound.play()
	$Graphics/Dead.show()
	$Graphics/Alive.hide()
	$CollisionShape2D.disabled = true
	z_index = -1
