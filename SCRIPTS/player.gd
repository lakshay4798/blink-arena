extends CharacterBody2D

@onready var animated = $AnimatedSprite2D
@export var fade_duration: float = 0.5   
@onready var canvas_modulate: CanvasModulate = get_node_or_null("../CanvasModulate")
@onready var player_light: PointLight2D = $PointLight2D
@onready var exit = $"."
@export var dark_duration: float = 10.0  
@export var preview_duration: float = 2.0  
#@onready var level4 = $"../BG2"
@export var dark_color: Color = Color(0.05, 0.05, 0.08, 1.0)   
@export var dim_map_color: Color = Color(0.35, 0.35, 0.45, 1.0) 
@onready var hitbox = $hitbox


@export var max_hits := 3
@export var invincible_time := 1.0

var hits := 0
var invincible := false
signal hit(hits_left: int)
signal died

const SPEED = 300.0
var health : int = 3
var is_invulnerable : bool = false	
var last_direction : Vector2 = Vector2.RIGHT
var is_attacking : bool = false
var hitbox_offset : Vector2
var strength : int = 100

func _ready() -> void:
	start_blink_cycle()
	hitbox.monitoring = false
	hitbox_offset = hitbox.position
	add_to_group("player")

#for blast all slime at once
#func _input(event: InputEvent) -> void:
	#if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_T:
		#trigger_random_slime_blasts()
#
#func trigger_random_slime_blasts() -> void:
	## Get all nodes in the "slimes" group
	#var all_slimes = get_tree().get_nodes_in_group("slimes")
	#
	#if all_slimes.is_empty():
		#return
		#
	## Randomize their order
	#all_slimes.shuffle()
	#
	## Pick up to 4 slimes to blast
	#var count = min(4, all_slimes.size())
	#for i in range(count):
		#var slime = all_slimes[i]
		#if slime.has_method("blast"):
			#slime.blast()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_echo(): return
	if event is InputEventKey and event.pressed and event.keycode == KEY_E:
		var exit_menu = load("res://TSCN/exitpoint.tscn").instantiate()
		get_tree().root.add_child(exit_menu)


func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("attack") and not is_attacking:
		attack()
		
	if is_attacking:
		velocity = Vector2.ZERO
		return

	process_movement()
	process_animation(last_direction)
	move_and_slide()
	#if "level_4" in get_tree().current_scene.name.to_lower():
		#if Input.is_key_pressed(KEY_E):
			#level4.clear()
		#else:
			#level4.

func take_hit() -> void:
	if invincible:
		return
	hits += 1
	hit.emit(max_hits - hits)
	if hits >= max_hits:
		die()
		return
	invincible = true
	var tw := create_tween().set_loops(int(invincible_time / 0.2))
	tw.tween_property($Sprite2D, "modulate:a", 0.3, 0.1)
	tw.tween_property($Sprite2D, "modulate:a", 1.0, 0.1)
	await get_tree().create_timer(invincible_time).timeout
	invincible = false
	$Sprite2D.modulate.a = 1.0

func die() -> void:
	died.emit()
	set_physics_process(false)
	await get_tree().create_timer(0.5).timeout
	get_tree().reload_current_scene()
	
	#-------------------------------------
func process_movement() -> void:
	var direction := Input.get_vector("left", "right", "up", "down")
	
	if direction != Vector2.ZERO:
		velocity = direction * SPEED
		last_direction = direction
		update_hitbox_offset()
	else:
		velocity = Vector2.ZERO
	
func process_animation(direction) -> void:
	if is_attacking:
		return
	if velocity != Vector2.ZERO:
		play_animation("run", last_direction)
	else:
		play_animation("idle", last_direction)

func play_animation(prefix: String, dir: Vector2) -> void:
	if dir.x != 0:
		animated.flip_h = dir.x < 0
		animated.play(prefix + "_right")
	elif dir.y < 0:
		animated.play(prefix + "_up")
	elif dir.y > 0:
		animated.play(prefix + "_down")

func attack() -> void:
	is_attacking = true
	hitbox.monitoring = true
	play_animation("attack", last_direction)
	
	# Wait one frame for physics engine to update overlapping shapes
	await get_tree().process_frame
	
	# Instant check for overlapping bodies
	for body in hitbox.get_overlapping_bodies():
		if body.has_method("take_damage"):
			body.take_damage(strength)

func _on_animated_sprite_2d_animation_finished() -> void:
	if is_attacking:
		is_attacking = false
		hitbox.monitoring = false

func update_hitbox_offset() -> void:
	var x := hitbox_offset.x
	var y := hitbox_offset.y
	
	match last_direction:
		Vector2.LEFT:
			hitbox.position = Vector2(-x, y)
		Vector2.RIGHT:
			hitbox.position = Vector2(x, y)
		Vector2.UP:
			hitbox.position = Vector2(y, -x)
		Vector2.DOWN:
			hitbox.position = Vector2(-y, x)

func _on_hitbox_body_entered(body: Node2D) -> void:
	if is_attacking and body.has_method("take_damage"):
		body.take_damage(strength)

func _on_hitbox_area_entered(area: Area2D) -> void:
	if is_attacking:
		if area.has_method("take_damage"):
			area.take_damage(strength)
		elif area.get_parent().has_method("take_damage"):
			area.get_parent().take_damage(strength)

func start_blink_cycle() -> void:
	while true:
		if canvas_modulate:
			var tween_bright = create_tween()
			tween_bright.tween_property(canvas_modulate, "color", Color.WHITE, fade_duration)
		
		if player_light:
			player_light.enabled = false
			
		await get_tree().create_timer(preview_duration).timeout
		
		if canvas_modulate:
			var tween_dark = create_tween()
			tween_dark.tween_property(canvas_modulate, "color", Color(0.1, 0.1, 0.15, 1.0), fade_duration)
		
		if player_light:
			player_light.enabled = true
			
		await get_tree().create_timer(dark_duration).timeout
