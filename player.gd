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
@onready var pause_vhs: TextureRect = $"../../../pause_filter"
@onready var flash: ColorRect = $"../../../flash"
@onready var trail: GPUTrail3D = $Head/hand/trail
@onready var katana_model: Node3D = $Head/hand/katana/katan_model
@onready var shader_spawn: Marker3D = $Head/shader_spawn

var SHAKE_INTENSITY = 2
var is_attacking = false
var hp = 100
var is_blocking = false
var BLOCK_SPEED = 3.0
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
var QUAD_POS = Vector3(0.0, 0.123, -0.781)
func _enter_tree() -> void:
	set_multiplayer_authority(str(name).to_int())
	
func _ready() -> void:
	change_trail_color(Globals.TRAIL_COLOR)
	katana_model.set_color(Globals.SWORD_COLOR)

	OG_HEAD_Y = head.position.y
	INIT_POS = position

	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event: InputEvent) -> void:

	if Globals.PAUSED: return 
	
	if event is InputEventMouseMotion:

		rotate_y(-deg_to_rad(event.relative.x * SENS))
		head.rotate_x(-deg_to_rad(event.relative.y * SENS))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-60), deg_to_rad(60))
	
	if event.is_action_pressed("attack"):
	
		if not is_blocking:
			animation_player.stop()
			
			animation_player.play("slash1")
				
			is_attacking = true
			
		
	if event.is_action_pressed("block"):
		if animation_player.is_playing():
			animation_player.stop()
			
		animation_player.play("block")
		is_blocking = true



func _physics_process(delta: float) -> void:
	
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			pause_vhs.visible = true
			Globals.PAUSED = true
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
		else:
			pause_vhs.visible = false
			Globals.PAUSED = false
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	if Globals.PAUSED: return
	print(is_attacking)
	move_and_slide()

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
	
	if is_blocking:
		is_dashing = false 
		is_sliding = false
		SPEED = BLOCK_SPEED
	
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
		speedlines.visible = false
		camera.fov = lerp(camera.fov, NORMAL_FOV, 20.0 * delta)	
		head.position.y = lerp(head.position.y, OG_HEAD_Y, 20.0 * delta)	
		control_ui.scale = lerp(control_ui.scale, Vector2(1.0, 1.0), 20.0 * delta)

	if Input.is_action_just_released("slide") and is_sliding:
		slide_collision.disabled = true 
		normal_collision.disabled = false 
	
		SPEED = NORMAL_SPEED

		is_sliding = false

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
		shake_time.wait_time = 0.1
		SHAKE_INTENSITY = 2
		shake_time.start()
	
	
	if shake_time.time_left > 0:
		camera.h_offset = randf_range(-SHAKE_INTENSITY * 0.01, SHAKE_INTENSITY *0.01)
		camera.v_offset = randf_range(-SHAKE_INTENSITY * 0.01, SHAKE_INTENSITY *0.01)
	else:
		if not direction:
			camera.h_offset = 0
			camera.v_offset = 0
		
	speed.value = get_real_velocity().length() * 3
	dashes_ui.text = "X".repeat(cur_dashes)
	hp_ui.text = str(hp) + "/100"
	
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	animation_player.play("RESET")
	if anim_name == "slash1":
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

func spawn_shader():
	var exists = head.get_node_or_null("post_shader") != null
	if exists: return
	var quad = preload("res://post_shader.tscn").instantiate()
	quad.global_position = shader_spawn.global_position
	quad.name = "post_shader"
	head.add_child(quad)

func remove_shader():
	var quad = head.get_node_or_null("post_shader") 
	if quad:
		quad.queue_free()


func _on_trail_color_picker_color_changed(color: Color) -> void:
	change_trail_color(color.to_html())

func _on_sword_color_picker_color_changed(color: Color) -> void:
	katana_model.set_color(color)

func _on_check_trail_toggled(toggled_on: bool) -> void:
	trail.visible = toggled_on

func _on_check_shaders_toggled(toggled_on: bool) -> void:
	if toggled_on:
		spawn_shader()
	else:
		remove_shader()
