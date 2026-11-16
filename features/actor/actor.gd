class_name Actor
extends Node2D

const TILE_SIZE: int = 16
const TILE_SIZE_VECTOR: Vector2 = Vector2(TILE_SIZE, TILE_SIZE)
@warning_ignore("integer_division")
const HALF_TILE_SIZE: int = TILE_SIZE / 2
const HALF_TILE_SIZE_VECTOR: Vector2 = Vector2(HALF_TILE_SIZE, HALF_TILE_SIZE)

@export var is_player: bool
@export var move_interval := 0.15

var move_cd := 0.0
var _raycast: RayCast2D

@onready var area_2d: Area2D = $Area2D


func try_move(direction: Vector2i) -> bool:
	var result := _do_raycast(direction, 1)
	if result.colliding:
		print("Unable to move in direction ", direction)
		return false

	var newpos: Vector2 = position + direction * float(TILE_SIZE)

	set_position(snap_pos(newpos))
	return true


func snap_pos(newpos: Vector2) -> Vector2:
	var snappedposition: Vector2 = snapped(newpos, TILE_SIZE_VECTOR)
	return snappedposition


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	snap_pos(position)

	_raycast = RayCast2D.new()
	_raycast.set_collision_mask_value(1, true)
	_raycast.hit_from_inside = false
	_raycast.collide_with_areas = true
	_raycast.position = HALF_TILE_SIZE_VECTOR
	_raycast.target_position = Vector2i(0, 0)
	_raycast.enabled = false

	add_child(_raycast)


func _do_raycast(direction: Vector2i, length: int) -> RayCastResult:
	_raycast.target_position = direction * length * TILE_SIZE
	_raycast.force_raycast_update()

	var result = RayCastResult.new()

	if _raycast.is_colliding():
		print("Collide")
		result.colliding = true
		result.collision_point = _raycast.get_collision_point()
		var shape := _raycast.get_collider()
		print(shape)
		if shape is Area2D:
			var actor = shape.get_parent()
			if (actor is Actor):
				result.actor = actor
			else:
				push_error("Unknown collision expected actor")

	return result

func _process(delta: float) -> void:
	move_cd -= delta
	if move_cd <= 0.0 && move():
		move_cd = move_interval

func _get_level() -> LevelGenerator:
	return get_tree().get_first_node_in_group("level") as LevelGenerator

func move() -> bool:
	if (!is_player):
		return _ai_move()
	return _player_move()

func _get_player() -> Actor: 
	for c in get_tree().current_scene.get_children():
		if c is Actor and c.is_player:
			return c
	return null

func _ai_move() -> bool:
	var player = _get_player()
	var level = _get_level()
	if !player or !level:
		return false
	
	var path: Array[Vector2] = level.generate_path_between(global_position, player.global_position)
	if path.size() < 2:
		return false
	
	var delta := path[1] - path[0]
	var dir: Vector2i = Vector2i.ZERO
	if absf(delta.x) > absf(delta.y):
		dir = Vector2i.RIGHT if delta.x > 0 else Vector2i.LEFT
	else:
		dir = Vector2i.DOWN if delta.y > 0 else Vector2i.UP
	if dir != Vector2i.ZERO:
		return try_move(dir)
		
	return false
	
func _player_move() -> bool:
	var dir: Vector2i = Vector2i.ZERO
	if (Input.is_action_pressed("ui_up")):
		dir = Vector2i.UP
	if (Input.is_action_pressed("ui_down")):
		dir = Vector2i.DOWN
	if (Input.is_action_pressed("ui_left")):
		dir = Vector2i.LEFT
	if (Input.is_action_pressed("ui_right")):
		dir = Vector2i.RIGHT
	if dir != Vector2i.ZERO:
		return try_move(dir)
	return false
