extends Control

signal value_changed

var use_snap = false
var snap_step = 0.05

var _curve: Curve
var _points = []


func interpolate(t: float) -> float:
    return _curve.interpolate(t)


func get_curve() -> Curve:
    if _curve == null:
        _curve = Curve.new()
    return _curve


func set_curve(curve: Curve) -> void:
    _points.clear()
    for i in range(curve.get_point_count()):
        _add_point(curve.get_point_position(i),
            curve.get_point_left_tangent(i),
            curve.get_point_right_tangent(i))
    _sort_points()
    update()


func _ready() -> void:
    update()


func _add_point(position: Vector2, left = 0.0, right = 0.0) -> Object:
    var point = {
        position = position,
        left = left,
        right = right,
        is_hovered = false,
        is_left_hovered = false,
        is_right_hovered = false,
        is_dragged = false,
        is_left_dragged = false,
        is_right_dragged = false,
       }
    _points.append(point)
    _sort_points()
    #print("Point added at [%.2f, %.2f]" % [position.x, position.y])
    update()
    return point


func _gui_input(event: InputEvent) -> void:
    if event is InputEventMouse:
        var rel = event.position / rect_size
        rel.y = 1.0 - rel.y
        var pos = rel * rect_size

        var is_over_a_point = false
        for i in range(_points.size()):
            var point = _points[i]
            var p = point.position * rect_size
            var l = p + _get_left_pos(point)
            var r = p + _get_right_pos(point)
            var dist = pos.distance_to(p)
            var dist_l = pos.distance_to(l)
            var dist_r = pos.distance_to(r)
            var is_in_range = dist <= 20.0
            var is_in_range_with_left = dist_l <= 20.0
            var is_in_range_with_right = dist_r <= 20.0
            point.is_hovered = is_in_range
            point.is_left_hovered = is_in_range_with_left
            point.is_right_hovered = is_in_range_with_right

            if event is InputEventMouseButton:
                if event.button_index == 1:
                    point.is_dragged = event.pressed and is_in_range
                    point.is_left_dragged = event.pressed and is_in_range_with_left
                    point.is_right_dragged = event.pressed and is_in_range_with_right
                if event.button_index == 2:
                    if is_in_range:
                        _points.remove(i)
                        break

            if event is InputEventMouseMotion:
                if event.button_mask == BUTTON_MASK_LEFT:
                    if point.is_dragged:
                        point.position = rel
                        if use_snap or Input.is_key_pressed(KEY_CONTROL):
                            point.position = point.position.snapped(Vector2(snap_step, snap_step))
                        point.position.x = clamp(point.position.x, 0.0, 1.0)
                        point.position.y = clamp(point.position.y, 0.0, 1.0)
                    elif point.is_left_dragged:
                        var angle = p.angle_to_point(pos)
                        if Input.is_key_pressed(KEY_CONTROL):
                            angle = stepify(angle, deg2rad(15.0))
                        point.left = angle
                        if Input.is_key_pressed(KEY_SHIFT):
                            point.right = angle
                    elif point.is_right_dragged:
                        var angle = pos.angle_to_point(p)
                        if Input.is_key_pressed(KEY_CONTROL):
                            angle = stepify(angle, deg2rad(15.0))
                        point.right = angle
                        if Input.is_key_pressed(KEY_SHIFT):
                            point.left = angle

            if is_in_range or is_in_range_with_left or is_in_range_with_right:
                is_over_a_point = true


        if not is_over_a_point:
            if event is InputEventMouseButton:
                if event.pressed:
                    var point = _add_point(rel)
                    point.is_dragged = true

        update()


func _draw() -> void:
    var size = rect_size

    _curve = Curve.new()
    _curve.min_value = 0.0
    _curve.max_value = 1.0

    # add the points to the curve
    for point in _points:
        _curve.add_point(point.position, point.left, point.right)

    _curve.bake() # bake the curve

    # plot the curve
    var last = Vector2(0.0, _curve.interpolate(0.0));
    for i in range(_curve.bake_resolution):
        var x = float(i) / _curve.bake_resolution
        var y = 1.0 - _curve.interpolate(x)
        var pos = Vector2(x * size.x, y * size.y)
        draw_line(last, pos, Color.white, 1.0, true)
        last = pos

    # and plot point positions and tangents controllers
    for point in _points:
        var pos = Vector2(point.position.x, 1.0 - point.position.y) * size
        var left_pos = _get_left_pos(point)
        left_pos = pos + Vector2(left_pos.x, - left_pos.y)
        var right_pos = _get_right_pos(point)
        right_pos = pos + Vector2(right_pos.x, - right_pos.y)
        var color = Color.red if point.is_dragged else Color.yellow if point.is_hovered else Color.white
        var color_left = Color.red if point.is_left_dragged else Color.yellow if point.is_left_hovered else Color.green
        var color_right = Color.red if point.is_right_dragged else Color.yellow if point.is_right_hovered else Color.green

        draw_line(pos, left_pos, Color.blue, 1.0, true)
        draw_line(pos, right_pos, Color.blue, 1.0, true)
        draw_circle(pos, 5.0, color)
        draw_circle(left_pos, 3.0, color_left)
        draw_circle(right_pos, 3.0, color_right)

    emit_signal("value_changed")

func _get_left_pos(point):
    return Vector2(-1.0, 0.0).rotated(point.left) * 30.0 * (rect_size.x / rect_size.y)


func _get_right_pos(point):
    return Vector2(1.0, 0.0).rotated(point.right) * 30.0 * (rect_size.x / rect_size.y)


func _sort_points():
    var count = _points.size()
    for i in range(count):
        for j in range(i + 1, count - 1):
            if _points[i].position.x > _points[j].position.x:
                var c = _points[i]
                _points[i] = _points[j]
                _points[j] = c
