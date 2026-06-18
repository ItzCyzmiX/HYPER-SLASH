extends CharacterBody3D

@onready var head: Node3D = $Head
@onready var dash_timer: Timer = $dash_refill_timer
@onready var camera: Camera3D = $Head/Camera3D
@onready var animation_player: AnimationPlayer = $Head/hand/AnimationPlayer
@onready var normal_collision: CollisionShape3D = $CollisionShape3D
@onready var slide_collision: CollisionShape3D = $CollisionShape3D2
@onready var dashing_time: Timer = $dash_time
@onready var shake_time: Timer = $shake_time
@onready var dashes_ui: RichTextLabel = $"../../../Control/DASHES"
@onready var hp_ui: RichTextLabel = $"../../../Control/HP"
@onready var speed: TextureProgressBar = $"../../../Control/SPEED"
@onready var control_ui: Control = $"../../../Control"
@onready var speedlines: ColorRect = $"../../../speedlines"

var hp = 100
var SPEED = 10.0
const NORMAL_FOV = 90.3
const NORMAL_SPEED = 10.0
const SLIDE_SPEED = 20.0
const DASH_SPEED = 100.0
const JUMP_VELOCITY = 9
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

func _enter_tree() -> void:
	set_multiplayer_authority(str(name).to_int())
	
func _ready() -> void:
	print('kk')
	#camera.current = is_multiplayer_authority()
	OG_HEAD_Y = head.position.y
	INIT_POS = position
	#if is_multiplayer_authority():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event: InputEvent) -> void:
	#if !is_multiplayer_authority(): return
	if event is InputEventMouseMotion:

		rotate_y(-deg_to_rad(event.relative.x * SENS))
		head.rotate_x(-deg_to_rad(event.relative.y * SENS))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-60), deg_to_rad(60))
	
	if event.is_action_pressed("attack"):
	
		if animation_player.current_animation == "slash1":
				animation_player.stop()
				animation_player.play("slash2")
		else:
			animation_player.play("slash1")
			
		
	if event.is_action_pressed("block"):
		if animation_player.is_playing():
			animation_player.stop()
			
		animation_player.play("block")



func _physics_process(delta: float) -> void:
	#if !is_multiplayer_authority(): return

	move_and_slide()

	if not is_on_floor():
		velocity += get_gravity() * delta
		var tween = create_tween()
		tween.tween_property(camera, "v_offset", 0.1, 0.2).set_ease(Tween.EASE_OUT)
	
	if velocity.y < 0:
		camera.v_offset = -0.05
		
	elif velocity.y == 0:
		var tween = create_tween()
		tween.tween_property(camera, "v_offset", 0.0, 0.1).set_ease(Tween.EASE_IN)
		
	is_moving = get_real_velocity().length() > 0.15
	
	if is_moving and Input.is_action_just_pressed("slide") and is_on_floor() and not is_dashing:
		SPEED = SLIDE_SPEED
		
		slide_collision.disabled = false
		normal_collision.disabled = true 
		
		is_sliding = true
		speedlines.visible = true
	
	if is_sliding:
		camera.fov = lerp(camera.fov, NORMAL_FOV - 10, 15.0 * delta)	
		head.position.y = lerp(head.position.y, OG_HEAD_Y - 0.8, 15.0 * delta)	
		control_ui.scale = lerp(control_ui.scale, Vector2(0.95, 0.95), 10.0 * delta)
	else:
		camera.fov = lerp(camera.fov, NORMAL_FOV, 20.0 * delta)	
		head.position.y = lerp(head.position.y, OG_HEAD_Y, 20.0 * delta)	
		control_ui.scale = lerp(control_ui.scale, Vector2(1.0, 1.0), 20.0 * delta)

	if Input.is_action_just_released("slide") and is_sliding:
		slide_collision.disabled = true 
		normal_collision.disabled = false 
	
		SPEED = NORMAL_SPEED

		is_sliding = false
		speedlines.visible = false
	
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	
	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	if cur_dashes == 0:
		if dash_timer.time_left == 0:
			dash_timer.start()

	if is_moving and Input.is_action_just_pressed("dash") and cur_dashes > 0 and not is_sliding:
		SPEED = DASH_SPEED
		is_dashing = true
		cur_dashes -= 1
		camera.fov = DASH_FOV
		control_ui.scale = Vector2(1.05, 1)

		dashing_time.start()
	
	if is_dashing:		
		SPEED = lerp(SPEED, NORMAL_SPEED, 8.0 * delta)
		camera.fov = lerp(camera.fov, NORMAL_FOV, delta-0.3)
		control_ui.scale = lerp(control_ui.scale, Vector2(1, 1),  delta - 0.4)
	
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	direction = lerp(direction, (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), 7.0 * delta)
	
	if direction:
		
		camera.h_offset = lerp(camera.h_offset, input_dir.x * 0.12, 7.0 * delta) 
		
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		
	else:
		
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	if position.y < -4.35:
		position = INIT_POS 
		shake_time.start()
	
	
	if shake_time.time_left > 0:
		camera.h_offset = randf_range(-0.02, 0.02)
		camera.v_offset = randf_range(-0.02, 0.02)
	else:
		if not direction:
			camera.h_offset = 0
			camera.v_offset = 0
		
	speed.value = get_real_velocity().length() * 3
	dashes_ui.text = "X".repeat(cur_dashes)
	hp_ui.text = str(hp) + "/100"
	
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	animation_player.play("RESET")
	
func _on_dash_refill_timer_timeout() -> void:
	
	if cur_dashes < MAX_DASHES:
		cur_dashes += 1
		dash_timer.start()

func _on_dash_time_timeout() -> void:
	is_dashing = false
	
	SPEED = NORMAL_SPEED
