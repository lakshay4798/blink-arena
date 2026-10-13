extends Control
@onready var click = $click
@onready var start_button = $STARTBUTTON
@onready var quit_button = $QUITBUTTON
# Called when the node enters the scene tree for the first time.

func _ready() -> void:
	start_button.add_theme_color_override("font_hover_color", Color(0, 0, 0))
	quit_button.add_theme_color_override("font_hover_color", Color(0,0,0))

	var hover_style = StyleBoxFlat.new()
	hover_style.bg_color = Color(1, 1, 1) 
	hover_style.set_corner_radius_all(4) 
	start_button.add_theme_stylebox_override("hover", hover_style)
	
func _on_startbutton_pressed() -> void:
	#if button.is_hovered():
		#button.add_theme_color_override("font_color")
	click.play()
	await get_tree().create_timer(0.25).timeout
	get_tree().change_scene_to_file("res://TSCN/main.tscn")
