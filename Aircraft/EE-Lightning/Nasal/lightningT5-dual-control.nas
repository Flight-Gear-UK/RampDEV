###############################################################################
## $Id$
##
## Nasal for MP-passenger on the MD500E over the multiplayer network.
##
##  Copyright (C) 2009  Anders Gidenstam  (anders(at)gidenstam.org)
##  This file is licensed under the GPL license version 2 or later.
##
###############################################################################

# Loading text
print("Loading Lightning T5 Dual Control script");

# Renaming (almost :)
var DCT = dual_control_tools;

######################################################################
# Pilot/copilot aircraft identifiers. Used by dual_control.
var pilot_type   = "Aircraft/EE-Lightning/Models/Lightning-T5.xml";
var copilot_type = "Aircraft/EE-Lightning/Models/Lightning-T5-Instr.xml";

props.globals.initNode("/sim/remote/pilot-callsign", "", "STRING");

######################################################################
# MP enabled properties.
# NOTE: These must exist very early during startup - put them
#       in the -set.xml file.

var pilot_switches1_mpp    = "sim/multiplay/generic/int[10]";
var pilot_bankselect_mpp   = "sim/multiplay/generic/int[8]";
var pilot_pitchselect_mpp  = "sim/multiplay/generic/float[11]";
var pilot_canopy_mpp       = "canopy/position-norm";
var pilot_inhg_mpp         = "engines/engine[6]/rpm";

var pilot_FCS_command_pitch = "engines/engine[5]/n1";
var pilot_FCS_command_roll = "engines/engine[5]/n2";

# Internal Lighting

var pilot_flood_lights_mpp = "engines/engine[8]/n1";
var pilot_inst_lights_mpp  = "engines/engine[8]/n2";
var pilot_IFIS_lights_mpp  = "engines/engine[8]/rpm";

var copilot_rudder_mpp     = "surface-positions/rudder-pos-norm";
var copilot_elevator_mpp   = "surface-positions/elevator-pos-norm";
var copilot_aileron_mpp    = "surface-positions/left-aileron-pos-norm";
var copilot_flap_mpp       = "surface-positions/flap-pos-norm";
var copilot_throttle1_mpp  = "sim/multiplay/generic/float[0]";
var copilot_throttle2_mpp  = "sim/multiplay/generic/float[1]";
var copilot_wbrakel_mpp    = "sim/multiplay/generic/float[2]";
var copilot_wbraker_mpp    = "sim/multiplay/generic/float[3]";
var copilot_parkbrake_mpp  = "sim/multiplay/generic/float[4]";

var copilot_switches1_mpp  =    "sim/multiplay/generic/int[0]";
var copilot_bankselect_mpp =    "sim/multiplay/generic/int[1]";
var copilot_pitchselect_mpp =    "";

var copilot_TDM1_mpp       =    "sim/multiplay/generic/string[0]";

######################################################################
# Useful local property paths.

var l_rudder_cmd     = "controls/flight/rudder";
var l_aileron_cmd    = "controls/flight/aileron";
var l_elevator_cmd   = "controls/flight/elevator";
var l_flaps_down_cmd  = "controls/flight/flaps";
var l_airbrakes_cmd = "controls/flight/speedbrake-switch";
var l_throttle1_cmd  = "controls/engines/engine[0]/throttle";
var l_throttle2_cmd  = "controls/engines/engine[1]/throttle";
var l_gear_down_cmd  = "controls/gear/gear-down";
var l_wbrakel_cmd    = "controls/gear/brake-left";
var l_wbraker_cmd    = "controls/gear/brake-right";
var l_parkbrake_cmd  = "controls/gear/brake-parking";
var l_canopy_pos     = "canopy/position-norm";
 
# Engines
var l_pilot_throttle1_cmd = "controls/engines/engine[0]/throttle";
var l_pilot_throttle2_cmd =  "controls/engines/engine[1]/throttle";

# Instruments

