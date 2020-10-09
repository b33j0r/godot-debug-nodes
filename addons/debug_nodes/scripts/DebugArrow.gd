tool
extends DebugSpatial

export(Vector3) var vector = Vector3.FORWARD setget set_vector
export(Color) var color = Color.red setget set_color
export(float) var shaft_radius = 0.025 setget set_shaft_radius
export(float) var tip_ratio = 3.0 setget set_tip_ratio

onready var pivot: Spatial = $Pivot
onready var shaft: MeshInstance = $Pivot/Shaft
onready var tip: MeshInstance = $Pivot/Shaft/Tip

func set_vector(value):
	vector = value
	call_deferred("_sync_handle")
	_update_deferred()

func set_color(value):
	color = value
	_update_deferred()

func set_shaft_radius(value):
	shaft_radius = value
	_update_deferred()

func set_tip_ratio(value):
	tip_ratio = value
	_update_deferred()

func get_tip_size() -> float:
	return shaft_radius * tip_ratio

func _process(_delta):
	var handle: Spatial = get_node_or_null("DebugHandle")
	if not handle:
		return
	call_deferred("set_vector", handle.transform.origin)

func _update():
	_update_mesh()
	_update_transform()

func _sync_handle():
	var handle: Spatial = get_node_or_null("DebugHandle")
	if not handle:
		return
	handle.transform.origin = vector

func _update_mesh():
	if not pivot:
		return
	var length = vector.length()
	var tip_size = get_tip_size()
	shaft.mesh.top_radius = shaft_radius
	shaft.mesh.bottom_radius = shaft_radius
	tip.mesh.bottom_radius = tip_size
	tip.mesh.height = tip_size * 2.0
	
	shaft.mesh.height = length - tip.mesh.height
	shaft.transform.origin.y = shaft.mesh.height / 2.0
	tip.transform.origin.y = (shaft.mesh.height + tip.mesh.height) / 2.0

	var shaft_material: SpatialMaterial = shaft.material_override
	var tip_material: SpatialMaterial = tip.material_override
	shaft_material.albedo_color = color
	tip_material.albedo_color = color

func _update_transform():
	var y0 = Vector3.UP
	var y1 = vector.normalized()
	var y_dot = y0.dot(y1)
	if is_equal_approx(y_dot, 1.0):
		pivot.transform.basis = Basis.IDENTITY
		return
	elif is_equal_approx(y_dot, -1.0):
		pivot.transform.basis = Basis.IDENTITY.rotated(Vector3.RIGHT, PI)
		return
	var x1 = -y0.cross(y1).normalized()
	var z1 = x1.cross(y1).normalized()
	
	pivot.transform.basis = Basis(x1, y1, z1)
