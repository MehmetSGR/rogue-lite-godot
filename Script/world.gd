extends Node2D

@export var basic_enemy_data: EnemyData
@export var available_upgrades: Array[UpgradeData] = []

@onready var player = $Player 
@onready var hp_bar = $CanvasLayer/HPBar
@onready var xp_bar = $CanvasLayer/XPBar 
@onready var upgrade_menu = $CanvasLayer/UpgradeMenu

var current_options: Array[UpgradeData] = []
var enemy_scene = preload("res://Scenes/enemy.tscn")

func _ready():
	# Player'ın sinyallerini bu scriptteki fonksiyonlara bağlıyoruz
	player.xp_changed.connect(_on_player_xp_changed)
	player.leveled_up.connect(_on_player_leveled_up)
	#HP Bar'ın başlangıç değerlerini ayarla
	hp_bar.max_value = player.max_health
	hp_bar.value = player.current_health
	
	player.leveled_up.connect(_on_player_leveled_up)
	upgrade_menu.hide()

func _process(_delta):
	hp_bar.value = player.current_health

func _on_player_xp_changed(current, total):
	# Barın maksimum değerini ve şu anki değerini güncelle
	xp_bar.max_value = total
	xp_bar.value = current

func _on_player_leveled_up(new_level):
	# İleride buraya seviye atlama ekranı gelecek
	get_tree().paused = true
	var pool = available_upgrades.duplicate()
	pool.shuffle()
	
	for i in range(min(3, pool.size())):
		current_options.append(pool[i])
		
	$CanvasLayer/UpgradeMenu/ColorRect/VBoxContainer/Opt1.text = current_options[0].upgrade_name
	$CanvasLayer/UpgradeMenu/ColorRect/VBoxContainer/Opt2.text = current_options[1].upgrade_name
	$CanvasLayer/UpgradeMenu/ColorRect/VBoxContainer/Opt3.text = current_options[2].upgrade_name
	

func _on_upgrade_selected(index: int):
	if index < current_options.size():
		current_options[index].apply_upgrade(player)
	resume_game()
	
func _on_timer_timeout():
	var new_enemy = enemy_scene.instantiate()
	new_enemy.data = basic_enemy_data 
	new_enemy.global_position = Vector2(randf_range(0, 1000), randf_range(0,1000))
	add_child(new_enemy)
	

func resume_game():
	upgrade_menu.hide() # Menüyü kapat
	get_tree().paused = false # Oyunu devam ettir
