extends CharacterBody3D

@onready var head: Node3D = $Head
@onready var dash_timer: Timer = $dash_refill_timer
@onready var camera: Camera3D = $Head/Camera3D
@onready var animation_player: AnimationPlayer = $Head/hand/AnimationPlayer
@onready var normal_collision: CollisionShape3D = $CollisionShape3D
@onready var slide_collision: CollisionShape3D = $CollisionShape3D2
@onready var dashing_time: Timer = $dash_time
@onready var shake_time: Timer = $shake_time
@onready var dashes_ui: RichTextLabel = $"../../../GUI/DASHES"
@onready var hp_ui: RichTextLabel = $"../../../GUI/HP"
@onready var speed: TextureProgressBar = $"../../../GUI/SPEED"
@onready var control_ui: Control = $"../../../GUI"
@onready var speedlines: ColorRect = $"../../../speedlines"
@onready var pause_vhs: TextureRect = $"../../../pause_filter"
@onready var flash: ColorRect = $"../../../flash"
@onready var trail: GPUTrail3D = $Head/hand/trail
@onready var katana_model: Node3D = $Head/hand/katana/katan_model
@onready var crosshair: Sprite2D = $"../../../crosshair/cross"
@onready var slide_queu_time: Timer = $slide_queu_time

var slide_queued= false
var SHAKE_INTENSITY = 2
var is_attacking = false
var hp = 100
var is_blocking = false
const NORMAL_FOV = 90.3
var SPEED = 15.0
const NORMAL_SPEED = 15.0
var BLOCK_SPEED = 3.0
const SLIDE_SPEED = 40.0
const DASH_SPEED = 120.0
var HOOKING_SPEED = 20.0
const JUMP_VELOCITY = 12
const SENS = 0.2
var direction = Vector3.ZERO
var cur_slash = 1
var is_dashing = false
var cur_dashes = 3
const MAX_DASHES = 3
const DASH_FOV = 83
var HEAD_BOB_ANGLE = 0
var is_sliding = false
var OG_HEAD_Y = 0
var is_moving = false
var INIT_POS = Vector3.ZERO

func _ready() -> void:
	change_trail_color(Globals.TRAIL_COLOR)
	katana_model.set_color(Globals.SWORD_COLOR)
	crosshair.visible = true
	OG_HEAD_Y = float(head.position.y)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		if !Globals.PAUSED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			pause_vhs.visible = true
			$"../../../Container".visible = true
			Globals.PAUSED = true
			var fx = AudioEffectHighPassFilter.new()
			AudioServer.add_bus_effect(AudioServer.get_bus_index("Song"), fx, 1)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			pause_vhs.visible = false
			$"../../../Container".visible = false
			Globals.PAUSED = false
			AudioServer.remove_bus_effect(AudioServer.get_bus_index("Song"), 0)

	if Globals.PAUSED: return
	
	if event is InputEventMouseMotion:
		rotate_y(-deg_to_rad(event.relative.x * SENS))
		head.rotate_x(-deg_to_rad(event.relative.y * SENS))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-80), deg_to_rad(80))
	
	if event.is_action_pressed("attack"):
		if not is_blocking:
			animation_player.stop()
			animation_player.play("attack")
			is_attacking = true
			
	if event.is_action_pressed("block"):
		if animation_player.is_playing():
			animation_player.stop()
		
		animation_player.play("block")
		is_blocking = true
		
	if !$HookController.is_hook_launched and is_moving and Input.is_action_just_pressed("slide") and not is_dashing:
		if is_on_floor():
			SPEED = SLIDE_SPEED
			slide_collision.disabled = false
			normal_collision.disabled = true 
			
			is_sliding = true
			speedlines.visible = true
			animation_player.play("slide")
			
		else:
			slide_queued= true
			
	if Input.is_action_just_released("slide") and is_sliding:
		slide_collision.disabled = true 
		normal_collision.disabled = false 
	
		SPEED = NORMAL_SPEED
		animation_player.play("RESET")
		is_sliding = false

	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY + (JUMP_VELOCITY/2)*int(is_sliding)
		if is_sliding:
			slide_collision.disabled = true 
			normal_collision.disabled = false 
		
			SPEED = NORMAL_SPEED
			animation_player.play("RESET")
			is_sliding = false
	
	
	if !$HookController.is_hook_launched and is_moving and Input.is_action_just_pressed("dash") and cur_dashes > 0 and not is_sliding:
		SPEED = DASH_SPEED
		is_dashing = true
		cur_dashes -= 1
		camera.fov = DASH_FOV
		control_ui.scale = Vector2(1.05, 1)
		dashing_time.start()


