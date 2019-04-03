extends Spatial

func set_heightmap(texture: Texture):
    $MeshInstance.material_override.set_shader_param("heightmap", texture)

func set_terrain_size(size: Vector2):
    if $MeshInstance.terrain_size != size.x:
        $MeshInstance.terrain_size = size.x
        $MeshInstance.generate_mesh()
        print("Regenerating mesh...")
    $MeshInstance.material_override.set_shader_param("terrain_size", size)

func set_terrain_subdivisions(amount: int):
    $MeshInstance.terrain_subdivisions = amount
    $MeshInstance.generate_mesh()
    $MeshInstance.material_override.set_shader_param("terrain_subdivisions", amount)