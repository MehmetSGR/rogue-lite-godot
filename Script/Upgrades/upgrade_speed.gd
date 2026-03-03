extends UpgradeData
class_name UpgradeSpeed

@export var speed_boost: float = 50.0

func apply_upgrade(player):
	player.speed += speed_boost
	print("Mimari Basarı: Oyuncu Hızı ", player.speed, " oldu")
