class_name Coin
extends Area2D

func _ready() -> void:
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 12.0
	shape.shape = circle
	add_child(shape)
	var poly := Polygon2D.new()
	var pts := PackedVector2Array()
	for i in range(24):
		var a := TAU * float(i) / 24.0
		pts.append(Vector2(cos(a), sin(a)) * 12.0)
	poly.polygon = pts
	poly.color = Color(1.0, 0.8, 0.1)
	add_child(poly)
