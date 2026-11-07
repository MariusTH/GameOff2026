# Currently just a copy of https://github.com/gdquest-demos/godot-4-procedural-generation/blob/master/godot4/basic_dungeon/01_rectangular/rectangular.gd

extends Node2D

const CLEAR_COLOR := Color("#a0a0a0")

@export var level_size := Vector2i(100, 100)
@export var rooms_size := Vector2i(10, 14)
@export var max_rooms := 15

@onready var level_tile_map_layer: TileMapLayer = $floor
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	RenderingServer.set_default_clear_color(CLEAR_COLOR)
	_generate() # apparently not a good idea if rooms become to big, keep small for now
	pass # Replace with function body.

func _generate() -> void:
	level_tile_map_layer.clear()
	for v in _generate_data():
		level_tile_map_layer.set_cell(v, 0, Vector2i.ZERO, 0)

func _generate_data() -> Array:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	
	var start := Vector2i(rng.randi_range(0, level_size.x), level_size.y)
	var end := Vector2i(rng.randi_range(0, level_size.x), 0)
	
	# Add path kinda drunken between start and end, then follow path, and then select X more to go along.
	# This will give us a path from start to end, and also room size, and in this selected areas 
	# we just "grow" out tumors on the path for cool rooms
	var floor = [start, end]
	return floor


func _get_random_room(rng: RandomNumberGenerator) -> Rect2:
	var rw = rng.randi_range(rooms_size.x, rooms_size.y)
	var rh = rng.randi_range(rooms_size.x, rooms_size.y)
	var x := rng.randi_range(0, level_size.x - rw - 1)
	var y := rng.randi_range(0, level_size.y - rh - 1)
	return Rect2(x,y, rw, rh)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
