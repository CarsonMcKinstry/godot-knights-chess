class_name Tuple2 extends RefCounted

var x: Variant
var y: Variant

static func from(x: Variant, y: Variant) -> Tuple2:
	var tup = Tuple2.new()
	
	tup.x = x
	tup.y = y
	
	return tup
