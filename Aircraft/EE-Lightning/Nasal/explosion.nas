props.globals.initNode("/disintegration/explosion/explode", 0, "BOOL");
props.globals.initNode("/disintegration/explosion/exploded", 0, "BOOL");
props.globals.initNode("/disintegration/explosion/fire", 0, "BOOL");

#detonation with fire
var explode = func(fire) {
	setprop("/disintegration/explosion/explode", 1);
	setprop("/disintegration/explosion/exploded", 1);
	if(fire) {
		setprop("/disintegration/explosion/fire", 1);
	}
	settimer( func {setprop("/disintegration/explosion/explode", 0);} , 0.2);
}

var stopFire = func {
	setprop("/disintegration/explosion/fire", 0);
	setprop("/disintegration/explosion/exploded", 0);
}
