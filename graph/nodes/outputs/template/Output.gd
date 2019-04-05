extends XGraphNode

onready var _preview = $PreviewFoldout/Preview
onready var _path_control = $Grid/InputControl
onready var _popup_button = $Grid/Button

var _file_dialog = FileDialog.new()
var _input = null


func _ready() -> void:
    _apply_changes()


func _apply_changes() -> void:
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
    _preview.texture = _input
