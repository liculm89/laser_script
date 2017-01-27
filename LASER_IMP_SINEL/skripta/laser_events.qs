
/*
  Function is triggered when laser marking is stoped with System call
  */
function onLaserStop()
{
    if(debug_mode){ print("laser stoped");}
}

/*
  Function is triggered when one of axis stops movement or when marking proces i finished
  */
function onLaserEnd()
{  
     laser_marking = 0;
}

var key_state = "OFF";
var enable_state = "OFF";
var warm_up_time = 30;
var wac =warm_up_time;

function laser_key_on()
{
   if(total_stop == 0)
    {
    
       if(key_state == "OFF")
       {	
	IoPort.resetPort(0, O_PIN_17);
	key_state = "ON";
                enable_state = "Wait:"+wac+"s";
	timers[8] = System.setTimer(times[8]);
                start_timer(timers[8], warmup_counter);
	    }
       else
       {
	IoPort.setPort(0, O_PIN_17);
	key_state = "OFF";
	if(enable_state != "ON")
	{disconnect_func(warmup_counter)}
                enable_state = "OFF";
	wac = warm_up_time;
       }
  }
  else
   {
      error_total_stop();
  }
}

function enable_pressed()
{
    if(total_stop == 0)
    {
    
	if(enable_state == "Press to enable" && laser_status == "Stand by, shutter closed")
	{
	    IoPort.resetPort(0, O_PIN_18);
	    enable_state = "ON";
	}
	else if(enable_state == "ON")
	{
	    IoPort.setPort(0, O_PIN_18);
	    enable_state = "OFF";
	}
	else if(laser_status == "Stand by, shutter closed" && enable_state == "OFF")
	{
	    IoPort.resetPort(0, O_PIN_18);
	   enable_state = "ON"; 
                }
      }
    else
    {
	error_total_stop();
    }
}

function warmup_counter(ID)
{
    if(ID == timers[8])
    {
	if(wac != 0)
	{
	    wac = wac - 1;
	    enable_state = "Wait:"+wac+"s";
	   
                }
	else
	{
	    disconnect_func(warmup_counter);
	    enable_state = "Press to enable";
	    wac =warm_up_time;
	}
    }
}

function reset_sequence()
{
    IoPort.setPort(0, O_PIN_17);
    key_state = "OFF";
    IoPort.setPort(0, O_PIN_18);
    enable_state = "OFF";
}

function disable_sequence()
	
{
    IoPort.resetPort(0, O_PIN_17);
    IoPort.resetPort(0, O_PIN_18); 
}

function enable_break()
{
    IoPort.resetPort(0, O_PIN_4);
    brake_status = 1;
    if(debug_mode){print("Brake active")}
}

function disable_break()
{
     IoPort.setPort(0, O_PIN_4); 
     brake_status = 0;
     if(debug_mode){print("Brake disabled")}
}

var laser_poz_before = Axis.getPosition(2);
var laser_poz_cur =  Axis.getPosition(2);
var laser_moving = 0;

/*
  Checks if laser is moving
  */
function laser_movement(ID)
{
    if(timers[4] == ID)
    {
        laser_poz_cur = Axis.getPosition(2);
        if(laser_poz_cur != laser_poz_before)
        {
            laser_moving = 1;
            //signal_ready = 0;
        }
        else
        {
            laser_moving = 0;
            //signal_ready = 1;
        }
        laser_poz_before = laser_poz_cur;
    }
}

function set_signal_ready(ID)
	
{
    print(signal_ready);
    if((timers[0] == ID)  && (signal_ready == 1))
    {
            IoPort.setPort(0, O_PIN_2); 
    }
    else if((timers[0] == ID) && (signal_ready == 0))
    {
            IoPort.resetPort(0, O_PIN_2); 
    }
    
    else if((timers[0] == ID) && (auto_mode == "OFF") && (laser_in_working_pos == 1) && (IoPort.getPort(0) & I_PIN_11))
    {
           IoPort.resetPort(0, O_PIN_2); 
    }
 }

function get_laser_events(event)
{
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
        break;
    }
}

var laser_state_msg = "No errors";

function check_laser_state(state)
{
    switch(state)
    {
    case System.LASER_OFF:
        laser_status = "OFF";
        break;
    case System.LASER_WARM_UP:
        laser_status = "Warming up";
        break;
    case System.LASER_WAIT:
        laser_status =" Waiting for key sequence";
        break;
    case System.LASER_STAND_BY:
        laser_status ="Stand by";
        break;
    case System.LASER_STAND_BY_SHUTTER_CLOSED:
        laser_status ="Stand by, shutter closed";
        break;
    case System.LASER_READY:
        laser_status ="Ready for marking";
        break;
    case System.LASER_READY_SHUTTER_CLOSED:
        laser_status ="Ready, shutter closed";
        break;
    case System.LASER_EMISSION:
        if (laser_moving == 0)
        {
            laser_status = "Marking is active";
        }
        else
        {
            laser_status = "Moving...";
        }
        break;
    case System.LASER_BUSY_SHUTTER_CLOSED:
        laser_status = "Busy, shutter closed";
        break;
    case System.LASER_WARNING:
        laser_status = "Warning";
        break;
    case System.LASER_ERROR:
        laser_status = "ERROR";
        break;
    default:
        print("Error Geting State");
        laser_status ("Error getting state");
        break;
    }
}

/*
  Function is triggered when one of axis starts(moving) and on start of laser marking process
  */
function onLaserStart()
{
    //laser_status="ACTIVE";
}

function onQueryStart()
{  
}

function onClose()
{
}
