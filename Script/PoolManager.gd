extends Node
# PoolManager.gd

var bullet_pool = []
@export var pool_size = 50
var bullet_scene = preload("res://Scenes/bullet.tscn")

func _ready():
	# Oyun başında havuzu doldur
	for i in range(pool_size):
		var bullet = bullet_scene.instantiate()
		bullet.visible = false
		bullet.set_process(false) # Çalışmasını durdur
		bullet_pool.append(bullet)
		add_child(bullet)

func get_bullet():
	for bullet in bullet_pool:
		if not bullet.visible: # Eğer mermi şu an kullanımda değilse
			return bullet
	# Havuz yetmezse yeni mermi ekle (Opsiyonel)
	var new_bullet = bullet_scene.instantiate()
	bullet_pool.append(new_bullet)
	add_child(new_bullet)
	return new_bullet
