extends XGraphNode

onready var _viewport = $Viewport
onready var _texture = $Viewport/Texture
onready var _preview = $PreviewMargin/Preview

onready var _type_control = $Grid/TypeControl
onready var _scale_control = $Grid/ScaleControl
onready var _params_control = $Grid/ParamControl
onready var _offset_control = $Grid/OffsetControl
onready var _variant_control = $Grid/VariantControl

var _material = ShaderMaterial.new()
var _shader = preload("./cellular_noise_shader.shader")


#warning-ignore:unused_argument
func get_slot_value(slot: int):
    return _viewport.get_texture()


func get_data_dict() -> Dictionary:
    return {
        node_offset = var2str(offset),
        scale = _scale_control.value,
        type = _type_control.value,
        variant = _variant_control.value,
        offset = var2str(_offset_control.value),
        params = var2str(_params_control.value),
       }


func load_data(data: Dictionary) -> void:
    offset = str2var(data.node_offset)
    _scale_control.value = data.scale
    _type_control.value = data.type
    _variant_control.value = data.variant
    _offset_control.value = str2var(data.offset)
    _params_control.value = str2var(data.params)
    _apply_changes()


func _ready() -> void:
    var preview_toggle_control = $Grid/PreviewToggleButton
    preview_toggle_control.connect("toggled", self, "_preview_toggled")
    _type_control.connect("value_changed", self, "_on_control_value_changed")
    _scale_control.connect("value_changed", self, "_on_control_value_changed")
    _params_control.connect("value_changed", self, "_on_control_value_changed")
    _offset_control.connect("value_changed", self, "_on_control_value_changed")
    _variant_control.connect("value_changed", self, "_on_control_value_changed")
    _material.shader = _shader
    _texture.material = _material
    _apply_changes()


func _apply_changes():
    _material.set_shader_param("iType", _type_control.value)
    _material.set_shader_param("iScale", _scale_control.value)
    _material.set_shader_param("iOffset", _offset_control.value)
    _material.set_shader_param("iParams", _params_control.value)
    _material.set_shader_param("iVariant", _variant_control.value)
    _update_viewport()
    yield(_wait_for_shader(), "completed")
    _notify_changes()


func _preview_toggled(state):
    if state:
        $PreviewMargin.add_child(_preview)
    else:
        $PreviewMargin.remove_child(_preview)
    rect_size.y = 0


func _update_viewport():
    _viewport.render_target_update_mode = Viewport.UPDATE_ONCE
