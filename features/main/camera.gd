extends Camera2D

const ZOOM_LEVELS := [0.25, 0.50, 0.75, 1.0, 1.25, 1.5, 1.75, 2, 2.5, 3, 5]
const DEFAULT_ZOOM_INDEX := 3

const pan_speed := 300.0

var target: Node2D
## Both zoom and free_look are stuff added so i can zoom out and look at the proc gen lvl
var zoom_index := DEFAULT_ZOOM_INDEX
var free_look := false

func set_target(new_target: Node2D) -> void:
	target = new_target
	free_look = false
	if target:
		global_position = target.global_position
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_zoom()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if free_look:
		var dir := Input.get_vector("ui_up", "ui_down", "ui_left", "ui_right")
		global_position += dir * pan_speed * delta / zoom.x
	else:
		global_position = target.global_position

func _zoom():
	zoom = Vector2i.ONE * ZOOM_LEVELS[zoom_index]

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey:
		match event.keycode:
			KEY_PLUS:
				zoom_index = clampi(zoom_index + 1, 0, ZOOM_LEVELS.size() - 1)
			KEY_MINUS:
				zoom_index = clampi(zoom_index - 1, 0, ZOOM_LEVELS.size() - 1)
			KEY_TAB:
				free_look != free_look
		_zoom()
