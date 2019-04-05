tool
extends Control

export var min_value = 0.0 setget _set_min
export var max_value = 1.0 setget _set_max
export var subdivisions = 5 setget _set_subdiv
export(Font) var label_font

func _draw() -> void:
    var size = get_rect().size
    draw_line(Vector2(0.0, size.y), Vector2(size.x, size.y), Color.white, 3.0)
    draw_line(Vector2(0.0, 0.0), Vector2(0.0, size.y), Color.white, 3.0)

    for i in range(subdivisions, -1, -1):
        var xv = 1.0 / subdivisions * (subdivisions - i)
        var yv = 1.0 / subdivisions * i
        var y = i * size.y / subdivisions
        var x = i * size.x / subdivisions
        _draw_htick(Vector2(0.0, y), xv)
        _draw_vtick(Vector2(x, size.y), yv)

    #_draw_htick(Vector2(0.0, size.y * 0.5), "0.5")
    #_draw_htick(Vector2(0.0, size.y), "0")

    #_draw_vtick(Vector2(0.0, size.y), "0")
    #_draw_vtick(Vector2(size.x * 0.5, size.y), "0.5")
    #_draw_vtick(Vector2(size.x, size.y), "1")

func _draw_htick(pos: Vector2, label: float):
    draw_line(pos - Vector2(10.0, 0.0), pos, Color.white, 2.0)
    var l = "%.1f" % label
    var s = label_font.get_string_size(l)
    draw_string(label_font, pos + Vector2(-s.x - 15.0, s.y * 0.3), l, Color.white)

func _draw_vtick(pos: Vector2, label: float):
    draw_line(pos + Vector2(0.0, 10.0), pos, Color.white, 2.0)
    var l = "%.1f" % label
    var s = label_font.get_string_size(l)
    draw_string(label_font, pos + Vector2(-s.x * 0.5, s.y + 10.0), l, Color.white)

func _set_min(val):
    min_value = val
    update()

func _set_max(val):
    max_value = val
    update()

func _set_subdiv(val):
    subdivisions = val
    update()
