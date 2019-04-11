extends XGraphNode

onready var _viewport = $Viewport
onready var _texture = $Viewport/Texture
onready var _control1 = $Grid/InputControl
onready var _control2 = $Grid/InputControl_2
onready var _control3 = $Grid/InputControl_3
onready var _control4 = $Grid/InputControl_4
onready var _control5 = $Grid/InputControl_5
onready var _control6 = $Grid/InputControl_6

var _material := ShaderMaterial.new()
var _shader := preload("./Filter.shader")
var _input = null


#warning-ignore:unused_argument
func get_port_value(port: int) -> Object:
    return _viewport.get_texture()


func _ready() -> void:
    $PreviewFoldout.connect("fold_changed", self, "_on_foldout_changed")
    _control1.connect("value_changed", self, "_on_control_value_changed")
    _control2.connect("value_changed", self, "_on_control_value_changed")
    _control3.connect("value_changed", self, "_on_control_value_changed")
    _control4.connect("value_changed", self, "_on_control_value_changed")
    _control5.connect("value_changed", self, "_on_control_value_changed")
    _control6.connect("value_changed", self, "_on_control_value_changed")
    _material.shader = _shader
    _texture.material = _material
    _apply_changes()


func _apply_changes() -> void:
    _material.set_shader_param("iTexture", _input)
    _material.set_shader_param("iMinHeight", _control1.value)
    _material.set_shader_param("iMaxHeight", _control2.value)
    _material.set_shader_param("iFalloffMin", _control3.value)
    _material.set_shader_param("iFalloffMax", _control4.value)
    _material.set_shader_param("iFalloffMinExp", _control5.value)
    _material.set_shader_param("iFalloffMaxExp", _control6.value)
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


func _on_foldout_changed(state):
    rect_size.y = 0


func get_data_dict() -> Dictionary:
    return {
        node_offset = var2str(offset),
        preview_folded = $PreviewFoldout.is_folded,
        param1 = _control1.value,
        param2 = _control2.value,
        param3 = _control3.value,
        param4 = _control4.value,
        param5 = _control5.value,
        param6 = _control6.value,
       }


func load_data(data: Dictionary) -> void:
    offset = str2var(data.node_offset)
    $PreviewFoldout.is_folded = data.preview_folded
    _control1.value = data.param1
    _control2.value = data.param2
    _control3.value = data.param3
    _control4.value = data.param4
    _control5.value = data.param5
    _control6.value = data.param6
