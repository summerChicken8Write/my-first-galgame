 # 继承自 Node2D，作为角色显示的节点
extends Node2D

 # 在节点进入场景树后自动获取 %AnimatedSprite2D 节点的引用
@onready var animated_sprite = %AnimatedSprite2D

 # 角色精灵帧资源字典，键为角色名，值为对应的 SpriteFrames 资源
const CHARACTER_FARAMES = {
	# "Phoenix" 角色的精灵帧资源文件
	"Phoenix": preload("res://Resources/phoenix-sprites.tres"),
	# "Trucy" 角色的精灵帧资源文件
	"Trucy": preload("res://Resources/trucy-sprites.tres")
}

 # 节点首次进入场景树时自动调用
func _ready() -> void:
	pass

 # 切换角色外观及说话状态
 # character_name: 角色名称
 # is_talking: 是否处于说话状态，默认为 true
func change_character(character_name: String, is_talking: bool = true):
	# 特例：Apollo 不使用精灵帧资源，直接播放 idle 动画
	if character_name == "Apollo":
		# 播放空闲动画
		animated_sprite.play("idle")
	else:
		# 从字典中获取对应角色的精灵帧并设置到 AnimatedSprite2D
		animated_sprite.sprite_frames = CHARACTER_FARAMES[character_name]
		# 根据说话状态播放对应的动画
		if is_talking:
			# 播放说话动画
			animated_sprite.play("talking")
		else:
			# 播放空闲动画
			animated_sprite.play("idle")
