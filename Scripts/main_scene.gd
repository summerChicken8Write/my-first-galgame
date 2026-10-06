# 主场景控制节点。
# 负责保存当前对话进度、接收“下一句”输入，并把角色数据分发给对话框和角色立绘。
extends Node2D

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
const dialog_lines: Array[String] = [
	# 第 0 条：Phoenix 向玩家打招呼。
	"Phoenix:你好啊！",
	# 第 1 条：Trucy 回应问候。
	"Trucy:你也好！",
	# 第 2 条：Apollo 对突然出现的两人感到困惑。
	"Apollo:你俩谁啊？ 我认识你们吗？",
	# 第 3 条：Phoenix 注意到 Apollo 准备离开。
	"Phoenix:等等， 你要去哪啊？",
	# 第 4 条：Trucy 用略带挑衅的语气回应。
	"Trucy:管的着么！",
	# 第 5 条：Apollo 因为被无视而提高语气。
	"Apollo:你俩有没有听我说话！",
	# 第 6 条：Phoenix 吐槽 Apollo 的态度。
	"Phoenix:你这个人怎么这样！",
	# 第 7 条：Trucy 继续反击。
	"Trucy:怎么？ 你不服气？",
	# 第 8 条：Apollo 的收尾长句。
	"Apollo:都让开， 我要开始说一大段废话辣， 你们快跑啊， 不然就跑不了辣， 哈哈， 污染你们的耳朵！"
]

# Godot 生命周期函数：节点进入场景树后自动调用。
# 这里连接文字动画完成信号，初始化对话索引，并立即显示第一条对话。
func _ready() -> void:
	dialog_ui.text_animation_done.connect(_on_text_animation_done)
	# 每次进入场景都从第一条对话开始，避免复用节点时保留旧进度。
	dialog_index = 0
	# 根据初始化后的索引显示第一条对话。
	process_current_line()

# Godot 输入回调：处理玩家推进对话或跳过当前文字动画的请求。
func _input(event: InputEvent) -> void:
	# "next_line" 是 project.godot 中定义的输入动作，通常绑定到鼠标左键、空格或回车。
	if event.is_action_pressed("next_line"):
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

# 解析单条对话文本。
# line: 必须是 "角色名:对话内容" 格式，例如 "Phoenix:你好啊！"。
# 返回值: 包含 speaker_name（角色名字符串）和 dialog_line（对话正文）的字典。
func parse_line(line: String):
	# 只使用英文冒号分隔，保证数据格式与 dialog_lines 中定义的格式一致。
	# 对话正文中暂时不限制冒号出现，因此这里只取第 0 和第 1 段。
	var line_info = line.split(":")
	# 调试期保护：角色名和对话内容缺一不可，格式错误时会在编辑器中直接暴露问题。
	assert(len(line_info) >= 2)

	# 返回结构化数据，方便调用方按字段读取，而不是继续处理原始字符串。
	return {
		# 原始角色名字符串，后续会转换成 Character.Name 枚举。
		"speaker_name": line_info[0],
		# 需要交给 DialogUI 显示的具体台词。
		"dialog_line": line_info[1]
	}

# 解析并显示当前索引对应的对话。
# 该函数会同时更新对话框内容和角色立绘，使说话者、姓名与台词保持一致。
func process_current_line():
	# 取出当前索引对应的原始对话字符串。
	var line = dialog_lines[dialog_index]
	# 将原始字符串拆分成角色名和台词正文。
	var line_info = parse_line(line)
	# 将字符串形式的角色名转换成 Character.Name 枚举，供后续类型化函数使用。
	var character_name = Character.get_enum_from_string(line_info["speaker_name"])
	# 更新对话框中的姓名、台词，并启动逐字显示动画。
	dialog_ui.change_line(character_name, line_info["dialog_line"])
	# 切换角色立绘到当前说话者，并播放说话动画。
	character_sprite.change_character(character_name)

# DialogUI 的文字动画播完后触发。
# 此时让当前角色停止说话动画，恢复到待机动画，表示这句话已经显示完毕。
func _on_text_animation_done():
	character_sprite.play_idle_animation()
