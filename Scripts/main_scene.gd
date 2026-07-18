extends Node2D

@onready var character = %Character

@onready var dialog_ui = %DialogUI

const dialog_lines: Array[String] = [
	"Phoenix:你好啊",
	"Trucy:你也好"
]
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	process_line(parse_line(dialog_lines[0]))

func parse_line(line: String):
	var line_info = line.split(":")
	assert(len(line_info) >= 2)
	
	return {
		"speaker_name": line_info[0],
		"dialog_line": line_info[1]
	}

func process_line(line_info: Dictionary):
	dialog_ui.speaker_name.text = line_info["speaker_name"]
	dialog_ui.dialog_line.text = line_info["dialog_line"]
	
