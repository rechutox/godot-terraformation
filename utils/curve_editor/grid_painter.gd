tool
extends Control

export var mayor_subdivisions = 10 setget _set_mayor_subdivisions
export var minor_subdivisions = 5 setget _set_minor_subdivisions
export var mayor_color = Color(0.3, 0.3, 0.3) setget _set_mayor_color
export var minor_color = Color(0.2, 0.2, 0.2) setget _set_minor_color


func _draw() -> void:
    var rect_size = get_rect().size
    var size = rect_size / (mayor_subdivisions * minor_subdivisions)
    for i in range(mayor_subdivisions * minor_subdivisions + 1):
        var minor_mayor = i % minor_subdivisions == 0
        var color = mayor_color if minor_mayor else minor_color
        var x = i * size.x
        var y = i * size.y
        draw_line(Vector2(x, 0.0), Vector2(x, rect_size.y), color, 1.0, false)
        draw_line(Vector2(0.0, y), Vector2(rect_size.x, y), color, 1.0, false)


func _set_mayor_subdivisions(val):
    mayor_subdivisions = val
    update()

func _set_minor_subdivisions(val):
    minor_subdivisions = val
    update()

func _set_mayor_color(val):
    mayor_color = val
    update()

func _set_minor_color(val):
    minor_color = val
    update()
