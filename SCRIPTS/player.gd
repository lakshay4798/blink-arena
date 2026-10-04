extends CharacterBody2D

@onready var animated = $AnimatedSprite2D
@export var fade_duration: float = 0.5   # Smooth transition time
@onready var canvas_modulate: CanvasModulate = get_node_or_null("../CanvasModulate")
@onready var player_light: PointLight2D = $PointLight2D

# Add near the top of player.gd with your other variables
@export var dark_duration: float = 10.0  
@export var preview_duration: float = 3.0  

@export var dark_color: Color = Color(0.05, 0.05, 0.08, 1.0)   
@export var dim_map_color: Color = Color(0.35, 0.35, 0.45, 1.0) 


const SPEED = 300.0
var last_direction : Vector2 = Vector2.RIGHT
var is_attacking : bool = false


func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("attack") and not is_attacking:
		attack()
	if is_attacking:
		velocity = Vector2.ZERO
		return
	
	process_movement()
	process_animation(last_direction)
	move_and_slide()

func _ready() -> void:
	start_blink_cycle()
	start_blink_loop()

func process_movement() -> void:
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_vector("left" ,"right", "up" , "down")
	
	if direction != Vector2.ZERO:
		velocity = direction * SPEED
		last_direction = direction
	else:
		velocity = Vector2.ZERO
	
func process_animation(direction) ->  void:
	if is_attacking:
		return
	if velocity !=Vector2.ZERO:
		play_animation("run", last_direction)
	else:
		play_animation("idle" , last_direction)
		
func play_animation(prefix: String ,dir : Vector2) -> void:
	if dir.x != 0:
		animated.flip_h = dir.x <0
		animated.play(prefix + "_right")
	elif dir.y < 0:
		animated.play(prefix + "_up")
	elif dir.y > 0:
		animated.play(prefix + "_down")
		
func attack() -> void:
	is_attacking = true
	play_animation("attack" , last_direction)
	print("attack")


func _on_animated_sprite_2d_animation_finished() -> void:
	if is_attacking:
		is_attacking = false

func start_blink_cycle() -> void:
	while true:
		# 1. VISIBLE PHASE: Turn background bright white (normal screen)
		if canvas_modulate:
			var tween_bright = create_tween()
			tween_bright.tween_property(canvas_modulate, "color", Color.WHITE, fade_duration)
		
		# Turn off player spot light during bright screen
		if player_light:
			player_light.enabled = false
			
		await get_tree().create_timer(preview_duration).timeout
		
		# 2. DARK PHASE: Smoothly fade background to dark
		if canvas_modulate:
			var tween_dark = create_tween()
			tween_dark.tween_property(canvas_modulate, "color", Color(0.1, 0.1, 0.15, 1.0), fade_duration)
		
		# Enable small player light so they can navigate
		if player_light:
			player_light.enabled = true
			
		await get_tree().create_timer(dark_duration).timeout

func start_blink_loop() -> void:
	if canvas_modulate:
		canvas_modulate.color = dark_color

	while true:
		# Wait in darkness
		await get_tree().create_timer(dark_duration).timeout
		
		# Fade to dim map vision
		if canvas_modulate:
			var tween_bright = create_tween()
			tween_bright.tween_property(canvas_modulate, "color", dim_map_color, fade_duration)
		
		# Hold dim vision briefly
		await get_tree().create_timer(preview_duration).timeout
		
		# Fade back to dark
		if canvas_modulate:
			var tween_dark = create_tween()
			tween_dark.tween_property(canvas_modulate, "color", dark_color, fade_duration)
