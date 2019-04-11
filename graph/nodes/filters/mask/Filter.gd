extends XGraphNode

onready var _viewport = $Viewport
onready var _texture = $Viewport/Texture
onready var _blend_control = $Grid/BlendControl

var _material := ShaderMaterial.new()
var _shader := preload("./Filter.shader")
var _input_a = null
var _input_b = null


#warning-ignore:unused_argument
func get_port_value(port: int) -> Object:
    return _viewport.get_texture()


func _ready() -> void:
    $PreviewFoldout.connect("fold_changed", self, "_on_foldout_changed")
    _blend_control.connect("value_changed", self, "_on_control_value_changed")
    _material.shader = _shader
    _texture.material = _material
    _apply_changes()


func _apply_changes() -> void:
    _material.set_shader_param("iTextureA", _input_a)
    _material.set_shader_param("iTextureB", _input_b)
    _material.set_shader_param("iBlend", _blend_control.value)
    _update_viewport()
    yield(_wait_for_shader(), "completed")
    _notify_changes()


#warning-ignore:unused_argument
func _input_disconnected(port: int) -> void:
    if port == 0:
        _input_a = null
    if port == 1:
        _input_b = null
    _apply_changes()


#warning-ignore:unused_argument
func _input_changed(port: int, value: Object = null) -> void:
    if port == 0:
        _input_a = value
    elif port == 1:
        _input_b = value
    _apply_changes()


func _update_viewport() -> void:
    _viewport.render_target_update_mode = Viewport.UPDATE_ONCE


func _on_foldout_changed(state):
    rect_size.y = 0


func get_data_dict() -> Dictionary:
    return {
        node_offset = var2str(offset),
        preview_folded = $PreviewFoldout.is_folded,
        param1 = _blend_control.value,
       }


func load_data(data: Dictionary) -> void:
    offset = str2var(data.node_offset)
    $PreviewFoldout.is_folded = data.preview_folded
    _blend_control.value = data.param1
