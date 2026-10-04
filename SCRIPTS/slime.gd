extends CharacterBody2D

@onready var animation = $AnimatedSprite2D

const SPEED = 200.0
var target = null
var health :int = 100

func _physics_process(delta: float) -> void:
	if target:
		_attack(delta)

func take_damage(damage : int) -> void:
	health -= damage
	print(health)

func _attack(delta: float) -> void:
	var direction = (target.position - position).normalized()
	position += direction *SPEED * delta
	animation.play("attack")

func _on_sight_body_entered(body: Node2D) -> void:
	if body.name == "player":
		#print("player detected")
		target = body


func _on_sight_body_exited(body: Node2D) -> void:
	if body.name == "player":
		#print("player out")
		target = null
