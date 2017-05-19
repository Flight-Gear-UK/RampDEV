
## Lightning FCC

print("Loading Lightning FCC/FCS");

### Declare variables & create properties
#

var update_period = 0.1;

# Settings

var def_act_limit_tail   = 0.45;
var def_act_limit_ail    = 0.1;
var def_act_limit_rud    = 0.2;
var def_act_limit_throt  = 0.9;

var base      = props.globals.getNode("systems/FCS",1);
var fdbase    = props.globals.getNode("systems/FCS/flight-director",1);
var apbase    = props.globals.getNode("systems/FCS/autopilot",1);
var atbase    = props.globals.getNode("systems/FCS/autothrottle",1);
var panelbase = props.globals.getNode("instrumentation/autopilot",1);
var internal  = apbase.getNode("internal",1);

# System
var powered = apbase.getNode("powered",1);
powered.setBoolValue(1);
var apengaged = apbase.getNode("engaged",1);
apengaged.setBoolValue(0);
var fdengaged = fdbase.getNode("engaged",1);
fdengaged.setBoolValue(1);
var atengaged = atbase.getNode("engaged",1);
atengaged.setBoolValue(0);

var targetpitch = base.getNode("target-pitch-deg",1);
targetpitch.setValue(0);
var targetroll = base.getNode("target-roll-deg",1);
targetroll.setValue(0);
var pitchdemand = base.getNode("demand-pitch-deg",1);
pitchdemand.setValue(0);
var rolldemand  = base.getNode("demand-roll-deg",1);
rolldemand.setValue(0);
var throtdemand = base.getNode("demand-throttle-deg",1);
throtdemand.setValue(0);

var targetalt = base.getNode("target-altitude-ft",1);
targetalt.setValue(0);
var targetspd = base.getNode("target-speed-kt",1);
targetspd.setIntValue(0);
var alterror = base.getNode("altitude-error",1);
alterror.setValue(0);
var hdgerror = base.getNode("heading-error",1);
hdgerror.setValue(0);

var latmode = base.getNode("mode-lateral",1);
latmode.setValue("");
var vermode = base.getNode("mode-vertical",1);
vermode.setValue("");

# Sources

# Selectors, 

var act_tailplane = apbase.getNode("actuators/tailplane-norm",1);
act_tailplane.setValue(0);
var act_aileron = apbase.getNode("actuators/ailerons-norm",1);
act_aileron.setValue(0);
var act_rudder = apbase.getNode("actuators/rudder-norm",1);
act_rudder.setValue(0);
var act_throttle = apbase.getNode("actuators/throttle-norm",1);
act_throttle.setValue(0);
var act_limit_tailplane = apbase.getNode("actuators/limiter-tailplane",1);
act_limit_tailplane.setValue(def_act_limit_tail);
var act_limit_aileron = apbase.getNode("actuators/limiter-ailerons",1);
act_limit_aileron.setValue(def_act_limit_ail);
var act_limit_rudder = apbase.getNode("actuators/limiter-rudder",1);
act_limit_rudder.setValue(def_act_limit_rud);
var act_limit_throttle = apbase.getNode("actuators/limiter-throttle",1);
act_limit_throttle.setValue(def_act_limit_throt);


# Controls
var key = {};
key.progclimb = panelbase.getNode("key-programmed-climb",1);
key.heading   = panelbase.getNode("key-heading",1);
key.height    = panelbase.getNode("key-height",1);
key.attitude  = panelbase.getNode("key-attitude",1);
key.track     = panelbase.getNode("key-track",1);
key.glide     = panelbase.getNode("key-glide",1);
	
key.progclimb.setBoolValue(0);
key.heading.setBoolValue(0);
key.height.setBoolValue(0);
key.attitude.setBoolValue(0);
key.track.setBoolValue(0);
key.glide.setBoolValue(0);

var bank_select = panelbase.getNode("selector-bank",1);
bank_select.setIntValue(0);
var pitch_select = panelbase.getNode("selector-pitch",1);
pitch_select.setValue(0);

var engage_switch_pilot = panelbase.getNode("engage-switch-pilot",1);
engage_switch_pilot.setValue(0);
var engage_switch_inst = panelbase.getNode("engage-switch-instructor",1);
engage_switch_inst.setValue(0);

### Functions
#


var fdloop = func {
     
	}
	
var aploop = func {
     
	}
	
var atloop = func {
     
    }
	
var mainloop = func {
     if ( powered.getBoolValue() ) {
	     if ( fdengaged.getBoolValue() ) {
		     fdloop;
			}
		 if ( apengaged.getBoolValue() ) {
		     aploop;
			}
		 if ( apengaged.getBoolValue() ) {
		     atloop;
			}
		}
	}

	
var maintimer = maketimer(update_period, mainloop);
maintimer.start;

var modeselect = func(x) {
     if ( x == "height") {
		 set_alt();
		 vermode.setValue("altitude-hold");
		 key.attitude.setBoolValue(0);
		 key.glide.setBoolValue(0);
        }
     if ( x == "heading") {
         key.attitude.setBoolValue(0);
		 key.track.setBoolValue(0);
		 latmode.setValue("heading-hold");
        }
	 if ( x == "attitude") {
         key.heading.setBoolValue(0);
		 key.height.setBoolValue(0);
		 key.track.setBoolValue(0);
		 key.glide.setBoolValue(0);
		 latmode.setValue("roll-hold");
		 vermode.setValue("pitch-hold");
        }
	 if ( x == "track" ) {
	     key.heading.setBoolValue(0);
		 key.attitude.setBoolValue(0);
		 latmode.setValue("track-hold");
		}
	 if ( x == "glide" ) {
	     key.height.setBoolValue(0);
		 key.attitude.setBoolValue(0);
		 vermode.setValue("glide");
		}
	}
	
var set_alt = func {
     targetalt.setValue ( getprop("/position/altitude-ft") );
	}
	
var set_spd = func {
     targetspd.setIntValue ( getprop("/velocities/airspeed-kt") );
	}
	
var engage = func (a) {
     if ( a == 1 ) {
	     set_alt();
		 apengaged.setBoolValue(1);
		}
	 else {
	     apengaged.setBoolValue(0);
		}
	}
	
var atengage = func (a) {
     if ( a == 1 ) {
	     set_spd();
		 atengaged.setBoolValue(1);
		}
	 else {
	     atengaged.setBoolValue(0);
		}
	}

trip = func {
	 key.progclimb.setBoolValue(0);
     key.heading.setBoolValue(0);
     key.height.setBoolValue(0);
     key.attitude.setBoolValue(0);
     key.track.setBoolValue(0);
     key.glide.setBoolValue(0);
	}

setlistener(apengaged.getPath(),func {
     engage( apengaged.getValue() );
	});
	
setlistener(atengaged.getPath(),func {
     atengage( atengaged.getValue() );
	});