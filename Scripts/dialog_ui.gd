 # 继承自 Control，作为对话框 UI 的节点
extends Control

 # 在节点进入场景树后自动获取 %DialogLine（显示对话文本的 RichTextLabel）节点的引用
@onready var dialog_line = %DialogLine

 # 在节点进入场景树后自动获取 %SpeakerName（显示说话者名字的标签）节点的引用
@onready var speaker_name = %SpeakerName

 # 逐字显示动画的速度（每秒显示的字符数）
const ANIMATION_SPEED:int = 30

 # 是否正在播放逐字动画的标志
var animate_flag:bool = false

 # 当前已显示的字符数
var current_visible_characters: int = 0

 # 节点首次进入场景树时自动调用
func _ready() -> void:
	pass

 # 每帧自动调用，用于驱动逐字显示动画
func _process(delta: float) -> void:
	# 只有在动画标志为 true 时才更新显示
	if animate_flag:
		# 若文本还未完全显示
		if dialog_line.visible_ratio < 1:
			# 根据动画速度和时间增量，逐步增加 visible_ratio，实现逐字出现效果
			dialog_line.visible_ratio += (1.0 / dialog_line.text.length()) * (ANIMATION_SPEED * delta)
			# 记录当前已显示的字符数
			current_visible_characters = dialog_line.visible_characters
		else:
			# 文本完全显示后关闭动画标志
			animate_flag = false

 # 切换对话框显示的内容
 # speaker: 说话者的名字
 # line: 说话的内容文本
func change_line(speaker: String, line: String):
	# 重置当前已显示字符数为 0
	current_visible_characters = 0
	# 设置说话者名字
	speaker_name.text = speaker
	# 设置对话文本内容
	dialog_line.text = line
	# 将可见字符数置为 0，确保从头开始显示
	dialog_line.visible_characters = 0
	# 开启逐字动画标志
	animate_flag = true
