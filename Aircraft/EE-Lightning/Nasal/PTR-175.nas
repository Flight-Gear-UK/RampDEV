

print("Loading PTR-175 R/T...");

var default_channel = 1;
var chanlist_path = "Settings/uvhf-channels.xml";
var min_frequency = 100.0;
var max_frequency = 339.95;
var default_frequency = 123.45;
var guard_frequency = 122.75;

var default_volume = 0.7;
var default_mode = 0;

## Electrical & Illumination

var power_req = 24;
var power_path = "/systems/electrical/outputs/UVHF-28v";
var volts = props.globals.getNode(power_path,1);

var illum_path = "/systems/electrical/outputs/internal-lights/pilot-instruments";
var illum_fade = 0.1;

## Audio FX Levels
	
var sfx_master = 1;
var sfx_poweron = 0.3;
var sfx_powerup = 0.3;
var sfx_static = 0.8;
var sfx_click = 0.8;
var sfx_txwhine = 0.5;
var sfx_controls = 0.25;
var sfx_flap = 0.4;

## Script Settings

var update_period = 0.1;

## PTR-175 Properties

var base = props.globals.getNode("instrumentation/PTR-175",1);

var powered = base.getNode("powered",1);
powered.setBoolValue(0);
var volume = base.getNode("volume-norm",1);
volume.setDoubleValue(default_volume);
var chansel = base.getNode("channel-selected",1);
chansel.setIntValue(default_channel);
var freqsel = base.getNode("frequency-selected-mhz",1);
freqsel.setDoubleValue(default_frequency);
var manfreq = base.getNode("manual-frequency-mhz",1);
manfreq.setDoubleValue(default_frequency);
var manfreqdisp1 = base.getNode("manual-frequency-display-10mhz",1);
manfreqdisp1.setIntValue(12);
var manfreqdisp2 = base.getNode("manual-frequency-display-1mhz",1);
manfreqdisp2.setIntValue(3);
var manfreqdisp3 = base.getNode("manual-frequency-display-decimal",1);
manfreqdisp3.setIntValue(45);
var manfreq = base.getNode("manual-frequency-mhz",1);
manfreq.setDoubleValue(default_frequency);
var guardfreq = base.getNode("guard-frequency-mhz",1);
guardfreq.setDoubleValue(guard_frequency);
var guardrx = base.getNode("guard-receive",1);
guardrx.setBoolValue(0);
var adffreq = base.getNode("ADF-frequency",1);
adffreq.setDoubleValue(0);
var modesel = base.getNode("mode-selected",1);
modesel.setIntValue(default_mode);
var illum = base.getNode("illumination-norm",1);
illum.setDoubleValue(0);
var ptt = base.getNode("push-to-talk",1);
ptt.setBoolValue(0);
var mute = base.getNode("mute",1);
mute.setBoolValue(0);
var flap = base.getNode("flap-position-norm",1);
flap.setDoubleValue(0);

## Flap

var channel_flap = func ( x ) {
	 if ( !x ) { read_channels() }
	 interpolate(flap,x,0.4);
	 sfx_trigger_flap.setBoolValue(1);
	 settimer( func { sfx_trigger_flap.setBoolValue(0) }, 1.5);
	}


## Com[0] Properties
var com0 = props.globals.getNode("instrumentation/comm[0]",1);
var com0freq = com0.getNode("frequencies/selected-mhz",1);
var com0vol = com0.getNode("volume",1);
var com0ptt = com0.getNode("ptt",1);

## Com[1] Properties
var com1 = props.globals.getNode("instrumentation/comm[1]",1);
var com1freq = com1.getNode("frequencies/selected-mhz",1);
var com1vol = com1.getNode("volume",1);

## FGCom Properties
var fgcomvol = props.globals.getNode("sim/fgcom/speaker-level",1);

com1freq.setDoubleValue(guard_frequency);		# Set Guard
com0vol.setValue(0);
com1vol.setValue(0);

## Nav[0] Properties
var nav0freq = props.globals.getNode("instrumentation/nav[0]/frequencies/selected-mhz",1);

## Nav[1] Properties
var nav1freq = props.globals.getNode("instrumentation/nav[1]/frequencies/selected-mhz",1);

## Channels
var channels = base.getNode("channel-presets",1);

var read_channels = func {
     print("Loading PRT-175 Channel Presets");
     var acpath = props.globals.getNode("sim/aircraft-dir").getValue() ~"/"~chanlist_path;
	 var chanpath = "";
	 var chanlist = io.read_properties(acpath,channels);
	}
read_channels();

