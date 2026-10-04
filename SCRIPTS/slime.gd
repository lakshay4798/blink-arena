#extends CharacterBody2D
#
#@onready var animation = $AnimatedSprite2D
#
#const SPEED = 200.0
#var target = null
#var health :int = 100
#
#func _physics_process(delta: float) -> void:
	#if target:
		#_attack(delta)
#
#func take_damage(damage : int) -> void:
	#health -= damage
	#print(health)
#
#func _attack(delta: float) -> void:
	#var direction = (target.position - position).normalized()
	#position += direction *SPEED * delta
	#animation.play("attack")
#
#func _on_sight_body_entered(body: Node2D) -> void:
	#if body.name == "player":
		##print("player detected")
		#target = body
#
#
#func _on_sight_body_exited(body: Node2D) -> void:
	#if body.name == "player":
		##print("player out")
		#target = null


extends CharacterBody2D

@onready var animation = $AnimatedSprite2D

const SPEED = 200.0
var target = null
var health :int = 100
var is_dead :bool = false

func _physics_process(delta: float) -> void:
	if is_dead:
		return
		
	if target:
		_attack(delta)

func take_damage(damage : int) -> void:
	if is_dead:
		return
		
	health -= damage
	print("Slime HP: ", health)
	
	if health <= 0:
		die()

func die() -> void:
	is_dead = true
	target = null
	
	set_physics_process(false)
	var collision = get_node_or_null("CollisionShape2D")
	if collision:
		collision.set_deferred("disabled", true)
	
	animation.play("die")
	await animation.animation_finished
	
	var tween = create_tween()
	tween.tween_property(animation, "modulate:a", 0.0, 0.5)
	await tween.finished
	
	queue_free()

func _attack(delta: float) -> void:
	var direction = (target.position - position).normalized()
	position += direction * SPEED * delta
	animation.play("attack")

func _on_sight_body_entered(body: Node2D) -> void:
	if body.name == "player":
		target = body

func _on_sight_body_exited(body: Node2D) -> void:
	if body.name == "player":
		target = null
