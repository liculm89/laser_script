/*
  Function is triggered when one of axis starts(moving) and on start of laser marking process
  */
function onLaserStart()
{
    //laser_status="ACTIVE";
}

/*
  Function is triggered when one of axis stops movement or when marking proces i finished
  */
function onLaserEnd()
{  

    if(auto_mode == "ON")
    {
        laser_marking = 0;
    }
    
    if(auto_mode == "OFF")
    {
        laser_marking = 0;
    }
}

/*
  Function is triggered when laser marking is stoped with System call
  */
function onLaserStop()
{
    print("laser stoped");
    //laser_status ="INACTIVE";
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
        print("Laser warm_up: " + System.LASER_WARM_UP)
        break;

    }
}

var laser_state_msg = "Unknown";

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
        laser_status =" Waiting...";
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

function onQueryStart()
{  
}

function onClose()
{
}
