/*
  Function is triggered when one of axis starts(moving) and on start of laser marking process
  */
function onLaserStart()
{
    laser_status="ACTIVE";
}

/*
  Function is triggered when one of axis stops movement or when marking proces i finished
  */
function onLaserEnd()
{  
    if(auto_mode == "ON" && pump_present == 0)
    {
	if(pump_present == 0)
	{
	    barrier_up_auto();
	}
	laser_status ="INACTIVE";
	print("on laser end, auto");
	laser_marking = 0;
	timer10 = System.setTimer(time10_ms);
	start_timer(timer10, reset_laser_marking);
    }
    
    if(auto_mode == "OFF")
    {	
	print("on laser end, manual");
	laser_status ="INACTIVE";
	laser_marking = 0;
    }
}

/*
  Function is triggered when laser marking is stoped with System call
  */
function onLaserStop()
{
    print("laser stoped");
    laser_status ="INACTIVE";
}


function get_laser_events(event)
{
    //laser_status_int = System.getDeviceStatus();
    //check_laser_state(laser_status_int);
    switch(event)
    {
    case System.EVENT_LASER_WAIT:
	print("laser wait");
	break;	 
    case System.EVENT_LASER_STAND_BY:
	print("laser stand by");
	break;	 
    case System.EVENT_LASER_STAND_BY_SHUTTER_CLOSED:
	print("laser stand by shutter closed");
	break;
    case System.EVENT_LASER_READY_SHUTTER_CLOSED:
	print("laser ready shutter closed");
	break;
    case System.EVENT_LASER_READY:
	print("laser ready!");
	break;
    case System.EVENT_LASER_WARM_UP:        
	print("laser is warming up");
	print("Laser warm_up: " + System.LASER_WARM_UP)
		break;
	
    }
}

var laser_state_msg = "Unknown";
function check_laser_state( laser_status_int)
{
    
    switch(laser_status_int)
    {
	    case System.LASER_OFF: 	 
		print("OFF");
		laser_status =  "OFF";
		break;
		
	    case System.LASER_WARM_UP: 
		print(" Warming up");
		laser_status ="Warming up";
		break;
		
	    case System.LASER_WAIT: 
		print(" Waiting...");
		laser_status =" Waiting...";
		break;    
		
	    case System.LASER_STAND_BY: 
		print("Stand by");
		laser_status ="Stand by";
		break;
		
	    case System.LASER_STAND_BY_SHUTTER_CLOSED: 
		print("Stand by, shutter closed");
		laser_status ="Stand by, shutter closed";
		break;    
		
	    case System.LASER_READY: 
		print("Ready for marking");
		laser_status ="Ready for marking";
		break;    
		
	    case System.LASER_READY_SHUTTER_CLOSED: 
		print("Ready, shutter closed");
		laser_status ="Ready, shutter closed";
		break;  
		
	    case System.LASER_EMISSION:
		if (laser_moving == 0);
		{
		    print("Marking is active");
		}
		{
		    print("Moving");
		}
		break;
		
	    case System.LASER_BUSY_SHUTTER_CLOSED: 
		print("Busy, shutter closed");
		break;
		
	    case System.LASER_WARNING: 
		print("Warning");
		break;
		
	    case System.LASER_ERROR: 
		print("ERROR");
		break;
		
		
	    default:
		print("Error Geting State");
		break;     	   
	    }
}


function onQueryStart()
{  
}

function onClose()
{
}