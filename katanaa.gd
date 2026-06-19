extends Node3D

var COLOR = "a30f00"
@onready var area = $area

func set_color(color):
	var mat = $Cube_004.get_surface_override_material(0)
	mat.albedo_color =  Color(color)
	mat.emission_enabled = true
	mat.emission = Color(color)
	mat.emission_energy_multiplier = 1.5
	COLOR = color 
	$Cube_004.set_surface_override_material(0, mat)

func get_color():
	return COLOR
	

func check_collision():
	var nodes = []
	for node in area.get_overlapping_bodies():
		if node.is_in_group("hittable"):
			nodes.append(node)
		
	return nodes
