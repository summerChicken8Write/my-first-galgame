# 对话框 UI 控件。
# 负责逐字显示当前台词、显示说话者姓名，并按角色性别播放文字提示音。
extends Control

# 当前台词的全部可见字符显示完成后发出。
# 主场景接到该信号后会把角色动画从说话状态切换回待机状态。
signal text_animation_done

# 显示角色台词的富文本标签。
@onready var dialog_line = %DialogLine

# 显示当前说话者姓名的标签。
@onready var speaker_name = %SpeakerName

# 负责播放每个字符提示音的 AudioStreamPlayer。
@onready var text_blip_sound = %TextBlipSound

# 控制文字提示音播放间隔的计时器。
@onready var text_blip_timer = %TextBlipTimer

# 在遇到逗号、句号等停顿标点时，临时暂停提示音的计时器。
@onready var sentence_pause_timer = %SentencePauseTimer

# 逐字显示动画速度，单位为每秒显示的字符数。
# 数值越大，台词出现越快。
const ANIMATION_SPEED:int = 15

# 不播放提示音的标点符号集合。
# 当这些标点后面出现空格时，会短暂停止提示音，让停顿更接近自然朗读。
const NOT_SOUND_CHARS: Array = [",", ".", "?", "!", "，", "。", "？", "！"]

# 是否正在执行逐字显示动画。
# true 表示文字仍在逐字出现，false 表示当前台词已经显示完毕或尚未开始。
var animate_flag:bool = false

# 上一帧已经显示到第几个字符，用于检测本次新增的字符并处理标点停顿。
var current_visible_characters: int = 0

# 当前说话者在 Character.CHARACTER_DETAILS 中的数据。
# 这里会用于获取姓名、性别以及对应的提示音资源。
var current_character_details: Dictionary

# Godot 生命周期函数：节点进入场景树后自动调用。
# 这里只连接两个计时器的超时信号，具体显示内容由主场景调用 change_line 传入。
func _ready() -> void:
	text_blip_timer.timeout.connect(_on_text_blip_timeout)
	sentence_pause_timer.timeout.connect(_on_sentence_pause_timeout)

# Godot 生命周期函数：每帧自动调用。
# 根据 delta 时间逐步增加 RichTextLabel.visible_ratio，实现与帧率无关的逐字显示效果。
func _process(delta: float) -> void:
	# 只有动画处于播放状态，并且没有被标点停顿计时器暂停时，才继续推进文字。
	if animate_flag and sentence_pause_timer.is_stopped():
		# visible_ratio 小于 1 表示文本还没有完全显示出来。
		if dialog_line.visible_ratio < 1:
			# 每次增加的比例 = 当前文本总长度的倒数 * 每秒速度 * 帧间隔。
			# 这样无论文本长短、帧率高低，整体显示速度都保持稳定。
			dialog_line.visible_ratio += (1.0 / dialog_line.text.length()) * (ANIMATION_SPEED * delta)
			# RichTextLabel 的 visible_characters 会在本帧跨过新字符时增加。
			if dialog_line.visible_characters > current_visible_characters:
				# current_visible_characters 记录的是上一帧已经显示的位置，
				# 因此这里读取的是“刚显示出来”的那个字符。
				var current_char = dialog_line.text[current_visible_characters - 1]
				if current_visible_characters < dialog_line.text.length():
					# next_char 是即将显示的字符，用来判断标点后是否跟着空格。
					var next_char = dialog_line.text[current_visible_characters]
					if NOT_SOUND_CHARS.has(current_char) and next_char == " ":
						# 标点加空格代表一个短停顿，暂停提示音，避免连续播报标点。
						text_blip_timer.stop()
						sentence_pause_timer.stop()
				# 记录本帧已经显示到哪一个字符，供下一帧继续比较。
				current_visible_characters = dialog_line.visible_characters
		else:
			# 当前文本完全显示后停止提示音，并通知主场景播放待机动画。
			animate_flag = false
			text_blip_timer.stop()
			text_animation_done.emit()

# 切换对话框显示的内容。
# character_name: 当前说话者的 Character.Name 枚举值。
# line: 需要逐字显示的台词正文。
func change_line(character_name: Character.Name, line: String):
	# 从全局角色配置中取出姓名、性别、动画资源等信息。
	current_character_details = Character.CHARACTER_DETAILS[character_name]
	# 重置可见字符统计，确保新台词从头开始显示。
	current_visible_characters = 0
	# 更新 UI 中的说话者姓名。
	speaker_name.text = current_character_details["name"]
	# 更新需要显示的完整台词文本。
	dialog_line.text = line
	# RichTextLabel 的 visible_characters 设为 0 时，文本内容仍然存在，但不会显示任何字符。
	dialog_line.visible_characters = 0
	# 开启逐字动画，并启动文字提示音计时器。
	animate_flag = true
	text_blip_timer.start()
	
# 立刻结束当前逐字动画。
# 玩家在文字尚未显示完时按下推进键，会调用该函数直接显示完整台词。
func skip_text_animation():
	dialog_line.visible_ratio = 1

# 文字提示音计时器超时后播放一次角色提示音。
# 声音资源由 TextBlipSound 根据当前角色的 gender 字段决定。
func _on_text_blip_timeout():
	text_blip_sound.play_sound(current_character_details)

# 标点停顿计时器超时后重新启动提示音。
# 这样标点后的空格停顿结束时，后续字符可以继续发出提示音。
func _on_sentence_pause_timeout():
	text_blip_timer.start()
