class_name Game
extends Node2D

const ACTOR = preload("uid://dsnrnk7yb71ik")

@onready var tilelayer: LevelGenerator = $Tilelayer
@onready var actor_layer: Node2D = %ActorLayer
@onready var camera_2d: Camera2D = %Camera2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var player := _spawn_actor(tilelayer.player_start)
	player.is_player = true
	camera_2d.target = player

	_spawn_enemies()


func _spawn_enemies() -> void:
	for i in tilelayer.rooms.size():
		for j in range(i + 1):
			var spawn_point = tilelayer.return_spawn_point_in_room(i)
			_spawn_actor(spawn_point)


func _spawn_actor(p: Vector2i) -> Actor:
	var actor: Actor = ACTOR.instantiate()
	actor.set_grid_pos(p)
	actor_layer.add_child(actor)
	return actor