var select_channel = func {
	 var ch = chansel.getValue();
	 var freq = default_frequency;
	 if ( ( ch == 0 ) or ( ch == 20 ) ) {
	     freq = guard_frequency;
		}
	 else {
	     if ( ch == 19 ) {
		     freq = manfreq.getValue();
			}
		 else {
			 freq = channels.getNode("channel["~ch~"]/frequency").getValue();
			 if ( ( freq < min_frequency ) or ( freq > max_frequency ) ) { freq = default_frequency }
			}
		}
	 freqsel.setValue(freq);
	}
setlistener(chansel,select_channel);
setlistener(manfreq,select_channel,0,1);

var decode_man_freq = func {
     var ten = ( manfreqdisp1.getValue() * 10 );
	 var one = ( manfreqdisp2.getValue() );
	 var dec = ( manfreqdisp3.getValue() * 0.01);
	 var result = (  ten + one + dec );
	 if ( result < min_frequency ) { 
	     result = min_frequency;
		 }
	 if ( result > max_frequency ) { 
	     result = max_frequency;
		}
	 manfreq.setDoubleValue(result);
	}
	
 var grx = 0;
	
var check_guard = func {
     grx = 0;
	 if ( modesel.getValue() == 2 ) {
	     grx = 1;
		}
	 if ( ( chansel.getValue() == 0 ) or ( chansel.getValue() == 20 ) ) {
	     grx = 0;
		}
	 if ( powered.getBoolValue() ) {
		 guardrx.setBoolValue(grx);
		}
	 else {
		 guardrx.setBoolValue(0);
		}
	}
	
## Audio FX


	
var sfx_levels = props.globals.getNode("sim/sound/levels/UVHF",1);
var sfx_level_master = sfx_levels.getNode("master",1);
var sfx_level_poweron = sfx_levels.getNode("power-on",1);
var sfx_level_powerup = sfx_levels.getNode("power-up",1);
var sfx_level_static = sfx_levels.getNode("static",1);
var sfx_level_click = sfx_levels.getNode("click",1);
var sfx_level_controls = sfx_levels.getNode("controls",1);
var sfx_level_txwhine = sfx_levels.getNode("tx-whine",1);
var sfx_level_flap = sfx_levels.getNode("flap",1);
sfx_level_master.setValue(sfx_master);
sfx_level_poweron.setValue(0);
sfx_level_powerup.setValue(sfx_powerup);
sfx_level_static.setValue(sfx_static);
sfx_level_click.setValue(sfx_click);
sfx_level_controls.setValue(sfx_controls);
sfx_level_txwhine.setValue(sfx_txwhine);
sfx_level_flap.setValue(sfx_flap);

var sfx_afmaster = sfx_levels.getNode("af-master",1);
sfx_afmaster.setValue(0);

var sfx_triggers = props.globals.getNode("sim/sound/triggers",1);
var sfx_trigger_powerup = sfx_triggers.getNode("UVHF-powerup",1);
sfx_trigger_powerup.setBoolValue(0);
var sfx_trigger_static = sfx_triggers.getNode("UVHF-static",1);
sfx_trigger_static.setBoolValue(0);
var sfx_trigger_click = sfx_triggers.getNode("UVHF-click",1);
sfx_trigger_click.setBoolValue(0);
var sfx_trigger_txwhine = sfx_triggers.getNode("UVHF-tx-whine",1);
sfx_trigger_txwhine.setBoolValue(0);
var sfx_trigger_control_channel = sfx_triggers.getNode("UVHF-control-channel",1);
sfx_trigger_control_channel.setBoolValue(0);
var sfx_trigger_control_digit = sfx_triggers.getNode("UVHF-control-digit",1);
sfx_trigger_control_digit.setBoolValue(0);
var sfx_trigger_control_mode = sfx_triggers.getNode("UVHF-control-mode",1);
sfx_trigger_control_mode.setBoolValue(0);
var sfx_trigger_flap = sfx_triggers.getNode("flap-position-norm",1);
sfx_trigger_flap.setBoolValue(0);

sfx_click_length = 0.07;
sfx_static_burst_length = 0.1;

var txsfx = func (a) {
     if ( a ) {
	     sfx_trigger_click.setBoolValue(1);
		 settimer( func { sfx_trigger_click.setBoolValue(0) }, sfx_click_length);
		 sfx_trigger_txwhine.setBoolValue(1);
		}
	 else {
	     settimer( func {
		     sfx_trigger_static.setBoolValue(1);
		     settimer( func { sfx_trigger_static.setBoolValue(0) }, sfx_static_burst_length);
			},sfx_static_burst_length);
		 sfx_trigger_click.setBoolValue(1);
	     settimer( func { sfx_trigger_click.setBoolValue(0) }, sfx_click_length);
		 sfx_trigger_txwhine.setBoolValue(0);
		}
	}
	
