# 对话逐字音效播放器。
# 根据角色配置中的 gender 字段，在男性或女性提示音资源之间切换。
extends AudioStreamPlayer

# 可用的文字提示音资源，键名必须与 Character.CHARACTER_DETAILS 中的 gender 值一致。
const sounds: Dictionary = {
	"male": preload("res://Assets/sounds/sfx-blipmale.wav"),
	"female": preload("res://Assets/sounds/sfx-blipfemale.wav"),
}

# 为指定角色播放一次文字提示音。
# character_detail: 当前角色在 Character.CHARACTER_DETAILS 中对应的配置字典。
func play_sound(character_detail: Dictionary):
	# 根据角色性别选择对应音效资源，并替换当前 AudioStreamPlayer 的流。
	var character_gender = character_detail["gender"]
	stream = sounds[character_gender]
	# 播放当前字符对应的提示音。
	play()
