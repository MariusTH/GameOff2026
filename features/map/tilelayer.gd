# Currently just a copy of https://github.com/gdquest-demos/godot-4-procedural-generation/blob/master/godot4/basic_dungeon/01_rectangular/rectangular.gd
class_name LevelGenerator
extends Node2D

const CLEAR_COLOR := Color("#a0a0a0")

@export var level_size := Vector2i(150, 150)
@export var rooms_size := Vector2i(10, 14)
@export var max_rooms := 5
@export var enemy_scene: PackedScene

@onready var player:Node2D = $"../Actor"
@onready var camera:Camera2D = $"../Camera2D"
@onready var level_tile_map_layer: TileMapLayer = $floor

var rooms: Array[Rect2i] = []
var astar := AStarGrid2D.new()

func _ready() -> void:
	add_to_group("level")
	RenderingServer.set_default_clear_color(CLEAR_COLOR)
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	
	var start := Vector2i(rng.randi_range(-5, 5) + (level_size.x / 2), level_size.y)
	_generate(start, rng) # apparently not a good idea if rooms become to big, keep small for now
	player.global_position = Vector2(start.x * 16, start.y * 16)
	camera.set_target(player)
	
	# spawn
	for i in rooms.size():
		for j in range(i + 1):
			var spawn_point = return_spawn_point_in_room(i)
			var enemy := enemy_scene.instantiate()
			enemy.global_position = Vector2(spawn_point.x * 16, spawn_point.y * 16)
			get_tree().current_scene.add_child.call_deferred(enemy)
		

func _generate(start: Vector2i, rng: RandomNumberGenerator) -> void:
	level_tile_map_layer.clear()
	var cells := _generate_data(start, rng)
	level_tile_map_layer.set_cells_terrain_connect(cells, 0, 0)
	_generate_astar(cells)

func _generate_data(start: Vector2i, rng: RandomNumberGenerator) -> Array[Vector2i]:
	
	var grid = {}
	
	grid[start] = 1;
	var last = start
	# This gives us the path
	while last.y != 0:
		# valid directions
		var valid_dirs = []
		if last.x - 1 >= 0:
			valid_dirs.push_back(Vector2i(last.x - 1, last.y))
		if last.x + 1 < level_size.x:
			valid_dirs.push_back(Vector2i(last.x + 1, last.y))
		if last.y - 1 >= 0:
			valid_dirs.push_back(Vector2i(last.x, last.y - 1))
		last = valid_dirs[rng.randi_range(0,valid_dirs.size() - 1)]
		grid[last] = 1
	
	# Generate some rooms
	var base_path = grid.keys()
	var dist = base_path.size() / max_rooms
	for i in max_rooms - 1:
		var traversal = rng.randi_range(1,4)
		var halfway_point = ((dist - traversal) / 2) + dist * i
		var p = base_path[halfway_point]
		var room_area = Rect2i(p, Vector2i(rng.randi_range(4, (dist - traversal) / 2), rng.randi_range(4, (dist - traversal) / 2)))
		var rendered_room := Rect2i(room_area.position - room_area.size / 2, room_area.size)
		rooms.push_back(rendered_room)
		for xra in range(rendered_room.size.x):
			for yra in range(rendered_room.size.y):
				grid[rendered_room.position + Vector2i(xra, yra)] = 1
	for p in base_path:
		for i in range(5):
			for j in range(5):
				grid[Vector2i(p.x + i - 1, p.y + j - 1)] = 1
	var cells: Array[Vector2i] = []
	cells.assign(grid.keys())
	return cells

func _generate_astar(cells: Array[Vector2i]) -> void:
	var bounds = Rect2i(cells[0], Vector2i.ONE)
	for c in cells:
		bounds = bounds.expand(c)
	bounds.size += Vector2i.ONE
	
	astar.region = bounds
	astar.cell_size = Vector2(16,16)
	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar.update()
	astar.fill_solid_region(bounds)
	for c in cells:
		astar.set_point_solid(c, false)
	
func generate_path_between(from_global: Vector2, to_global: Vector2) -> Array[Vector2]:
	var from := level_tile_map_layer.local_to_map(level_tile_map_layer.to_local(from_global))
	var to := level_tile_map_layer.local_to_map(level_tile_map_layer.to_local(to_global))
	
	if not astar.is_in_boundsv(from) or not astar.is_in_boundsv(to):
		return []
	
	var result: Array[Vector2] = []
	for cell in astar.get_id_path(from, to):
		result.append(level_tile_map_layer.to_global(level_tile_map_layer.map_to_local(cell)))
	return result
	
	
func return_spawn_point_in_room(room: int) -> Vector2i:
	if room >= 0 && room < rooms.size():
		var r = rooms[room]
		var rng = RandomNumberGenerator.new()
		var x = rng.randi_range(r.position.x, r.position.x + r.size.x - 1)
		var y = rng.randi_range(r.position.y, r.position.y + r.size.y - 1)
		return Vector2i(x,y)
	return Vector2i(0,0)

func _get_area_vecs() -> Array[Vector2i]:
	return []
func _get_random_room(rng: RandomNumberGenerator) -> Rect2:
	var rw = rng.randi_range(rooms_size.x, rooms_size.y)
	var rh = rng.randi_range(rooms_size.x, rooms_size.y)
	var x := rng.randi_range(0, level_size.x - rw - 1)
	var y := rng.randi_range(0, level_size.y - rh - 1)
	return Rect2(x,y, rw, rh)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
