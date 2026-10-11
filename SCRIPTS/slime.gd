extends CharacterBody2D

@onready var animation = $AnimatedSprite2D
@onready var hitbox: Area2D = get_node_or_null("Hitbox") as Area2D
@onready var slime_body =$AnimatedSprite2D

const SPEED = 200.0
var target = null
var health :int = 100
var is_dead :bool = false

func _ready() -> void:
	if hitbox == null:
		#push_warning("Slime: add an Area2D child named 'Hitbox' (with a CollisionShape2D).")
		pass

func _physics_process(delta: float) -> void:
	if is_dead:
		return

	if target:
		_attack(delta)

	if hitbox:
		for body in hitbox.get_overlapping_bodies():
			if body.is_in_group("player") and body.has_method("take_hit"):
				body.take_hit()

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
	if hitbox:
		hitbox.set_deferred("monitoring", false)   # dead slime can't hurt you

	animation.play("die")
	await get_tree().create_timer(1.5).timeout
	slime_body.global_position = Vector2(1000,1020)
	#await animation.animation_finished
	

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

#func _physics_process(_delta: float) -> void:
	#for body in $Hitbox.get_overlapping_bodies():
		#if body.is_in_group("player"):
			#body.take_hit()