func _physics_process(delta: float) -> void:

	if Globals.PAUSED: return

	is_moving = get_real_velocity().length() > 5
	
	if $Head/Camera3D/ray.is_colliding():
		$"../../../crosshair/can_hook".scale = lerp($"../../../crosshair/can_hook".scale, Vector2(0.223, 0.223), 12.0 * delta) 
	else:
		$"../../../crosshair/can_hook".scale = lerp($"../../../crosshair/can_hook".scale, Vector2(0, 0), 12.0 * delta)
	
	if animation_player.name == "attack":
		var collided_with = katana_model.check_collision()
		
		for i in collided_with:
			if is_attacking:
				SHAKE_INTENSITY = 3
				shake_time.wait_time = 0.3
				shake_time.start()
				
				$hitstop_time.start()
				flash.color = Color("ffffff7b")
				Engine.time_scale = 0.01
				
				i.queue_free()
		
	if not is_on_floor():
		velocity += get_gravity() * delta
		var tween = create_tween()
		tween.tween_property(camera, "v_offset", 0.1, 0.2).set_ease(Tween.EASE_OUT)
	
	if is_on_floor():
		if slide_queued and Input.is_action_pressed("slide"):
			if not is_sliding:
				SPEED = SLIDE_SPEED
				slide_collision.disabled = false
				normal_collision.disabled = true 
				
				is_sliding = true
				speedlines.visible = true
				animation_player.play("slide")
				slide_queued=false

	if is_blocking:
		is_dashing = false 
		is_sliding = false
		SPEED = BLOCK_SPEED
	
	if velocity.y < 0:
		camera.v_offset = -0.05
	elif velocity.y == 0:
		var tween = create_tween()
		tween.tween_property(camera, "v_offset", 0.0, 0.1).set_ease(Tween.EASE_IN)

	if is_sliding:
		if !is_moving:
			is_sliding = false  
		else:
			camera.fov = lerp(camera.fov, NORMAL_FOV - 10, 15.0 * delta)	
			head.position.y = lerp(head.position.y, OG_HEAD_Y - 0.8, 15.0 * delta)	
			control_ui.scale = lerp(control_ui.scale, Vector2(0.95, 0.95), 10.0 * delta)
	else:		
		speedlines.visible = false
		camera.fov = lerp(camera.fov, NORMAL_FOV, 20.0 * delta)	
		head.position.y = lerpf(head.position.y, OG_HEAD_Y, 20.0 * delta)	
		control_ui.scale = lerp(control_ui.scale, Vector2(1.0, 1.0), 20.0 * delta)


	if cur_dashes == 0:
		if dash_timer.time_left == 0:
			dash_timer.start()

	if is_dashing:		
		SPEED = lerp(SPEED, NORMAL_SPEED, 8.0 * delta)
		camera.fov = lerp(camera.fov, NORMAL_FOV, delta - 0.3)
		control_ui.scale = lerp(control_ui.scale, Vector2(1, 1),  delta - 0.4)
	
	# --- SMOOTH MOVEMENT / MOMENTUM CONSERVATION ---
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	var target_dir = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	direction = target_dir # Kept so the shake logic at the bottom still functions

	if direction:
		camera.h_offset = lerp(camera.h_offset, input_dir.x * 0.12, 7.0 * delta)

	var current_h_vel = Vector3(velocity.x, 0, velocity.z)
	var target_h_vel = direction * SPEED

	# Tuning variables: Snappy on the ground, loose in the air
	var accel = 15.0 if is_on_floor() else 3.0
	var friction = 12.0 if is_on_floor() else 1.5
	var speed_decay = 5.0 if is_on_floor() else 0.5 # Conserves momentum heavily when airborne

	if direction != Vector3.ZERO:
		if current_h_vel.length() > SPEED:
			# Conserve the high speed (e.g. from a dash), but smoothly steer towards input
			var steered_vel = direction * current_h_vel.length()
			current_h_vel = current_h_vel.lerp(steered_vel, accel * delta)
			
			# Slowly bleed off the excess speed back down to the current SPEED cap
			current_h_vel = current_h_vel.lerp(target_h_vel, speed_decay * delta)
		else:
			current_h_vel = current_h_vel.lerp(target_h_vel, accel * delta)
	else:
		# Apply friction to slide to a halt
		current_h_vel = current_h_vel.lerp(Vector3.ZERO, friction * delta)

	velocity.x =  current_h_vel.x if !is_blocking else 0
	velocity.z = current_h_vel.z if !is_blocking else 0

	if position.y < -10 and !$HookController.is_hook_launched:
		global_position = INIT_POS 
		velocity = Vector3.ZERO
		
		shake_time.wait_time = 0.1
		SHAKE_INTENSITY = 2
		shake_time.start()
	
	if shake_time.time_left > 0:
		camera.h_offset = randf_range(-SHAKE_INTENSITY * 0.01, SHAKE_INTENSITY * 0.01)
		camera.v_offset = randf_range(-SHAKE_INTENSITY * 0.01, SHAKE_INTENSITY * 0.01)
	else:
		if not direction:
			camera.h_offset = 0
			camera.v_offset = 0
		
	move_and_slide()
	
	speed.value = get_real_velocity().length() * 2

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name != "slide" and anim_name != "hook":
		animation_player.play("RESET")
	
	if anim_name == "attack":
		is_attacking = false
	
	if anim_name == "block":
		is_blocking = false
		SPEED = NORMAL_SPEED
		
func _on_dash_refill_timer_timeout() -> void:
	if cur_dashes < MAX_DASHES:
		cur_dashes += 1
		dash_timer.start()

func _on_dash_time_timeout() -> void:
	is_dashing = false
	SPEED = NORMAL_SPEED

func _on_hitstop_time_timeout() -> void:
	Engine.time_scale = 1
	flash.color = Color('ffffff00')

func change_trail_color(color):
	var grt = GradientTexture1D.new()
	var gr = Gradient.new()
	gr.colors = PackedColorArray([Color.TRANSPARENT, Color.TRANSPARENT, Color.TRANSPARENT, Color.TRANSPARENT, Color.TRANSPARENT, Color(color)])
	grt.set_gradient(gr)
	trail._set_color_ramp(grt)

func _on_trail_color_picker_color_changed(color: Color) -> void:
	change_trail_color(color.to_html())

func _on_sword_color_picker_color_changed(color: Color) -> void:
	katana_model.set_color(color)

func _on_check_trail_toggled(toggled_on: bool) -> void:
	trail.visible = toggled_on

func _on_hook_controller_hook_launched() -> void:
	if $Head/Camera3D/ray.is_colliding():
		animation_player.play("hook")
		SPEED = HOOKING_SPEED

func _on_hook_controller_hook_detached() -> void:
	animation_player.play("unhook")
	SPEED = NORMAL_SPEED
