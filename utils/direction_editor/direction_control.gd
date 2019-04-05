tool
extends Control

signal value_changed

export(Color) var color setget _set_color
export var angle = 0.0 setget _set_angle
export var line_width = 1.0 setget _set_line_width
export var circle_margin = 0.0 setget _set_circle_margin

var _is_dragging = false


func get_vector():
    return Vector2.RIGHT.rotated(angle)


func get_radians():
    return angle


func get_degrees():
    return rad2deg(angle);


func _ready() -> void:
    update()


func _draw() -> void:
    var half_size = rect_size * 0.5
    var radius = min(half_size.x, half_size.y) - line_width * 0.5 - circle_margin
    _draw_circle_arc(half_size, radius, 0.0, 360.0, color, line_width, true)
    draw_circle(half_size, radius * 0.1, color)
    var dir = get_vector()
    draw_line(half_size, half_size + dir * radius, color, line_width, true)


func _gui_input(event: InputEvent) -> void:
    if event is InputEventMouse:
        var pos = event.position
        if event is InputEventMouseButton:
            _is_dragging = event.pressed
        if _is_dragging:
            var ang = pos.angle_to_point(rect_size * 0.5)
            if Input.is_key_pressed(KEY_CONTROL):
                ang = stepify(ang, deg2rad(15.0))
            self.angle = ang


func _set_color(val):
    color = val
    update()


func _set_angle(val):
    angle = val
    emit_signal("value_changed", angle)
    update()


func _set_line_width(val):
    line_width = val
    update()

func _set_circle_margin(val):
    circle_margin = val
    update()

func _draw_circle_arc(center, radius, angle_from, angle_to, color, width = 1.0, antialias = true):
    var nb_points = 48
    var points_arc = PoolVector2Array()

    for i in range(nb_points + 1):
        var angle_point = deg2rad(angle_from + i * (angle_to-angle_from) / nb_points - 90)
        points_arc.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * radius)

    for index_point in range(nb_points):
        draw_line(points_arc[index_point], points_arc[index_point + 1], color, width, antialias)
