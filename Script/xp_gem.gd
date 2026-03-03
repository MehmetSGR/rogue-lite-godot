extends Area2D

var xp_amount = 1 # Bu kristal kaç puan verecek?
var move_speed = 0
var target = null # Mıknatıs etkisi için oyuncu
var is_being_pulled = false

var scatter_velocity = Vector2.ZERO
var friction = 0.92

func _process(delta):
	#Saçılma Mantığı
	if scatter_velocity.length() > 10:
		global_position += scatter_velocity * delta
		scatter_velocity *= friction
	#Mıknatıs Mantığı	
	if is_being_pulled and target:
		move_speed = lerp(move_speed, 600.0, 0.1)
		global_position = global_position.move_toward(target.global_position, move_speed * delta)

#Düşman tarafından çağrılacak fonksiyon
func apply_scatter(force_vector: Vector2):
	scatter_velocity = force_vector

func start_magnet(player_node):
	target = player_node
	is_being_pulled = true

# Kristal oyuncuya fiziksel olarak değince ne olacak?
func _on_body_entered(body):
	if body.is_in_group("player"):
		if body.has_method("gain_xp"):
			body.gain_xp(xp_amount) 
		queue_free() # Şimdilik yok et (İleride Pooling'e dahil edeceğiz)
