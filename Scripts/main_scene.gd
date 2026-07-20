extends Node2D

@onready var character = %Character

@onready var dialog_ui = %DialogUI

var dialog_index = 0

const dialog_lines: Array[String] = [
	"Phoenix:你好啊",
	"Trucy:你也好",
	"Apollo:你俩谁啊",
	"Phoenix:你要去哪啊",
	"Trucy:管的着么",
	"Apollo:你俩有没有听我说话",
	"Phoenix:你这个人怎么这样",
	"Trucy:怎么？你不服气？"
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	dialog_index = 0
	process_current_line()
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("next_line"):
		if dialog_index < len(dialog_lines) - 1:
			dialog_index += 1
			process_current_line()

func parse_line(line: String):
	var line_info = line.split(":")
	assert(len(line_info) >= 2)
	
	return {
		"speaker_name": line_info[0],
		"dialog_line": line_info[1]
	}

func process_current_line():
	var line = dialog_lines[dialog_index]
	var line_info = parse_line(line)
	dialog_ui.speaker_name.text = line_info["speaker_name"]
	dialog_ui.dialog_line.text = line_info["dialog_line"]
	character.change_character(line_info["speaker_name"])
