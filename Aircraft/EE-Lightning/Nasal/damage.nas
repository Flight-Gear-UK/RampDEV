
# Algy Failures

var loop_time = 0.2;
var fail_path = "/sim/damage";
var luck = 0.5;

var eng_type = "jet"; # Options are jet, piston or turboprop

var init = func {
     props.globals.initNode("/sim/damage/enabled", 1, "BOOL"); # Temporarily enabled at launch
	 props.globals.initNode("/sim/damage/birdstrike/enabled", 1, "BOOL");
	 props.globals.initNode("/sim/damage/birdstrike/strike-sequence-norm", 0, "DOUBLE");
	 props.globals.initNode("/sim/damage/birdstrike/engine", 0, "INT");
	 fireflicker();
	};
	
var ff = props.globals.getNode("/sim/damage/internal/fire-flicker",1);
ff.setValue(0);	
var ff_update = 0.05;

var fireflicker = func {
     var ff1 = props.globals.getNode("/sim/damage/internal/fire-flicker-1",1);
	 var ff2 = props.globals.getNode("/sim/damage/internal/fire-flicker-2",1);
	 ff1.setValue( ( rand() * 0.75 ) + 0.25 );
	 ff2.setValue( ( rand() * 0.75 ) + 0.25 );
	 settimer(fireflicker, ff_update);
	}
	 
	
settimer(init, 5); # Temporary start


# DamageZone object useage:

# damage.hitzone.new("engine[0]", "engine", 18.0, -3.5, 1.4, 2, 0.5, 0.5, 0.2, "/sim/failure-manager/engines/engine[0]/unserviceable");

var damageZone = {
     new: func(name = "unnamed", type = "",pos_x = 0,pos_y = 0,pos_z = 0,size_x = 0.5,size_y = 0.5,size_z = 0.5,res = 0.2, usprop = nil ) { 
		 var h = { parents: [damageZone] };
		 if ( usprop == nil ) { print("Failures Error: Hitzone without USProp"); return; }
		 # Declare Required Object Properties
         h.type = type;		 
		 h.base = props.globals.getNode(fail_path~"/damage-zones/"~name,1);
		 h.cfg = h.base.getNode("config",1);
		 h.name = h.base.getNode("name",1);
		 h.name.setValue(name);
		 h.xpos = h.cfg.getNode("position-x",1);
		 h.xpos.setValue(pos_x);
		 h.ypos = h.cfg.getNode("position-y",1);
		 h.ypos.setValue(pos_y);
		 h.zpos = h.cfg.getNode("position-z",1);
		 h.zpos.setValue(pos_z);
		 h.xsize = h.cfg.getNode("size-x",1);
		 h.xsize.setValue(size_x);
		 h.ysize = h.cfg.getNode("size-y",1);
		 h.ysize.setValue(size_y);
		 h.zsize = h.cfg.getNode("size-z",1);
		 h.zsize.setValue(size_z);
		 h.res = h.cfg.getNode("resilience",1);
		 h.res.setValue(res);
		 h.usprop = h.cfg.getNode("properties/us-property",1);
		 h.usprop.setValue(usprop);
		 h.damprop = h.base.getNode("damage-norm",1);
		 h.damprop.setValue(0);
		 h.stable = h.base.getNode("stable",1);
		 h.stable.setBoolValue(1);
		 h.malfunction = h.base.getNode("malfunction",1);
		 h.malfunction.setValue(0);
		 if ( type == "engine" ) {
		     h.engnode = name;
			 h.fire = h.base.getNode("fire",1);
			 h.fire.setValue(0);
			 h.smoke = h.base.getNode("smoke-norm",1);
			 h.smoke.setValue(0);
			 h.explode = h.base.getNode("explosion",1);
			 h.explode.setValue(0);
			}
		 # Declare Optional Properties
		 # Declare Extra Properties
		return h;
	},
	 hit: func (count, power) {
	     # Check damage is enabled
		 if ( props.globals.getNode(fail_path~"/enabled").getBoolValue() ) {
		     var d1 = 0;
			 var d2 = 0;
			 var d3 = 0;
			 # Work out damage for single hit
		     d1 = ( ( 0.98 - me.res.getValue() ) * power ) ;
			 print("D1: "~d1);
			 # Number of hits
			 d2 = (d1 * count);
			 print("D2: "~d2);
			 # Were you lucky?
			 x = (( rand() + luck) / 20);
			 d3 = ( d2 - x );
			 print("D3: "~d3);
			 # Apply Damage 
			 var dx = ( me.damprop.getValue() + d3);
			 if ( dx > 1 ) { dx = 1; }
			 me.damprop.setValue(dx);
			}
		},
    };
	
# Engine Classes

var engine1 = damageZone.new("engine[0]", "engine", 18.0, -3.5, 1.4, 2, 0.5, 0.5, 0.2, "/sim/failure-manager/engines/engine[0]/unserviceable");
var engine2 = damageZone.new("engine[1]", "engine", 18.0, -3.5, 1.4, 2, 0.5, 0.5, 0.2, "/sim/failure-manager/engines/engine[1]/unserviceable");


	 
var birdstrike = func(n = nil, sev = 0.21 ) {
     var bsbase = props.globals.getNode("sim/damage/birdstrike",1);
	 var sequence = bsbase.getNode("strike-sequence-norm",1);
	 var engine = bsbase.getNode("engine",1);
	 var eng = 0;
	 var time = 2;
	 var airspeed = props.globals.getNode("velocities/groundspeed-kt").getValue();
	 var birdspeed = ( ( airspeed * 0.51444 ) + 5 );
	 var time = ( 100 / birdspeed );
	 print(time);
	 sequence.setValue(0);
	 engine.setIntValue(0);
	 # Determine which engine
	 if ( n != nil ) { x = ( n / 4 ); }
	 else { x = rand(); }
	 var engnode = 0;
	 if ( x < 0.25 ) { eng = 0; var engnode = engine0; }
	 if (( x > 0.25 ) and ( x < 0.5 )) { eng = 1; var engnode = engine1; }
	 if (( x > 0.5 ) and ( x < 0.75 )) { eng = 2; var engnode = engine2; }
	 if ( x > 0.75 ) { eng = 3; var engnode = engine3; }
	 engine.setIntValue(eng);
	 interpolate(sequence, 1, time);
	 settimer(func { engnode.hit( 1 , sev ); },time);
	}
	

	
	 
	 
	 
	 