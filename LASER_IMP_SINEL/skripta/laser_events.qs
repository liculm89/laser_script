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

function check_laser_state( laser_status_int)
{
 
   // status= System.getDeviceStatus();
   
   switch( laser_status_int)
     {
                 case System.LASER_OFF: 
	 
	 print(" Laser OFF State");
            break;
	 
             case System.LASER_WARM_UP: 
	 print(" Laser Warm Up State");
            break;
	    
            case System.LASER_WAIT: 
	 print(" Laser Wait State");
            break;    
	    
	        case System.LASER_STAND_BY: 
	 print(" Laser Stand By  State");
            break;    
	        case System.LASER_STAND_BY_SHUTTER_CLOSED: 
	 print(" Laser Stabd by shuter closed State");
            break;    
	    
            case System.LASER_READY: 
	 print(" Laser READY State");
            break;    
	    
	         case System.LASER_READY_SHUTTER_CLOSED: 
	 print(" Laser READY Shutter Closed State");
            break;  
	           case System.LASER_EMISSION:
	
	print(" Laser EMISSION State");
            break;
	           case System.LASER_BUSY_SHUTTER_CLOSED: 
	 print(" Laser Busy shutter closed State");
            break;
	        case System.LASER_WARNING: 
	 print(" Laser Warning State");
            break;
	        case System.LASER_ERROR: 
	 print(" Laser  ERROR State");
            break;
	    
	
                 default:
                print("Error Geting State");
	   break;
	     	   
	 
       }
 }