
# RAF IFIS (Lightning/Buccaneer)
# By Algernon


# Settings

var update_period = 0.1;
var instrument_reaction_time = 1;
var indicator_reaction_time = 0.1;
var artificial_horizon_poweroff_pos = 130; # In degrees

var propertyPath = "/instrumentation/nav-display";
var ACpowerPath = "/systems/electrical/outputs/IFIS-28v";
var DCpowerPath = "/systems/electrical/outputs/IFIS-28v";

var ACvoltsReq = 110;
var DCvoltsReq = 26;

# Power Objects

var ACpowernode = props.globals.getNode(ACpowerPath,1);
ACpowernode.setValue(0);
var DCpowernode = props.globals.getNode(DCpowerPath,1);
DCpowernode.setValue(0);

# Nav Display Instrument

var base = props.globals.getNode(propertyPath,1);
var ACpowered = base.getNode("AC-power",1);
ACpowered.setBoolValue(0);
var DCpowered = base.getNode("DC-power",1);
DCpowered.setBoolValue(0);
var powerind = base.getNode("power-fail-indicator",1);
powerind.setValue(1);
var modeswitch = base.getNode("mode-switch-pos",1);
modeswitch.setIntValue(1);
var compDGswitch = base.getNode("compass-DG-switch",1);
compDGswitch.setBoolValue(0);
var headingKnob = base.getNode("heading-select-knob",1);
headingKnob.setValue(0);
var mode = base.getNode("mode",1);
mode.setValue("HDG");
var headingSet = base.getNode("settings/selected-heading-deg",1);
headingSet.setValue(0);
var headingPointer = base.getNode("heading-pointer-deg",1);
headingPointer.setValue(0);
var compassCard = base.getNode("compass-heading-deg",1);
compassCard.setValue(0);
var rangeCounter = base.getNode("indicated-distance-nm",1);
rangeCounter.setValue(0);
var beamPointerDeg = base.getNode("glidepath-presentation-deg",1);
beamPointerDeg.setValue(0);
var beamPointerOff = base.getNode("glidepath-presentation-offset",1);
beamPointerOff.setValue(0);
var glideslopePointer = base.getNode("glideslope-pointer-norm",1);
glideslopePointer.setValue(0);
var attHorizonPitch = base.getNode("artificial-horizon-pitch-deg",1);
attHorizonPitch.setValue(0);
var attHorizonRoll = base.getNode("artificial-horizon-roll-deg",1);
attHorizonRoll.setValue(artificial_horizon_poweroff_pos);
var attBead_X = base.getNode("FCS-bead-pos-x",1);
attBead_X.setValue(15);
var attBead_Y = base.getNode("FCS-bead-pos-y",1);
attBead_Y.setValue(15);
var attBeadPark = base.getNode("FCS-bead-park",1);
attBeadPark.setBoolValue(1);

var sources = {};
sources.magcompass = props.globals.getNode("/orientation/heading-magnetic-deg");
sources.dirgyro = props.globals.getNode("/orientation/heading-deg");
sources.pitch = props.globals.getNode("/orientation/pitch-deg");
sources.roll = props.globals.getNode("/orientation/roll-deg");
sources.tacanhdg = props.globals.getNode("/instrumentation/tacan/indicated-bearing-true-deg");
sources.tacanrange = props.globals.getNode("/instrumentation/tacan/indicated-distance-nm");
sources.ilshdg = props.globals.getNode("/instrumentation/nav/radials/target-auto-hdg-deg");
sources.ilsqdm = props.globals.getNode("/instrumentation/nav/radials/target-radial-deg");
sources.ilsgs = props.globals.getNode("/instrumentation/nav/gs-needle-deflection-norm");
sources.ilsrange = props.globals.getNode("/instrumentation/nav/nav-distance");
sources.ilsgp = props.globals.getNode("/instrumentation/nav/heading-needle-deflection-norm");
sources.gpshdg = props.globals.getNode("/instrumentation/gps/wp/wp[1]/bearing-true-deg");
sources.gpsrange = props.globals.getNode("/instrumentation/gps/wp/wp[1]/distance-nm");
sources.fcspitch = props.globals.getNode("/systems/FCS/target-pitch-deg");
sources.fcsroll = props.globals.getNode("/systems/FCS/target-roll-deg");

var pullSource = func {
     var data = [];
	 if ( modeswitch.getValue() == 1 ) {
	     data = [ headingSet.getValue(), 0 ];
		}
	 if ( modeswitch.getValue() == 2 ) {
	     data = [ sources.ilshdg.getValue(), ( sources.ilsrange.getValue() * M2NM )];
		}
	 if ( modeswitch.getValue() == 3 ) {
	     data = [ sources.tacanhdg.getValue(), sources.tacanrange.getValue()];
		}
	 if ( modeswitch.getValue() == 4 ) {
	     data = [ sources.gpshdg.getValue(), sources.gpsrange.getValue()];
		}
	 return data;
	}
	
