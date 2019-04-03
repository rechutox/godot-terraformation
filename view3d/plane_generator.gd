tool
extends MeshInstance

export var terrain_size = 5.0
export var terrain_subdivisions = 5
export var generate = false setget _set_generate


func _set_generate(val):
    generate = false
    generate_mesh()


func generate_mesh():
    var st = SurfaceTool.new()

    st.begin(Mesh.PRIMITIVE_TRIANGLES)

    var sw = terrain_size / float(terrain_subdivisions)
    var sh = terrain_size / float(terrain_subdivisions)

    var w = sw
    var h = (sqrt(3.0) / 2.0) * sw
    var max_x = ceil(terrain_size / w) * 2.0 #terrain_subdivisions * 2 + 1
    var max_z = ceil(terrain_size / h) #terrain_subdivisions + 1

    for z in range(max_z):
        for x in range(max_x):
            _even(st, x, z, w, h, max_x, max_z)
            if (x + z) % 2 == 0:
                _even_index(st, x, z, w, h, max_x, max_z)
            else:
                _odd_index(st, x, z, w, h, max_x, max_z)

    st.generate_tangents()
    mesh = st.commit()

    translation = Vector3(-terrain_size * 0.5, 0.0, -terrain_size * 0.5)


func _even(st, x, z, size_x, size_z, max_x, max_z):
    var _x = x * size_x * 0.5
    var _z = z * size_z
    st.add_normal(Vector3.UP)
    st.add_uv(Vector2(_x / terrain_size, _z / terrain_size))
    st.add_uv2(Vector2(_x / terrain_size, _z / terrain_size))
    st.add_vertex(Vector3(_x, 0.0, _z))


func _even_index(st, x, z, size_x, size_z, max_x, max_z):
    if x >= max_x - 1: return
    if z >= max_z - 1: return
    st.add_index(x + z * max_x)
    st.add_index(x + z * max_x + 1)
    st.add_index(x + (z + 1) * max_x + 1)

    st.add_index(x + z * max_x)
    st.add_index(x + (z + 1) * max_x + 1)
    st.add_index(x + (z + 1) * max_x)


func _odd_index(st, x, z, size_x, size_z, max_x, max_z):
    if x >= max_x - 1: return
    if z >= max_z - 1: return
    st.add_index(x + z * max_x)
    st.add_index(x + z * max_x + 1)
    st.add_index(x + (z + 1) * max_x)

    st.add_index(x + z * max_x + 1)
    st.add_index(x + (z + 1) * max_x + 1)
    st.add_index(x + (z + 1) * max_x)
