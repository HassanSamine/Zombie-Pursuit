extends Node2D

var grid_step := 1.0
var points := {}
var astar = AStar2D.new()
var grid_y := 0.5

func _ready() -> void:
	var pathables = get_tree().get_nodes_in_group("pathable")
	_add_points(pathables)
	_connect_points()

func _add_points(pathables: Array) -> void:
	for pathable in pathables:
		if pathable is Sprite2D:
			var sprite = pathable as Sprite2D
			var texture_size: Vector2 = sprite.texture.get_size()
			var start_point = sprite.global_position
			var x_steps = int(texture_size.x / grid_step)
			var y_steps = int(texture_size.y / grid_step)
			for x in range(x_steps):
				for y in range(y_steps):
					var next_point = start_point + Vector2(x * grid_step, y * grid_step)
					_add_point(next_point)

func _add_point(point: Vector2) -> void:
	point.y = grid_y
	var id = astar.get_available_point_id()
	astar.add_point(id, point)
	points[world_to_astar(point)] = id

func world_to_astar(world_point: Vector2) -> String:
	var x = int(snapped(world_point.x, grid_step))
	var y = int(snapped(world_point.y, grid_step))
	return "%d,%d" % [x, y]

func _connect_points() -> void:
	for point in points:
		var pos_str = point.split(",")
		var world_pos = Vector2(int(pos_str[0]), int(pos_str[1]))
		var search_coords = [-grid_step, 0, grid_step]
		for x in search_coords:
			for y in search_coords:
				var search_offset = Vector2(x, y)
				if search_offset == Vector2.ZERO:
					continue
				var potential_neighbor = world_to_astar(world_pos + search_offset)
				if points.has(potential_neighbor):
					var current_id = points[point]
					var neighbour_id = points[potential_neighbor]
					astar.connect_points(current_id, neighbour_id)
					if not astar.are_points_connected(current_id, neighbour_id):
						astar.connect_points(current_id, neighbour_id)

func direction_to(from: Vector2, to: Vector2) -> Array:
	var start_id = astar.get_closest_point(from)
	var end_id = astar.get_closest_point(to)
	return astar.get_point_path(start_id, end_id)
