extends WorldEnvironment

const DEFAULT_SUN_SCALE: float = 0.5
const DEFAULT_SUN_STRENGTH: float = 1.0


var sun_scale_property_path: String = "environment/sky/sky_material/shader/shader_parameter/sun_scale"
var sun_strength_property_path: String = "environment/sky/sky_material/shader/shader_parameter/sun_strength"



func _ready() -> void:
	connect_signals()
	

func connect_signals()-> void:
	SignalBus.connect_signal(self, "tween_sun_scale")
	SignalBus.connect_signal(self, "tween_sun_strength")


func _on_tween_sun_scale(target_value: float, duration: float = 4.0) -> void:
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, sun_scale_property_path, target_value, duration)

func _on_tween_sun_strength(target_value: float, duration: float = 4.0) -> void:
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, sun_strength_property_path, target_value, duration)
