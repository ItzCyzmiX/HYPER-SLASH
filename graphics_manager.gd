extends Control

var current_preset := "mid"
var current_window_size := "windowed"
const SAVE_PATH = "user://graphics.cfg"

const PRESETS := {
	"low": {
		"msaa"            : RenderingServer.VIEWPORT_MSAA_DISABLED,
		"fxaa"            : false,
		"shadow_atlas"    : 1024,
		"shadow_filter"   : RenderingServer.SHADOW_QUALITY_HARD,
		"ssao"            : false,
		"ssil"            : false,
		"ssr"             : false,
		"glow"            : false,
		"dof"             : false,
		"sdfgi"           : false,
		"scale_3d"        : 0.75,
		"scale_mode"      : Viewport.SCALING_3D_MODE_BILINEAR,
		"max_fps"         : 0,  # 0 = uncapped
	},
	"mid": {
		"msaa"            : RenderingServer.VIEWPORT_MSAA_2X,
		"fxaa"            : true,
		"shadow_atlas"    : 2048,
		"shadow_filter"   : RenderingServer.SHADOW_QUALITY_SOFT_LOW,
		"ssao"            : true,
		"ssil"            : false,
		"ssr"             : false,
		"glow"            : true,
		"dof"             : false,
		"sdfgi"           : false,
		"scale_3d"        : 1.0,
		"scale_mode"      : Viewport.SCALING_3D_MODE_BILINEAR,
		"max_fps"         : 0,
	},
	"high": {
		"msaa"            : RenderingServer.VIEWPORT_MSAA_4X,
		"fxaa"            : true,
		"shadow_atlas"    : 4096,
		"shadow_filter"   : RenderingServer.SHADOW_QUALITY_SOFT_HIGH,
		"ssao"            : true,
		"ssil"            : true,
		"ssr"             : true,
		"glow"            : true,
		"dof"             : true,
		"sdfgi"           : false,  # flip to true if you bake SDFGI
		"scale_3d"        : 1.0,
		"scale_mode"      : Viewport.SCALING_3D_MODE_BILINEAR,
		"max_fps"         : 0,
	},
}
func _load() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) == OK:
		var saved : String = cfg.get_value("graphics", "preset", "mid")
		var window_size : String = cfg.get_value("graphics", "window_size", "windowed")
		set_preset(saved)
	else:
		set_preset("mid")
		set_window_size('windowed')

func _save() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("graphics", "preset", current_preset)
	cfg.set_value("graphics", "window_size", current_window_size)
	cfg.save(SAVE_PATH)
	

func set_window_size(size: String) -> void:
	if size == "windowed":
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MINIMIZED)
		
		current_window_size = size
	elif size == "fullscreen":
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		
		current_window_size = size
	elif size == "borderless":
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_size(DisplayServer.screen_get_size())
	
		current_window_size = size
	
	_save()

func set_preset(preset: String) -> void:
	if not PRESETS.has(preset):
		push_error("GraphicsManager: unknown preset '%s'" % preset)
		return
	current_preset = preset
	_apply(PRESETS[preset])
	_save()

func get_preset():
	return PRESETS[current_preset]

func _apply(p):
	var vp := get_viewport()

	# Render scale
	vp.scaling_3d_scale = p["scale_3d"]
	vp.scaling_3d_mode  = p["scale_mode"]

	# AA
	vp.msaa_3d                          = p["msaa"]
	vp.screen_space_aa                  = (
		Viewport.SCREEN_SPACE_AA_FXAA if p["fxaa"]
		else Viewport.SCREEN_SPACE_AA_DISABLED
	)

	# Shadow atlas
	RenderingServer.directional_shadow_atlas_set_size(p["shadow_atlas"], true)

	# Shadow filter
	RenderingServer.directional_soft_shadow_filter_set_quality(p["shadow_filter"])
	RenderingServer.positional_soft_shadow_filter_set_quality(p["shadow_filter"])

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_load()

func _on_quality_list_item_selected(index: int) -> void:
	if index == 0:
		current_preset = "low"
	elif index == 1:
		current_preset = "mid"
	elif index == 2:
		current_preset = "high"
	
	set_preset(current_preset)
