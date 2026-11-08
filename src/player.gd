class_name Player
extends CharacterBody2D

const SPEED := 260.0

var _touch_pos := Vector2.ZERO
var _touching := false

func _ready() -> void:
	add_to_group("player")
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 16.0
	shape.shape = circle
	add_child(shape)
	var poly := Polygon2D.new()
	var pts := PackedVector2Array()
	for i in range(24):
		var a := TAU * float(i) / 24.0
		pts.append(Vector2(cos(a), sin(a)) * 16.0)
	poly.polygon = pts
	poly.color = Color(0.3, 0.7, 1.0)
	add_child(poly)

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		_touching = event.pressed
		if event.pressed:
			_touch_pos = event.position
	elif event is InputEventScreenDrag:
		_touch_pos = event.position
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		_touching = event.pressed
		if event.pressed:
			_touch_pos = event.position
	elif event is InputEventMouseMotion and _touching:
		_touch_pos = event.position

func _physics_process(_delta: float) -> void:
	var dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if dir == Vector2.ZERO and _touching:
		var to := _touch_pos - global_position
		if to.length() > 8.0:
			dir = to.normalized()
	velocity = dir * SPEED
	move_and_slide()
	position.x = clamp(position.x, 16.0, 784.0)
	position.y = clamp(position.y, 16.0, 584.0)
