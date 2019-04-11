extends ColorRect

signal value_changed

export(Curve) var curve setget _set_curve


func interpolate(t: float) -> float:
    return $Margin3/Curve.interpolate(t)


func get_curve() -> Curve:
    return $Margin3/Curve.get_curve()


func _ready() -> void:
    if curve == null:
        var _curve = Curve.new()
        _curve.add_point(Vector2(0.0, 0.0))
        _curve.add_point(Vector2(1.0, 1.0))
        _set_curve(_curve)
    $Margin3/Curve.connect("value_changed", self, "_on_value_changed")


func _set_curve(val) -> void:
    curve = val
    $Margin3/Curve.set_curve(val)


func _on_value_changed() -> void:
    emit_signal("value_changed", curve)


func get_data_dict() -> Dictionary:
    return {
        curve = var2str(get_curve())
       }

func load_data(data: Dictionary) -> void:
    self.curve = str2var(data.curve)
