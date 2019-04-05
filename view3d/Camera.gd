extends Spatial

onready var _pivot := $Pivot
onready var _camera := $Pivot/Camera

var _yaw := 0.0
var _pitch := 0.0
var _zoom := 15.0
var _min_zoom := 5.0
var _fps_cam := false
var _last_zoom := 0.0
var _last_mouse_pos := Vector2()
var _mouse_captured := false
var _relative := Vector2()
var _left_pressed := false
var _middle_pressed := false
var _right_pressed := false


func _ready() -> void:
    _yaw = rotation_degrees.y
    _pitch = _pivot.rotation_degrees.x
    _zoom = _camera.translation.z


func _input(event: InputEvent) -> void:
    if event is InputEventMouse:
        var inside = get_viewport().get_visible_rect().has_point(event.global_position)

        if event is InputEventMouseButton:
            if inside and event.pressed:
                _last_mouse_pos = get_tree().root.get_mouse_position()
                Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
                _mouse_captured = true
            else:
                if _mouse_captured:
                    Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
                    get_tree().root.warp_mouse(_last_mouse_pos)
                _mouse_captured = false

            _left_pressed = _mouse_captured and event.pressed and event.button_index == BUTTON_LEFT
            _right_pressed = _mouse_captured and event.pressed and event.button_index == BUTTON_RIGHT
            _middle_pressed = _mouse_captured and event.pressed and event.button_index == BUTTON_MIDDLE

        if event is InputEventMouseMotion and _mouse_captured:
            _relative = event.relative


func _process(delta: float) -> void:
    var wheel = Input.get_action_strength("zoom+") - Input.get_action_strength("zoom-")

    # Orbit
    if _left_pressed:
        _yaw -= _relative.x * delta * 3.0
        _pitch -= _relative.y * delta * 3.0
    # FPS
    elif _right_pressed:
        if _fps_cam == false:
            global_transform.origin = _camera.global_transform.origin
            _last_zoom = _zoom
            _zoom = 0
            _fps_cam = true
        _yaw -= _relative.x * delta * 3.0
        _pitch -= _relative.y * delta * 3.0
    else:
        if _fps_cam == true:
            global_transform.origin = _camera.global_transform.origin - _camera.global_transform.basis.z * _last_zoom
            _zoom = _last_zoom
        _fps_cam = false

    # Pan
    if _middle_pressed:
        var quat = Quat()
        quat.set_euler(Vector3(deg2rad(_pitch), deg2rad(_yaw), 0.0))
        global_translate(quat * Vector3(-_relative.x, _relative.y, 0.0) * delta)

    if not _fps_cam:
        _zoom = max(_min_zoom, _zoom + wheel * 10.0 * delta)

    _relative.x = 0
    _relative.y = 0
    rotation_degrees.y = _yaw
    _pivot.rotation_degrees.x = _pitch
    _camera.translation.z = _zoom

    var input = Vector3()
    input.z = Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")
    input.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
    input.y = Input.get_action_strength("move_up") - Input.get_action_strength("move_down")
    input = input.normalized()
    var quat = Quat()
    quat.set_euler(Vector3(deg2rad(_pitch), deg2rad(_yaw), 0.0))
    global_translate(quat * input * 10.0 * delta)
