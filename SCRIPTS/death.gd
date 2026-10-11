extends Area2D

@onready var death = $AudioStreamPlayer2D2

func _ready() -> void:
	pass 

#func _process(delta: float) -> void:
	#pass

func _on_body_entered(body: Node2D) -> void:
	if body.name == "player":
		death.play()
		await get_tree().create_timer(1.0).timeout
		get_tree().call_deferred("reload_current_scene")
