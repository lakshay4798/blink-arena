extends Area2D
@export var next_scene = PackedScene
@export var fade_duration : float = 0.5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _on_body_entered(body: Node2D) -> void:
	if body.name == "player":
		if next_scene:
			fade_and_change_scene()
		else:
			"level not loaded"

func fade_and_change_scene() -> void:
	# 1. Create a persistent canvas layer on root
	var canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 100
	get_tree().root.add_child(canvas_layer)
	
	# 2. Create black screen rect
	var fade_rect = ColorRect.new()
	fade_rect.color = Color(0, 0, 0, 0)
	fade_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	canvas_layer.add_child(fade_rect)
	
	# 3. Fade to black using canvas layer's own tree context
	var tween_out = canvas_layer.create_tween()
	tween_out.tween_property(fade_rect, "color:a", 1.0, fade_duration)
	await tween_out.finished
	
	# 4. Change scene
	get_tree().change_scene_to_packed(next_scene)
	
	# 5. Use the canvas_layer to complete the fade in on the new scene
	var tween_in = canvas_layer.create_tween()
	tween_in.tween_property(fade_rect, "color:a", 0.0, fade_duration)
	await tween_in.finished
	
	# 6. Clean up canvas layer
	canvas_layer.queue_free()
