extends Node2D

@onready var animated_sprite = %AnimatedSprite2D

const CHARACTER_FARAMES = {
	"Phoenix": preload("res://Resources/phoenix-sprites.tres"),
	"Trucy": preload("res://Resources/trucy-sprites.tres")
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func change_character(character_name: String, is_talking: bool = true):
	if character_name == "Apollo":
		animated_sprite.play("idle")
	else:
		animated_sprite.sprite_frames = CHARACTER_FARAMES[character_name]
		if is_talking:
			animated_sprite.play("talking")
		else:
			animated_sprite.play("idle")
