extends XGraphNode

onready var _viewport = $Viewport
onready var _texture = $Viewport/Texture

var _material := ShaderMaterial.new()
var _shader := preload("./template_shader.shader")
var _input = null


#warning-ignore:unused_argument
func get_port_value(port: int) -> Object:
    return _viewport.get_texture()


func _ready() -> void:
    _material.shader = _shader
    _texture.material = _material
    _apply_changes()


func _apply_changes() -> void:
    _material.set_shader_param("iTexture", _input)
    _update_viewport()
    yield(_wait_for_shader(), "completed")
    _notify_changes()


#warning-ignore:unused_argument
func _input_disconnected(port: int) -> void:
    _input = null
    _apply_changes()


#warning-ignore:unused_argument
func _input_changed(port: int, value: Object = null) -> void:
    _input = value
    _apply_changes()


func _update_viewport() -> void:
    _viewport.render_target_update_mode = Viewport.UPDATE_ONCE
