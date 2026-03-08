extends CharacterBody2D

signal xp_changed(current_xp, required_xp)
signal leveled_up(new_level)


@export var projectile_container_path: NodePath
@export var max_health = 100.0
@export var speed = 300.0

var fire_rate = 1.0
var level = 1
var experience = 0
var experience_required = 5
var current_health = 100.0


signal health_changed(current_hp)

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
	
	print("Seviye atladı. Yeni seviye : ", level)
	
	xp_changed.emit(experience, experience_required)
	leveled_up.emit(level)
	

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
		var target = enemies[0]
		for enemy in enemies:
			if global_position.distance_to(enemy.global_position) < global_position.distance_to(target.global_position):
				target = enemy
		
		# Sadece mermiyi al ve olduğu yerde aktif et
		var bullet = PoolManager.get_bullet()
		
		# Eğer mermi zaten bir yerdeyse, önce oradan çıkar.
		if bullet.get_parent():
			bullet.get_parent().remove_child(bullet)
		bullet.activate(global_position, global_position.direction_to(target.global_position))
		
		var container = get_node_or_null(projectile_container_path)
		if container:
			container.add_child(bullet)
		else:
			get_tree().current_scene.add_child(bullet) # Yedek plan
	

func _on_timer_timeout() -> void:
	shoot()

func take_damage(amount):
	current_health -= amount
	print("Oyuncu Hasar Aldı! Kalan Can: ", current_health)
	if current_health <= 0:
		die()
	
	health_changed.emit(current_health)

func die():
	print("OYUN BİTTİ!")
	get_tree().reload_current_scene() # Şimdilik sahneyi yeniden başlatır


# player.gd içine ekle
func _on_magnet_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("xp_gem"):
		if area.has_method("start_magnet"):
			area.start_magnet(self)
