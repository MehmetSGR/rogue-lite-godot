extends Area2D

var speed = 600
var direction = Vector2.RIGHT
var damage = 1.0 #Mermi hasarı

func _process(delta):
	#Mermi sürekli belirlediği yöne gider
	position += direction * speed * delta

func deactivate():
	visible = false
	set_process(false)
	set_deferred("monitoring", false) # Çarpışmaları kapat
	set_deferred("monitorable", false)

func activate(pos, dir):
	global_position = pos
	direction = dir
	visible = true
	set_process(true)
	set_deferred("monitoring", true)
	set_deferred("monitorable", true)

# Eski queue_free() yerine deactivate() çağır:
func _on_visible_on_screen_notifier_2d_screen_exited():
	deactivate() 

func _on_body_entered(body):
	if body.is_in_group("enemy"):
		if body.has_method("take_damage"):
			body.take_damage(damage) 
		deactivate()
	
