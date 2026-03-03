extends CharacterBody2D

signal xp_changed(current_xp, required_xp)
signal leveled_up(new_level)

var fire_rate = 1.0
var bullet_scene = preload("res://Scenes/bullet.tscn")
var world_scene = preload("res://Scenes/world.tscn")

@export var max_health = 100.0
@export var speed = 300.0

var level = 1
var experience = 0
var experience_required = 5
var current_health = 100.0

func _ready():
	add_to_group("xp_gem")
	xp_changed.emit(experience, experience_required)
	
func gain_xp(amount):
	experience += amount
	print("XP Alındı: ", experience, "/", experience_required)
	xp_changed.emit(experience, experience_required)
	if experience >= experience_required:
		level_up()
		
func level_up():
	level += 1
	experience = 0
	experience_required *= 1.5
	leveled_up.emit(level)
	xp_changed.emit(experience, experience_required)
	
	
	var upgrade_choice = randi() % 3
	match upgrade_choice:
		0:
			speed += 50
			print("Hız Arttı! Yeni Hız : ", speed)
		1:
			fire_rate *= 0.8
			$Timer.wait_time = fire_rate
			print("Ateş Hızı Arttı")
		
		2:
			max_health += 20
			current_health += 20
			print("Maksimum Can Arttı!")
		

func _physics_process(_delta):
	#Hareket yönünü al (WASD veya Ok tuşları otomatik tanımalıdır)
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	#Eğer bir yöne basılıyorsa hareket et, basılmıyorsa yavaşla
	if direction:
		velocity = direction * speed
	else:
		velocity = velocity.move_toward(Vector2.ZERO, speed)
		
	move_and_slide() #Godot'un hazır fizik fonksiyonu
	
func shoot():
	var enemies = get_tree().get_nodes_in_group("enemy")
	if enemies.size() > 0:
		# En yakın düşmanı bulma algoritması
		var target = enemies[0]
		for enemy in enemies:
			if global_position.distance_to(enemy.global_position) < global_position.distance_to(target.global_position):
				target = enemy
		
		# Mermiyi oluştur ve fırlat
		var bullet = PoolManager.get_bullet()
		bullet.activate(global_position, global_position.direction_to(target.global_position))
		bullet.global_position = global_position
		bullet.direction = global_position.direction_to(target.global_position)
		get_tree().root.add_child(bullet)
	

func _on_timer_timeout() -> void:
	shoot()

func take_damage(amount):
	current_health -= amount
	print("Oyuncu Hasar Aldı! Kalan Can: ", current_health)
	if current_health <= 0:
		die()

func die():
	print("OYUN BİTTİ!")
	get_tree().reload_current_scene() # Şimdilik sahneyi yeniden başlatır


# player.gd içine ekle
func _on_magnet_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("xp_gem"):
		if area.has_method("start_magnet"):
			area.start_magnet(self)
