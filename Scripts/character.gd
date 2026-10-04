# 全局角色配置类。
# 该脚本通过 class_name 暴露 Character，使其他脚本可以直接访问角色枚举和角色数据。
class_name Character

# 角色配置本身不放入场景树，只作为静态数据访问入口。
extends Node

# 游戏中可用角色的枚举。
# 对话文本中的角色名会通过 get_enum_from_string 转换到这些值。
enum Name {
	APOLLO,
	PHOENIX,
	TRUCY
}

# 所有角色的共享配置表。
# 外层键是 Character.Name 枚举，内层字典包含显示名、文字提示音性别和角色动画资源。
const CHARACTER_DETAILS: Dictionary = {
	Name.APOLLO: {
		# 显示在对话框姓名栏中的名字。
		"name": "Apollo",
		# TextBlipSound 会根据该值选择男性或女性提示音。
		"gender": "male",
		# Apollo 暂时没有立绘资源；为 null 时 CharacterSprite 会尝试回退到 idle 动画。
		"sprite_frames": null
	},
	Name.PHOENIX: {
		"name": "Phoenox",
		"gender": "male",
		# Phoenix 的角色动画资源。
		"sprite_frames": preload("res://Resources/phoenix-sprites.tres")
	},
	Name.TRUCY: {
		"name": "Trucy",
		"gender": "female",
		# Trucy 的角色动画资源。
		"sprite_frames": preload("res://Resources/trucy-sprites.tres")
	}
}

# 将对话文本中的角色名字符串转换成 Character.Name 枚举。
# string_value: 角色名，大小写不敏感，例如 "Phoenix" 或 "PHOENIX"。
# 返回值: 找到时返回对应枚举；找不到时记录错误并返回 PHOENIX 作为兜底角色。
static func get_enum_from_string(string_value: String) -> int:
	# 枚举键默认使用大写形式，因此这里先统一转换成大写再查找。
	var upper_string = string_value.to_upper()
	if Name.has(upper_string):
		return Name[upper_string]
	else:
		# 输出错误信息，帮助定位对话文本中拼错的角色名。
		push_error("错误角色名" + string_value)
		# 返回 1 对应 Name.PHOENIX，保证错误数据不会让场景立刻崩溃。
		return 1
