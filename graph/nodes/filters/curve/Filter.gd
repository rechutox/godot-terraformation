extends XGraphNode

onready var _viewport = $Viewport
onready var _texture = $Viewport/Texture
onready var _curve_control = $CurveEditor

var _material := ShaderMaterial.new()
var _shader := preload("./Filter.shader")
var _input = null


func curve2gradient(curve: Curve, resolution = 100) -> Gradient:
    var gradient = Gradient.new()
    curve.bake_resolution = resolution
    curve.bake()
    for i in range(resolution):
        var t = float(i) / float(resolution)
        var v = curve.interpolate_baked(t)
        gradient.add_point(t, Color(v, v, v, 1.0))
    return gradient


#warning-ignore:unused_argument
func get_port_value(port: int) -> Object:
    return _viewport.get_texture()


func _ready() -> void:
    $PreviewFoldout.connect("fold_changed", self, "_on_foldout_changed")
    _curve_control.connect("value_changed", self, "_on_control_value_changed")
    _material.shader = _shader
    _texture.material = _material
    _apply_changes()


func _apply_changes() -> void:
    var gradient = curve2gradient(_curve_control.get_curve(), 512)
    var gradient_tex = GradientTexture.new()
    gradient_tex.gradient = gradient
    _material.set_shader_param("iTexture", _input)
    _material.set_shader_param("iGradient", gradient_tex)
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
        param1 = _curve_control.get_data_dict(),
       }


func load_data(data: Dictionary) -> void:
    offset = str2var(data.node_offset)
    $PreviewFoldout.is_folded = data.preview_folded
    _curve_control.load_data(data.param1)
