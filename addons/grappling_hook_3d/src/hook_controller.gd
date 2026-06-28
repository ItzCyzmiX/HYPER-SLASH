class_name HookController
extends Node
## Node that is responsible for managing the hook, and the hook interface.


@export_category("Hook Controller")
@export_group("Required Settings")
@export var hook_raycast: RayCast3D
## Usually the parent of the player's scene
@export var player_body: CharacterBody3D
## Input Map action name that triggers hook's launch
@export var launch_action_name: String
## Input Map action name that triggers hook's retraction
@export var retract_action_name: String
@export_group("Optional Settings")
@export var pull_speed: float = 20.0
## A 3D node that serves as the beginning on the rope model
@export var hook_source: Node3D
## How stiff the rope is — higher snaps back to the radius harder, lower feels more elastic
@export var rope_stiffness: float = 0.5

@export_group("Advanced Settings")
@export var hook_scene: PackedScene = preload("res://addons/grappling_hook_3d/src/hook.tscn")

var is_hook_launched: bool = false
var _hook_model: Node3D = null
var _held: bool = false
var hook_target_normal: Vector3 = Vector3.ZERO
var hook_target_node: Marker3D = null
var rope_length: float = 0.0


signal hook_launched()
signal hook_attached(body)
signal hook_detached()


func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("grapple"):
		_held = true

	if Input.is_action_just_released("grapple"):
		_held = false
		if is_hook_launched:
			_retract_hook()

	# Keep trying to launch every frame while held and not yet hooked
	if _held and not is_hook_launched:
		_launch_hook()

	if is_hook_launched:
		_handle_hook(delta)

		if Input.is_action_just_pressed("jump"):
			player_body.velocity.y += player_body.JUMP_VELOCITY
			_retract_hook()

## Attaches a Marker3D to the body that is in the way of the raycast.
## Enables the hook, emits proper signals.
func _launch_hook() -> void:
	if not hook_raycast.is_colliding():
		return
	
	is_hook_launched = true
	
	hook_attached.emit()
	
	
	var body: Node3D = hook_raycast.get_collider()
	
	hook_target_node = Marker3D.new()
	body.add_child(hook_target_node)
	hook_target_node.global_position = hook_raycast.get_collision_point()
	
	# Lock in the rope length at the moment of attachment
	rope_length = player_body.global_position.distance_to(hook_target_node.global_position)
	
	hook_target_normal = hook_raycast.get_collision_normal()
	
	_hook_model = hook_scene.instantiate()
	add_child(_hook_model)

## Disables the hook, frees the target node and the hook model, emits required signals.
func _retract_hook() -> void:
	is_hook_launched = false
	if is_instance_valid(hook_target_node):
		hook_target_node.queue_free()
	
	_hook_model.queue_free()
	_held = false
	hook_detached.emit()


func _handle_hook(delta: float) -> void:
	if not is_instance_valid(hook_target_node) or not is_instance_valid(_hook_model):
		_retract_hook()
		return
	
	var anchor: Vector3 = hook_target_node.global_position
	var to_player: Vector3 = player_body.global_position - anchor
	var distance: float = to_player.length()
	
	if distance > 0.001:
		var rope_dir: Vector3 = to_player / distance
		
		# Only constrain once the rope is taut (player past rope_length).
		# This lets the player swing freely while inside the radius.
		if distance > rope_length:
			# Strip out the radial (outward) component of velocity, keep tangential —
			# this is what produces the swing instead of a stop/snap.
			var radial_speed: float = player_body.velocity.dot(rope_dir)
			if radial_speed > 0.0:
				player_body.velocity -= rope_dir * radial_speed
			
			# Pull the player back onto the rope's radius (soft correction, not a hard snap)
			var overshoot: float = distance - rope_length
			player_body.global_position = lerp(player_body.global_position, player_body.global_position-rope_dir * overshoot * rope_stiffness, 15.0 * delta)
	
	# Optional: let the player reel in/out with input, e.g. shorten rope_length over time
	rope_length = max(rope_length - pull_speed * delta, 1.0)
	# Hook model handling
	var source_position: Vector3 = hook_source.global_position if hook_source else player_body.global_position
	_hook_model.extend_from_to(source_position, hook_target_node.global_position, hook_target_normal)
