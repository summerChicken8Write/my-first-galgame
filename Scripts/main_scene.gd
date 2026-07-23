 # 继承自 Node2D，作为主场景的控制节点
extends Node2D

 # 在节点进入场景树后自动获取 %Character 节点（角色显示）的引用
@onready var character = %Character

 # 在节点进入场景树后自动获取 %DialogUI 节点（对话框 UI）的引用
@onready var dialog_ui = %DialogUI

 # 当前对话在对话列表中的索引
var dialog_index = 0

 # 对话列表，每条格式为 "角色名:对话内容"
const dialog_lines: Array[String] = [
	# 第 0 条：Phoenix 说"你好啊"
	"Phoenix:你好啊",
	# 第 1 条：Trucy 说"你也好"
	"Trucy:你也好",
	# 第 2 条：Apollo 说"你俩谁啊"
	"Apollo:你俩谁啊",
	# 第 3 条：Phoenix 说"你要去哪啊"
	"Phoenix:你要去哪啊",
	# 第 4 条：Trucy 说"管的着么"
	"Trucy:管的着么",
	# 第 5 条：Apollo 说"你俩有没有听我说话"
	"Apollo:你俩有没有听我说话",
	# 第 6 条：Phoenix 说"你这个人怎么这样"
	"Phoenix:你这个人怎么这样",
	# 第 7 条：Trucy 说"怎么？你不服气？"
	"Trucy:怎么？你不服气？"
]

 # 节点首次进入场景树时自动调用
func _ready() -> void:
	# 将对话索引初始化为 0，从第一条对话开始
	dialog_index = 0
	# 处理并显示当前索引对应的对话
	process_current_line()

 # 处理用户的输入事件
func _input(event: InputEvent) -> void:
	# 检测是否按下"下一句"的操作（next_line 动作）
	if event.is_action_pressed("next_line"):
		# 如果当前对话不是最后一条，才允许前进
		if dialog_index < len(dialog_lines) - 1:
			# 索引加 1，跳转到下一条对话
			dialog_index += 1
			# 处理并显示新的对话
			process_current_line()

 # 解析单条对话文本，拆分为角色名和对话内容
 # line: 格式为 "角色名:对话内容" 的字符串
func parse_line(line: String):
	# 用冒号分隔字符串，得到角色名和对话内容
	var line_info = line.split(":")
	# 断言：确保拆分后至少有两个部分（角色名和内容必须都存在）
	assert(len(line_info) >= 2)

	# 返回包含角色名和对话内容的字典
	return {
		# 说话者名字
		"speaker_name": line_info[0],
		# 对话文本内容
		"dialog_line": line_info[1]
	}

 # 处理并显示当前索引对应的对话
func process_current_line():
	# 根据当前索引从对话列表中获取对应的对话文本
	var line = dialog_lines[dialog_index]
	# 调用 parse_line 解析该文本，得到角色名和对话内容
	var line_info = parse_line(line)
	# 让对话框 UI 显示角色名和对话内容
	dialog_ui.change_line(line_info["speaker_name"], line_info["dialog_line"])
	# 让角色节点切换到对应的角色外观和说话状态
	character.change_character(line_info["speaker_name"])
