# 角色立绘显示节点。
# 负责根据当前说话者读取 Character 中的动画资源，并切换说话或待机动画。
extends Node2D

# 实际显示角色立绘和播放动画的 AnimatedSprite2D。
@onready var animated_sprite = %AnimatedSprite2D

# Godot 生命周期函数：节点进入场景树后自动调用。
# 当前没有额外初始化逻辑，角色外观会在主场景显示第一句台词时设置。
func _ready() -> void:
	pass

# 切换角色外观和动画状态。
# character_name: 要显示的角色，来自 Character.Name 枚举。
# is_talking: 是否播放说话动画；true 表示正在说话，false 表示待机。
func change_character(character_name: Character.Name, is_talking: bool = true):
	# 从角色全局配置中读取该角色对应的 SpriteFrames 资源。
	var sprite_frames = Character.CHARACTER_DETAILS[character_name]["sprite_frames"]
	if sprite_frames:
		# 角色配置中存在动画资源时，先替换 SpriteFrames，再按说话状态播放动画。
		animated_sprite.sprite_frames = sprite_frames
		if is_talking:
			animated_sprite.play("talking")
		else:
			animated_sprite.play("idle")
	else:
		# 没有配置角色专属动画时回退到当前 SpriteFrames 的 idle 动画。
		# 这可以让尚未制作立绘的角色仍然出现在场景中，而不是保持上一帧状态。
		animated_sprite.play("idle")

# 播放待机动画。
# 主场景在文字动画完成时会调用该函数，让角色停止说话动作。
func play_idle_animation():
	animated_sprite.play("idle")
