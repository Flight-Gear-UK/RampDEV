
var xlights = props.globals.getNode("lights/external",1);
var nav = xlights.getNode("nav-lights",1);
nav.setDoubleValue(0);
var taxi = xlights.getNode("taxi-lights",1);
taxi.setDoubleValue(0);
var ac = xlights.getNode("anticoll-lights",1);
ac.setDoubleValue(0);

var volts_req = 24;

#var nav_volts_path = "sim/multiplay/generic/int[0]";
#var taxi_volts_path = "sim/multiplay/generic/int[1]";
#var ac_switch_path = "sim/multiplay/generic/int[2]";

var nav_volts_path = "/systems/electrical/outputs/external-lights/nav-lights";
var taxi_volts_path = "/systems/electrical/outputs/external-lights/taxi-lights";
var nav_switch_path = "/controls/switches/nav-lights";

#var self = cmdarg();

var nav_volts = props.globals.getNode(nav_volts_path,1);
var taxi_volts = props.globals.getNode(taxi_volts_path,1);
var nav_switch = props.globals.getNode(nav_switch_path,1);

var on_time = 0.3;
var flash_time = 0.65;

var flash = func {
     var halftime = ( flash_time / 2 );
	 interpolate(ac,1,halftime);
	 settimer( func { interpolate(ac,0,halftime) },halftime );
	 settimer( func {
		 if ( ( nav_volts.getValue() > volts_req ) and ( nav_switch.getValue() == 2 ) ) { flash() }
		},(flash_time + 0.1));
	}
	
	
setlistener(nav_switch_path, func {
	 settimer( func {
		 if ( ( nav_volts.getValue() > volts_req ) and ( nav_switch.getValue() == 2 ) ) { flash() }
		},0.15);
	},0,0);
	
setlistener(nav_volts_path, func {
	 settimer( func {
		 if ( ( nav_volts.getValue() > volts_req ) and ( nav_switch.getValue() != 0 ) ) { 
		     interpolate(nav,1,on_time);
			}
		 else {
		     interpolate(nav,0,on_time);
			}
		},0.15);
	},0,0);
	
setlistener(taxi_volts_path, func {
	 settimer( func {
		 if ( taxi_volts.getValue() > volts_req ) { 
		     interpolate(taxi,1,on_time);
			}
		 else {
		     interpolate(taxi,0,on_time);
			}
		},0.15);
	},0,0);

