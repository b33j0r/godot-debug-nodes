tool
extends Object
class_name DebugNodes

static func look_along(vector):
	var y0 = Vector3.UP
	var y1 = vector.normalized()
	var y_dot = y0.dot(y1)
	if is_equal_approx(y_dot, 1.0):
		return Basis.IDENTITY
	elif is_equal_approx(y_dot, -1.0):
		return Basis.IDENTITY.rotated(Vector3.RIGHT, PI)
	var x1 = -y0.cross(y1).normalized()
	var z1 = x1.cross(y1).normalized()
	return Basis(x1, y1, z1)