var pullHeading = func {
     var data = 0;
	 if ( !compDGswitch.getBoolValue() ) {
	     data = sources.magcompass.getValue();
		}
     else { 
	     data = sources.dirgyro.getValue(); 
		}
	 return data;
	}
	
var pullILS = func(a){
     var data = "";
     if ( a = "gp" ) { data = sources.ilsgp.getValue(); }
	 if ( a = "gs" ) { data = sources.ilsgs.getValue(); }
	 if ( a = "qdm" ) { data = sources.ilsqdm.getValue(); }
	 return data;
    }
	
var changeMode = func {
	 var mode = 0;
	 var sp = modeswitch.getValue(); # Switch Position
	 if ( sp == 1 ) { mode = "HDG"; }
	 if ( sp == 2 ) { mode = "ILS"; }
	 if ( sp == 3 ) { mode = "TAC"; }
	 if ( sp == 4 ) { mode = "EXT"; }
	 return mode;
	}
	
var setHeading = func {
     var hdg = ( headingSet.getValue() + ( headingKnob.getValue() * 2.5 ) );
	 if ( hdg > 360 ) { hdg = 0 };
	 if ( hdg < 0 ) { hdg = 360 };
	 headingSet.setValue(hdg);
	}
	
var ACloop = func {
	 
	}
	
var DCloop = func {
     # Mode
	 mode.setValue(changeMode());
	 # Compass
	 interpolate(compassCard,pullHeading(),( instrument_reaction_time / 2.5 ));
	 # Heading
	 if ( headingKnob.getValue() != 0 ) {
	     setHeading();
		}
	 # ILS
	 if ( mode.getValue() == "ILS" ) {
	     interpolate(beamPointerDeg,pullILS("qdm"),( instrument_reaction_time / 2.5 ));
		 interpolate(beamPointerOff,pullILS("gp"),( instrument_reaction_time / 2.5 ));
		 interpolate((glideslopePointer),pullILS(("gs" * -1)),( instrument_reaction_time / 2.5 ));
		}
	 
	 # Display Source
	 var src = pullSource();
	 var srchdg = src[0];
	 var srcrng = src[1];
	 interpolate(headingPointer,srchdg,( instrument_reaction_time / 5 ));
	 rangeCounter.setValue(srcrng);
	 
	 # Attitude Indicator
	 attHorizonPitch.setValue( sources.pitch.getValue() );
	 attHorizonRoll.setValue( sources.roll.getValue() );
	 
	 var FDengaged = props.globals.getNode("/systems/FCS/flight-director/engaged").getBoolValue();
	 
	 if ( FDengaged ) {
	     attBeadPark.setBoolValue(0);
		}
	 else {
	     attBeadPark.setBoolValue(1);
		}
	 
	 if ( attBeadPark.getBoolValue() ) {
	     interpolate(attBead_X, 15, 0.15);
	     interpolate(attBead_Y, 15, 0.15);
		}
	 else {
	     interpolate(attBead_X, sources.fcsroll.getValue(), 0.15);
	     interpolate(attBead_Y, sources.fcspitch.getValue(), 0.15);
		}
	}	

var AClooptimer = maketimer(update_period, ACloop);
var DClooptimer = maketimer(update_period, DCloop);
	
var psu = func {
     if ( ACpowernode.getValue() > ACvoltsReq ) { 
	     ACpowered.setBoolValue(1); 
		 AClooptimer.start(); 
		}
	 else { 
	     ACpowered.setBoolValue(0);
         AClooptimer.stop();
        }
	 if ( DCpowernode.getValue() > DCvoltsReq ) { 
	     DCpowered.setBoolValue(1); 
		 DClooptimer.start(); 
		 if ( powerind.getValue() == 1 ) {
		     interpolate(powerind,0,indicator_reaction_time);
			}
		}
	 else { 
	     DCpowered.setBoolValue(0);
         DClooptimer.stop();
		 if ( powerind.getValue() == 0 ) {
		     interpolate(powerind,1,indicator_reaction_time);
			}
        }
	 settimer(psu,0.5);
	}
	

	
var init = func {
     print("Initialising IFIS");
	 headingSet.alias("/autopilot/settings/heading-bug-deg");
	 settimer( func { 
	     psu();
		},3);
    }
	
# Bodges
setprop("/autopilot/settings/heading-bug-deg", 0);
	
init();