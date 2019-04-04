extends XGraphNode

var _input = null


#warning-ignore:unused_argument
func get_port_value(port: int) -> Object:
    return _input


func _ready() -> void:
    _apply_changes()


func _apply_changes() -> void:
    _notify_changes()


#warning-ignore:unused_argument
func _input_disconnected(port: int) -> void:
    _input = null
    _apply_changes()


#warning-ignore:unused_argument
func _input_changed(port: int, value: Object = null) -> void:
    _input = value
    _apply_changes()
