extends Node2D

@export var basic_enemy_data: EnemyData
@export var available_upgrades: Array[UpgradeData] = []

@onready var player = $Player 
@onready var hp_bar = $CanvasLayer/HPBar
@onready var xp_bar = $CanvasLayer/XPBar 
@onready var upgrade_menu = $CanvasLayer/UpgradeMenu
@onready var projectile_container = $ProjectileContainer

var current_options: Array[UpgradeData] = []
var enemy_scene = preload("res://Scenes/enemy.tscn")

func _ready():
	# Player'ın sinyallerini bu scriptteki fonksiyonlara bağlıyoruz
	player.xp_changed.connect(_on_player_xp_changed)
	player.leveled_up.connect(_on_player_leveled_up)
	#HP Bar'ın başlangıç değerlerini ayarla
	hp_bar.max_value = player.max_health
	hp_bar.value = player.current_health
	
	player.health_changed.connect(func(hp): hp_bar.value = hp)
	
	# YENİ EKLE: Butonların tıklanma olaylarını (signal) koda bağlıyoruz
	$CanvasLayer/UpgradeMenu/ColorRect/VBoxContainer/Opt1.pressed.connect(func(): _on_upgrade_selected(0))
	$CanvasLayer/UpgradeMenu/ColorRect/VBoxContainer/Opt2.pressed.connect(func(): _on_upgrade_selected(1))
	$CanvasLayer/UpgradeMenu/ColorRect/VBoxContainer/Opt3.pressed.connect(func(): _on_upgrade_selected(2))
	upgrade_menu.hide()

func _process(_delta):
	pass

func _on_player_xp_changed(current, total):
	# Barın maksimum değerini ve şu anki değerini güncelle
	xp_bar.max_value = total
	xp_bar.value = current

func _on_player_leveled_up(_new_level): # Parametreye _ ekledik (temiz kod)
	get_tree().paused = true
	current_options.clear()
	
	var pool = available_upgrades.duplicate()
	pool.shuffle()
	
	# Güvenlik: Elimizde kaç upgrade varsa (en fazla 3) o kadar göster
	var num_to_show = min(3, pool.size())
	
	# Önce tüm butonları gizle ki eski değerler kalmasın
	$CanvasLayer/UpgradeMenu/ColorRect/VBoxContainer/Opt1.hide()
	$CanvasLayer/UpgradeMenu/ColorRect/VBoxContainer/Opt2.hide()
	$CanvasLayer/UpgradeMenu/ColorRect/VBoxContainer/Opt3.hide()
	
	for i in range(num_to_show):
		current_options.append(pool[i])
		var opt_button = get_node("CanvasLayer/UpgradeMenu/ColorRect/VBoxContainer/Opt" + str(i+1))
		opt_button.text = pool[i].upgrade_name
		opt_button.show() # Sadece ihtiyacımız olan butonu göster
	
	upgrade_menu.show()
	

func _on_upgrade_selected(index: int):
	if index < current_options.size():
		current_options[index].apply_upgrade(player)
	
	current_options.clear()	
	
	resume_game()
	
func _on_timer_timeout():
	var new_enemy = enemy_scene.instantiate()
	new_enemy.data = basic_enemy_data 
	
	var random_angle = randf() * 2 * PI
	var spawn_distance = 750
	var spawn_direction = Vector2(cos(random_angle), sin(random_angle))
	var spawn_pos = player.global_position + (spawn_direction * spawn_distance)
	
	new_enemy.global_position = spawn_pos
	add_child(new_enemy)
	

func resume_game():
	upgrade_menu.hide() # Menüyü kapat
	get_tree().paused = false # Oyunu devam ettir
