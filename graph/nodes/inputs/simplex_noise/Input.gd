extends XGraphNode

onready var _viewport = $Viewport
onready var _texture = $Viewport/Texture

onready var _scale_control = $Grid/ScaleControl
onready var _offset_control = $Grid/OffsetControl

var _shader = preload("./Input.shader")
var _material = ShaderMaterial.new()


#warning-ignore:unused_argument
func get_port_value(port: int):
    return _viewport.get_texture()


func get_data_dict() -> Dictionary:
    return {
        node_offset = var2str(offset),
        preview_folded = $PreviewFoldout.is_folded,
        scale = _scale_control.value,
        offset = var2str(_offset_control.value),
       }


func load_data(data: Dictionary) -> void:
    offset = str2var(data.node_offset)
    $PreviewFoldout.is_folded = data.preview_folded
    _scale_control.value = data.scale
    _offset_control.value = str2var(data.offset)
    _apply_changes()


func _ready() -> void:
    $PreviewFoldout.connect("fold_changed", self, "_on_foldout_changed")
    _scale_control.connect("value_changed", self, "_on_control_value_changed")
    _offset_control.connect("value_changed", self, "_on_control_value_changed")
    _material.shader = _shader
    _texture.material = _material
    _apply_changes()


func _apply_changes():
    _material.set_shader_param("iScale", _scale_control.value)
    _material.set_shader_param("iOffset", _offset_control.value)
    _update_viewport()
    yield(_wait_for_shader(), "completed")
    _notify_changes()


func _on_foldout_changed(state):
    rect_size.y = 0


func _update_viewport():
    _viewport.render_target_update_mode = Viewport.UPDATE_ONCE
