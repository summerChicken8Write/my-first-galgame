# 主场景控制节点。
# 负责保存当前对话进度、接收“下一句”输入，并把角色数据分发给对话框和角色立绘。
extends Node2D

@onready var background = %Background

# 角色立绘节点，用于根据当前说话者切换人物外观和动画。
@onready var character_sprite = %CharacterSprite

# 对话框 UI 节点，用于显示说话者姓名和当前对话文本。
@onready var dialog_ui = %DialogUI

# 玩家切换到下一句时播放的音效。
@onready var next_sentence_sound = %NextSentenceSound

# 当前正在显示的对话在 dialog_lines 中的索引。
var dialog_index = 0

# 剧情对话列表。
# 每条字符串都必须符合 "角色名:对话内容" 的格式，角色名会通过 Character.get_enum_from_string 转成枚举。
var dialog_lines: Array = []

# Godot 生命周期函数：节点进入场景树后自动调用。
# 这里连接文字动画完成信号，初始化对话索引，并立即显示第一条对话。
func _ready() -> void:
	dialog_lines = load_dialog("res://Resources/Story/secend_scene.json")
	
	dialog_ui.text_animation_done.connect(_on_text_animation_done)
	dialog_ui.choice_selected.connect(_on_choice_selected)
	# 每次进入场景都从第一条对话开始，避免复用节点时保留旧进度。
	dialog_index = 0
	# 根据初始化后的索引显示第一条对话。
	process_current_line()

# Godot 输入回调：处理玩家推进对话或跳过当前文字动画的请求。
func _input(event: InputEvent) -> void:
	if dialog_index >= dialog_lines.size() or dialog_index < 0:
		printerr("Error: dialog_index错误", dialog_index)
		return
	
	var line = dialog_lines[dialog_index]
	
	if line.has("next_scene"):
		return
		
	var has_choice = line.has("choices")
	# "next_line" 是 project.godot 中定义的输入动作，通常绑定到鼠标左键、空格或回车。
	if event.is_action_pressed("next_line") and not has_choice:
		# 如果文字还在逐字显示，第一次按键只负责立刻显示完整文本。
		if dialog_ui.animate_flag:
			dialog_ui.skip_text_animation()
		else:
			# 当前文本已经完整显示时，才可以继续推进到下一句。
			# 最后一条对话之后不再继续增加索引，避免数组越界。
			if dialog_index < len(dialog_lines) - 1:
				# 切换到下一条对话，并播放翻页音效。
				dialog_index += 1
				next_sentence_sound.play()
				# 解析并显示新的对话内容与角色立绘。
				process_current_line()

# 解析并显示当前索引对应的对话。
# 该函数会同时更新对话框内容和角色立绘，使说话者、姓名与台词保持一致。
func process_current_line():
	# 取出当前索引对应的原始对话字符串。
	var line = dialog_lines[dialog_index]
	
	if line.has("location"):
		var background_file = "res://Assets/images/" + line["location"] + ".png"
		background.texture = load(background_file)
		dialog_index += 1
		process_current_line()
		return
	
	if line.has("goto"):
		dialog_index = get_anchor_position(line["goto"])
		process_current_line()
		return
	
	if line.has("anchor"):
		dialog_index += 1
		process_current_line()
		return
		
	if line.has("show_character"):
		var character_name = Character.get_enum_from_string(line["show_character"])
		character_sprite.change_character(character_name, false, line.get("expression", ""))
	elif line.has("speaker"):
		var character_name = Character.get_enum_from_string(line["speaker"])
		character_sprite.change_character(character_name, true, line.get("expression", ""))
		
	if line.has("choices"):
		dialog_ui.display_choices(line["choices"])
	elif line.has("text"):
		# 将字符串形式的角色名转换成 Character.Name 枚举，供后续类型化函数使用。
		var speaker_name = Character.get_enum_from_string(line["speaker"])
		# 更新对话框中的姓名、台词，并启动逐字显示动画。
		dialog_ui.change_line(speaker_name, line["text"])
	else:
		dialog_index += 1
		process_current_line()
		return

func get_anchor_position(anchor: String):
	for i in range(dialog_lines.size()):
		if dialog_lines[i].has("anchor") and dialog_lines[i]["anchor"] == anchor:
			return i
	
	printerr("Error: 未找到索引", anchor)
	
	return null

func load_dialog(file_path: String):
	if not FileAccess.file_exists(file_path):
		printerr("Error: 文件未找到，", file_path)
		return null
		
	var file = FileAccess.open(file_path, FileAccess.READ)
	
	if file == null:
		printerr("Error: 文件打开失败，", file_path)
		return null

	var content = file.get_as_text() 
	
	var json_content = JSON.parse_string(content)
	
	if json_content == null:
		printerr("Error: JSON解析失败，", file_path)
		return null  
	
	return json_content

# DialogUI 的文字动画播完后触发。
# 此时让当前角色停止说话动画，恢复到待机动画，表示这句话已经显示完毕。
func _on_text_animation_done():
	character_sprite.play_idle_animation()
	
func _on_choice_selected(anchor: String):
	dialog_index = get_anchor_position(anchor)
	process_current_line()
	next_sentence_sound.play()