var powerup_sfx = func (b) {
     if (b) {
	     #settimer( func { interpolate(sfx_level_poweron,sfx_poweron, 1.2) }, 0.25);
		 sfx_trigger_click.setBoolValue(1);
		 settimer( func { sfx_trigger_click.setBoolValue(0) }, sfx_click_length);
		 sfx_level_poweron.setValue(sfx_poweron);
		 sfx_trigger_powerup.setBoolValue(1);
		 settimer( func { sfx_trigger_powerup.setBoolValue(0) }, 2.75);
		}
	 else {
	     sfx_trigger_click.setBoolValue(1);
	     settimer( func { sfx_trigger_click.setBoolValue(0) }, sfx_click_length);
		 sfx_level_poweron.setValue(0);
		}
	}
	
var fadein_af = func {
	 settimer( func {
		 interpolate(sfx_afmaster,volume.getValue(),2.5)
	    },2);
	}
	
setlistener(powered, func {
     if ( powered.getBoolValue() ) { fadein_af() }
	 else { sfx_afmaster.setValue(0) }
	},0,0);
	
var ptt_sfx = func {
     txsfx(ptt.getBoolValue());
	}
setlistener(com0ptt,ptt_sfx,0,0);
setlistener(powered, func { powerup_sfx( powered.getBoolValue() )},0,0);

setlistener(chansel, func {
     sfx_trigger_control_channel.setBoolValue(1);
	 settimer( func { sfx_trigger_control_channel.setBoolValue(0) }, 0.1);
	},0,0);
setlistener(modesel, func {
     sfx_trigger_control_mode.setBoolValue(1);
	 settimer( func { sfx_trigger_control_mode.setBoolValue(0) }, 0.2);
	},0,0);
setlistener(manfreqdisp1, func {
     sfx_trigger_control_digit.setBoolValue(1);
	 settimer( func { sfx_trigger_control_digit.setBoolValue(0) }, 0.2);
	},0,0);
setlistener(manfreqdisp2, func {
     sfx_trigger_control_digit.setBoolValue(1);
	 settimer( func { sfx_trigger_control_digit.setBoolValue(0) }, 0.2);
	},0,0);
setlistener(manfreqdisp3, func {
     sfx_trigger_control_digit.setBoolValue(1);
	 settimer( func { sfx_trigger_control_digit.setBoolValue(0) }, 0.2);
	},0,0);

var illum_volts = 0;
var illum_norm = 0;

var power = func {
	 illum_volts = props.globals.getNode(illum_path,1).getValue();
	 if ( illum_volts == nil ) { return }
	 illum_norm = ( illum_volts / power_req );
     interpolate(illum,( illum_norm * power_req ),illum_fade);
	 decode_man_freq();
	 check_guard();
	 com0freq.setValue(freqsel.getValue());
	 if ( volts.getValue() == nil ) { return };
	 if ( volts.getValue() > power_req ) {
	     if ( modesel.getValue() != 0 ) {
			 powered.setBoolValue(1);
			 loop();
			}
		 else {
		     powered.setBoolValue(0);
			 com0vol.setValue(0);
			 com1vol.setValue(0);
			 fgcomvol.setValue(0);
			}
		 if ( modesel.getValue() == 3 ) {
		     adffreq.setValue( manfreq.getValue() );
			}
		 else {
		      adffreq.setValue(0);
			}
		}
	 else {
	     powered.setBoolValue(0);
		 com0vol.setValue(0);
		 com1vol.setValue(0);
		 fgcomvol.setValue(0);
		}
	}

var loop = func {
     if ( ptt.getBoolValue() ) {
	     com0ptt.setBoolValue(1);
		 mute.setBoolValue(1);
		}
	 else {
	     com0ptt.setBoolValue(0);
		 mute.setBoolValue(0);
		}
	 if ( !mute.getBoolValue() ) {
		 if ( guardrx.getBoolValue() ) {
			 com1vol.setValue(volume.getValue());
			}
		 else {
			 com1vol.setValue(0);
			}
		 com0vol.setValue(volume.getValue() * sfx_afmaster.getValue());
		 fgcomvol.setValue(volume.getValue() * sfx_afmaster.getValue());
		 nav0freq.setValue(adffreq.getValue() * sfx_afmaster.getValue());
		 
		}
	 else {
		 com0vol.setValue(0);
		 com1vol.setValue(0);
		 fgcomvol.setValue(0);
		}	     
	}

var timer = maketimer(update_period,power);
timer.start();
