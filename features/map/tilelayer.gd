# Currently just a copy of https://github.com/gdquest-demos/godot-4-procedural-generation/blob/master/godot4/basic_dungeon/01_rectangular/rectangular.gd

extends Node2D

const CLEAR_COLOR := Color("#a0a0a0")

@export var level_size := Vector2i(150, 150)
@export var rooms_size := Vector2i(10, 14)
@export var max_rooms := 5

@onready var player:Node2D = $"../Actor"
@onready var camera:Camera2D = $"../Camera2D"
@onready var level_tile_map_layer: TileMapLayer = $floor
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	RenderingServer.set_default_clear_color(CLEAR_COLOR)
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	
	var start := Vector2i(rng.randi_range(-5, 5) + (level_size.x / 2), level_size.y)
	_generate(start, rng) # apparently not a good idea if rooms become to big, keep small for now
	player.global_position = Vector2(start.x * 16, start.y * 16)
	camera.add_child(player)
	camera.set_target(player)
	

func _generate(start: Vector2i, rng: RandomNumberGenerator) -> void:
	level_tile_map_layer.clear()
	var cells := _generate_data(start, rng)
	level_tile_map_layer.set_cells_terrain_connect(cells, 0, 0)

func _generate_data(start: Vector2i, rng: RandomNumberGenerator) -> Array[Vector2i]:
	
	var grid = {}
	
	grid[start] = 1;
	var row = level_size.y;
	var last = start
	# This gives us the path
	while row != 0:
		var dir = rng.randi_range(0,2) - 1
		if dir + last.x < 0 || dir + last.x > level_size.x:
			dir = 0
		if grid.get(Vector2i(last.x + dir, row)):
			dir = 0
		if dir == 0:
			row = row - 1
		last = Vector2i(last.x + dir, row)
		grid[last] = 1
	
	# Generate some rooms
	var base_path = grid.keys()
	var dist = base_path.size() / max_rooms
	for i in max_rooms - 1:
		var traversal = rng.randi_range(1,4)
		var halfway_point = ((dist - traversal) / 2) * max_rooms
		var p = base_path[halfway_point]
		var room_area = Rect2i(p, Vector2i(rng.randi_range(4, (dist - traversal) / 2), rng.randi_range(4, (dist - traversal) / 2)))
		for xra in range(room_area.size.x):
			for yra in range(room_area.size.y):
				grid[Vector2i(xra + room_area.position.x - (room_area.size.x / 2), yra + room_area.position.y - (room_area.size.y / 2) )] = 1
	for p in base_path:
		for i in range(3):
			for j in range(3):
				grid[Vector2i(p.x + i - 1, p.y + j - 1)] = 1
	var cells: Array[Vector2i] = []
	cells.assign(grid.keys())
	return cells

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