var l_autopilot_keyheight   = "instrumentation/autopilot/key-height";
var l_autopilot_keyheading  = "instrumentation/autopilot/key-heading";
var l_autopilot_keyattitude = "instrumentation/autopilot/key-attitude";
var l_autopilot_keytrack    = "instrumentation/autopilot/key-track";
var l_autopilot_keyglide    = "instrumentation/autopilot/key-glide";
var l_autopilot_bankselect  = "instrumentation/autopilot/selector-bank";
var l_fd_engaged            = "systems/FCS/flight-director/engaged";
	 


######################################################################
# Slow state properties for replication.


###############################################################################
# Pilot MP property mappings and specific copilot connect/disconnect actions.


######################################################################
# Used by dual_control to set up the mappings for the pilot.
var pilot_connect_copilot = func (copilot) {
    return 
        [
         ######################################################################
         # Process received properties.
         ######################################################################
		 # Co-Pilot controls
		 DCT.Translator.new
         (copilot.getNode(copilot_elevator_mpp),
          props.globals.getNode("/controls/copilot/elevator")),
		 DCT.Translator.new
         (copilot.getNode(copilot_aileron_mpp),
          props.globals.getNode("/controls/copilot/aileron")),
         DCT.Translator.new
         (copilot.getNode(copilot_rudder_mpp),
          props.globals.getNode("/controls/copilot/rudder")),
		 DCT.Translator.new
         (copilot.getNode(copilot_throttle1_mpp),
          props.globals.getNode("/controls/copilot/throttle[0]")),
		 DCT.Translator.new
         (copilot.getNode(copilot_throttle2_mpp),
          props.globals.getNode("/controls/copilot/throttle[1]")),
		 DCT.Translator.new
         (copilot.getNode(copilot_wbrakel_mpp),
          props.globals.getNode("/controls/copilot/brake-left")),
		 DCT.Translator.new
         (copilot.getNode(copilot_wbraker_mpp),
          props.globals.getNode("/controls/copilot/brake-right")),	 
		 
		 ##################################################
         # Decode copilot cockpit switch states.
         #   NOTE: Actions are only triggered on change.
         DCT.SwitchDecoder.new
         (copilot.getNode(copilot_switches1_mpp),
          [
           # Flight Control Switches
			func (b) {
			     if (b)  { props.globals.getNode(l_flaps_down_cmd).setValue(1); }
                 else { props.globals.getNode(l_flaps_down_cmd).setValue(0); }
			},
			func (b) {
			     if (b)  { props.globals.getNode(l_gear_down_cmd).setValue(1); }
                 else { props.globals.getNode(l_gear_down_cmd).setValue(0); }
			},
			func (b) {
			     if (b)  { props.globals.getNode(l_airbrakes_cmd).setValue(1); }
                 else { props.globals.getNode(l_airbrakes_cmd).setValue(0); }
			},
			func (b) {
			     if (b)  { props.globals.getNode(l_parkbrake_cmd).setValue(1); }
                 else { props.globals.getNode(l_parkbrake_cmd).setValue(0); }
			},
			# Autopilot Keys
			func (b) {
			     if (b)  { props.globals.getNode(l_autopilot_keyheight).setValue(1); }
                 else { props.globals.getNode(l_autopilot_keyheight).setValue(0); }
			},
			func (b) {
			     if (b)  { props.globals.getNode(l_autopilot_keyheading).setValue(1); }
                 else { props.globals.getNode(l_autopilot_keyheading).setValue(0); }
			},
			func (b) {
			     if (b)  { props.globals.getNode(l_autopilot_keyattitude).setValue(1); }
                 else { props.globals.getNode(l_autopilot_keyattitude).setValue(0); }
			},
			func (b) {
			     if (b)  { props.globals.getNode(l_autopilot_keytrack).setValue(1); }
                 else { props.globals.getNode(l_autopilot_keytrack).setValue(0); }
			},
			func (b) {
			     if (b)  { props.globals.getNode(l_autopilot_keyglide).setValue(1); }
                 else { props.globals.getNode(l_autopilot_keyglide).setValue(0); }
			}
			
          ]),
		 
         ######################################################################
         # Process properties to send.
         ######################################################################

		 ##################################################
         # Encoding of on/off switches.
         DCT.SwitchEncoder.new
         ([
           props.globals.getNode(l_flaps_down_cmd),
           props.globals.getNode(l_gear_down_cmd),
		   props.globals.getNode(l_airbrakes_cmd),
		   props.globals.getNode(l_parkbrake_cmd),
		   
		   props.globals.getNode(l_autopilot_keyheight),
		   props.globals.getNode(l_autopilot_keyheading),
		   props.globals.getNode(l_autopilot_keyattitude),
		   props.globals.getNode(l_autopilot_keytrack),
		   props.globals.getNode(l_autopilot_keyglide),
		   props.globals.getNode(l_fd_engaged)
          ],
		   props.globals.getNode(pilot_switches1_mpp))
		 
        ];
}

