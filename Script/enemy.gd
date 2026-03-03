extends CharacterBody2D

@export var data: EnemyData
@onready var player = get_tree().get_first_node_in_group("player")

# enemy.gd içine eklenecek
var xp_gem_scene = preload("res://Scenes/xp_gem.tscn")
var current_health: float

func _ready():
	if data:
		current_health = data.health
		# Görseli veriye göre özelleştirebilirsin
		$Sprite2D.modulate = data.sprite_color

func _physics_process(_delta):
	if player:
		#Oyuncuya doğru olan yön vektörü
		var direction = global_position.direction_to(player.global_position)
		velocity = direction * data.speed
		move_and_slide()
		
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			var collider = collision.get_collider()
			if collider.is_in_group("player"):
				if collider.has_method("take_damage"):
					collider.take_damage(0.5)
		
func take_damage(amount):
	current_health -= amount
	modulate = Color.RED # Hemen kırmızı yap
	await get_tree().create_timer(0.1).timeout # 0.1 sn bekle
	modulate = Color.WHITE # Eski haline (veya orijinal rengine) döndür
	
	if current_health <= 0:
		die()
		
func die():
	var gem = xp_gem_scene.instantiate()
	gem.global_position = global_position # Düşmanın öldüğü yer
	get_tree().root.add_child(gem)
	
	var random_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	var random_force = randf_range(200, 400)
	if gem.has_method("apply_scatter"):
		gem.apply_scatter(random_direction * random_force)
		
	queue_free()
