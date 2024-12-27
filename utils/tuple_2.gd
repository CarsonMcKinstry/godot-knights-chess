class_name Tuple2 extends RefCounted

var x: Variant
var y: Variant

static func from(x: Variant, y: Variant) -> Tuple2:
	var tup = Tuple2.new(x, y)
	return tup

func _init(i_x: Variant, i_y: Variant):
	x = i_x
	y = i_x
