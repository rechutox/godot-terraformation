extends Spatial

var _yaw := 0.0
var _pitch := 0.0
var _zoom := 15.0


func get_pivot_pos():
    return global_transform.origin + global_transform.basis.z * _zoom


func _ready() -> void:
    var pivot_pos = get_pivot_pos()
    var dir = pivot_pos - global_transform.origin
    _yaw = rad2deg(cos(dir.x))
    _pitch = rad2deg(sin(dir.y))


var relative = Vector2()
var left_pressed = false

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouse:

        if event is InputEventMouseMotion:
            relative = event.relative

        if event is InputEventMouseButton:
            if event.pressed == true:
                Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
                left_pressed = event.button_index == BUTTON_LEFT
            else:
                Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
                left_pressed = false


func _process(delta: float) -> void:
    if left_pressed:
        var pivot_pos = get_pivot_pos()
        var diff = pivot_pos - global_transform.origin
        _yaw -= relative.x * 0.1
        relative.x = 0.0
        translation.x = pivot_pos.x + cos(_yaw) * _zoom
        translation.z = pivot_pos.y + sin(_yaw) * _zoom
        translation.y = diff.y
        #look_at(pivot_pos, Vector3.UP)
        #rotation_degrees.y = _yaw
    #rotation_degrees.x = _pitch
