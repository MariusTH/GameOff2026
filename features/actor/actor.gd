class_name Actor
extends Node2D

const TILE_SIZE: int = 16
const TILE_SIZE_VECTOR: Vector2 = Vector2(TILE_SIZE, TILE_SIZE)
@warning_ignore("integer_division")
const HALF_TILE_SIZE: int = TILE_SIZE / 2
const HALF_TILE_SIZE_VECTOR: Vector2 = Vector2(HALF_TILE_SIZE, HALF_TILE_SIZE)

@export var is_player: bool

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
		if shape is Area2D:
			var actor = shape.get_parent()
			if (actor is Actor):
				result.actor = actor
			else:
				push_error("Unknown collision expected actor")

	return result


func _unhandled_key_input(event: InputEvent) -> void:
	if (!is_player):
		return
	if (event.is_action_pressed("ui_up")):
		try_move(Vector2i.UP)
	if (event.is_action_pressed("ui_down")):
		try_move(Vector2i.DOWN)
	if (event.is_action_pressed("ui_left")):
		try_move(Vector2i.LEFT)
	if (event.is_action_pressed("ui_right")):
		try_move(Vector2i.RIGHT)