######################################################################
var pilot_disconnect_copilot = func {
}

###############################################################################
# Copilot MP property mappings and specific pilot connect/disconnect actions.

var l_flap_down_cmd = "controls/flight/flaps";
var l_gear_down_cmd = "controls/gear/gear-down";
var l_airbrakes_cmd = "controls/flight/speedbrake-switch";


######################################################################
# Used by dual_control to set up the mappings for the copilot.
var copilot_connect_pilot = func (pilot) {
    # Initialize Nasal wrappers for copilot pick anaimations.
    set_copilot_wrappers(pilot);

    return
        [
         ######################################################################
         # Process received properties.
         ######################################################################
         DCT.Translator.new
         (pilot.getNode(pilot_canopy_mpp),
          props.globals.getNode("/canopy/position-norm")),
		 DCT.Translator.new
         (pilot.getNode(pilot_inhg_mpp),
          props.globals.getNode("/instrumentation/altimeter/setting-inhg")),
		 DCT.Translator.new
         (pilot.getNode(pilot_flood_lights_mpp),
          props.globals.getNode("/controls/rotary/pilot-flood-lights")),
		 DCT.Translator.new
         (pilot.getNode(pilot_inst_lights_mpp),
          props.globals.getNode("/controls/rotary/pilot-instrument-lights")),
		 DCT.Translator.new
         (pilot.getNode(pilot_IFIS_lights_mpp),
          props.globals.getNode("/controls/rotary/IFIS-lights")),
		  DCT.Translator.new
         (pilot.getNode(pilot_FCS_command_pitch),
          props.globals.getNode("/systems/FCS/target-pitch-deg")),
		  DCT.Translator.new
         (pilot.getNode(pilot_FCS_command_roll),
          props.globals.getNode("/systems/FCS/target-roll-deg")),
		 
		 ##################################################
         # Decode pilot cockpit switch states.
         #   NOTE: Actions are only triggered on change.
         DCT.SwitchDecoder.new
         (pilot.getNode(pilot_switches1_mpp),
          [
            # Flight Control Switches
			func (b) {
			     if (b)  { props.globals.getNode(l_flaps_down_cmd).setValue(1); }
                 else { props.globals.getNode(l_flaps_down_cmd).setValue(0); }
			},
			func (b) {
			     if (b)  { props.globals.getNode(l_gear_down_cmd).setValue(1); }
                 else { props.globals.getNode(l_gear_down_cmd).setValue(0); }
			},
			func (b) {
			     if (b)  { props.globals.getNode(l_airbrakes_cmd).setValue(1); }
                 else { props.globals.getNode(l_airbrakes_cmd).setValue(0); }
			},
			func (b) {
			     if (b)  { props.globals.getNode(l_parkbrake_cmd).setValue(1); }
                 else { props.globals.getNode(l_parkbrake_cmd).setValue(0); }
			},
			# Autopilot Keys
			func (b) {
			     if (b)  { props.globals.getNode(l_autopilot_keyheight).setValue(1); }
                 else { props.globals.getNode(l_autopilot_keyheight).setValue(0); }
			},
			func (b) {
			     if (b)  { props.globals.getNode(l_autopilot_keyheading).setValue(1); }
                 else { props.globals.getNode(l_autopilot_keyheading).setValue(0); }
			},
			func (b) {
			     if (b)  { props.globals.getNode(l_autopilot_keyattitude).setValue(1); }
                 else { props.globals.getNode(l_autopilot_keyattitude).setValue(0); }
			},
			func (b) {
			     if (b)  { props.globals.getNode(l_autopilot_keytrack).setValue(1); }
                 else { props.globals.getNode(l_autopilot_keytrack).setValue(0); }
			},
			func (b) {
			     if (b)  { props.globals.getNode(l_autopilot_keyglide).setValue(1); }
                 else { props.globals.getNode(l_autopilot_keyglide).setValue(0); }
			},
			func (b) {
			     if (b)  { props.globals.getNode(l_fd_engaged).setValue(1); }
                 else { props.globals.getNode(l_fd_engaged).setValue(0); }
			}
          ]),
		 
         ######################################################################
         # Process properties to send.
         ######################################################################

         DCT.Translator.new
         (props.globals.getNode(l_elevator_cmd),
          props.globals.getNode(copilot_elevator_mpp)),
		 DCT.Translator.new
         (props.globals.getNode(l_aileron_cmd),
          props.globals.getNode(copilot_aileron_mpp), 1),
         DCT.Translator.new
         (props.globals.getNode(l_rudder_cmd),
          props.globals.getNode(copilot_rudder_mpp)),
		 DCT.Translator.new
         (props.globals.getNode(l_throttle1_cmd),
          props.globals.getNode(copilot_throttle1_mpp)),
		 DCT.Translator.new
         (props.globals.getNode(l_throttle2_cmd),
          props.globals.getNode(copilot_throttle2_mpp)),
		 DCT.Translator.new
		 (props.globals.getNode(l_wbrakel_cmd),
          props.globals.getNode(copilot_wbrakel_mpp)),
		 DCT.Translator.new
         (props.globals.getNode(l_wbraker_cmd),
          props.globals.getNode(copilot_wbraker_mpp)),
		 
		 DCT.MostRecentSelector.new(
		 props.globals.getNode(l_autopilot_bankselect),
		 pilot.getNode(pilot_bankselect_mpp),
		 props.globals.getNode("/instrumentation/autopilot/selector-bank"),
		 0.1),		 
		 
		 ##################################################
         # Encoding of on/off switches.
         DCT.SwitchEncoder.new
         ([
           props.globals.getNode(l_flaps_down_cmd),
           props.globals.getNode(l_gear_down_cmd),
		   props.globals.getNode(l_airbrakes_cmd),
		   props.globals.getNode(l_parkbrake_cmd),
		   
		   props.globals.getNode(l_autopilot_keyheight),
		   props.globals.getNode(l_autopilot_keyheading),
		   props.globals.getNode(l_autopilot_keyattitude),
		   props.globals.getNode(l_autopilot_keytrack),
		   props.globals.getNode(l_autopilot_keyglide)
          ],
		   props.globals.getNode(copilot_switches1_mpp))
        ];
}

######################################################################
var copilot_disconnect_pilot = func {
    # Reset local sound properties.
    p = "engines/engine/rpm";
    props.globals.getNode(p).unalias();
    props.globals.getNode(p).setValue(0);
    p = "gear/gear[0]/compression-norm";
    props.globals.getNode(p).unalias();
    props.globals.getNode(p).setValue(0);
    p = "gear/gear[1]/compression-norm";
    props.globals.getNode(p).unalias();
    props.globals.getNode(p).setValue(0);
}

######################################################################
# Copilot Nasal wrappers

var set_copilot_wrappers = func (pilot) {
    # Setup aliases to animate the MP 3d model.

    # Setup aliases to drive local sound.
    p = "engines/engine/rpm";
    props.globals.getNode(p).alias(pilot.getNode(p));
	p = "engines/engine[1]/rpm";
}
