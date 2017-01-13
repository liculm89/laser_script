
function readFile_manual()
{
	if(total_stop == 0)
	{
	    if(auto_mode == "OFF" && laser_status != "ACTIVE")
	    {
		readFile();
	    }
	    else { error_auto_mode(); }
	}
	else{error_total_stop();}
}

function stop_m_manual(){
    if(auto_mode == "OFF")
    {
	System.stopLaser();
	laser_status = "INACTIVE"; 
    }
    else { error_auto_mode(); }
}

function search_working_pos()
{  
    barrier_down();
    Axis.move(2, (Axis.getPosition(2) - 150));
    start_timer(time7_ms, stop_search);   
}

function stop_search(ID)
{
    if(timer7 == ID)
    {
	if(IoPort.getPort(0) & I_PIN_10)
	{ 	       
	    print("Laser is moving to working position");
	}
	else
	{
	     print("pump in laser focus");
	    Axis.stop(2);
	    laser_in_working_pos = 1;
	    System["sigTimer(int)"].disconnect(stop_search);	
	}
    }
}

/*
function laser_moveto_pos(ID)
{  
    if ( timer3 == ID)
    {
	print("tick move_to_pos");
	if(IoPort.getPort(0) & I_PIN_10)
	{
	    print("laser moving");
                    Axis.move(2, (Axis.getPosition(2)-1));
	}
	else
	{	
	    print("laser is in working pos");
	    laser_in_working_pos = 1;
	    print("killing timer move_to_pos");
	    //System.killTimer(timer3);
	    System["sigTimer(int)"].disconnect(laser_moveto_pos);
	}
    }
}
*/

function laser_reference()
{
    if(auto_mode == "OFF")
    {
	barrier_up();
	Axis.reset(2);
	print("laser is moving to reference pos");
    }
    else
    {
	error_auto_mode();
    }

}

function move_up()
{ 
    //print("move up");
    //Axis.move(2, (Axis.getPosition(2) + sb1_v) );
    
    if (auto_mode == "OFF")
    {
	print( "Current Z axis poz before: " + Math.round(Axis.getPosition(2)));
	Axis.move(2, (Axis.getPosition(2) + sb1_v) );
	laser_in_working_pos = 0;
	print( "Current Z axis poz after: " + Math.round(Axis.getPosition(2)));
    }
    else { error_auto_mode(); }
    
}

function move_down()
{
    if (auto_mode == "OFF")
    {
	print( "Current Z axis poz before: " + Math.round(Axis.getPosition(2)));
	Axis.move(2, (Axis.getPosition(2) - sb1_v) );
	laser_in_working_pos = 0;
                print( "Current Z axis poz after: " + Math.round(Axis.getPosition(2)));
    }
    else { error_auto_mode(); }
}

function stop_axis()
{	
    if (auto_mode == "OFF")
    {
	print( "Current Z axis poz: " + Math.round(Axis.getPosition(2)));
	Axis.stop(2);
	print ("Stop!");
	disconnect_timers();
    }
    else { error_auto_mode(); }
 }

function barrier_up()
{
    print(auto_mode);
    if(auto_mode == "OFF")
    {
	IoPort.resetPort(0, O_PIN_23);
	bar_dolje = 0;
	print("barrier up");
	IoPort.setPort(0, O_PIN_5);
	//IoPort.setPort(0, O_PIN_4);
	bar_gore=1;
    }
    else
    {
	error_auto_mode();
    }
    
}

function barrier_down()
{
     print(auto_mode);
     if (auto_mode == "OFF")
    {	
	 IoPort.resetPort(0, O_PIN_5);
	 //IoPort.resetPort(0, O_PIN_4);
	 bar_gore = 0; 
                 print("barrier down");
	 IoPort.setPort(0, O_PIN_23);
	 bar_dolje = 1;
     }
      else { error_auto_mode(); }
 }

 function disconnect_timers()
 {
   
    //System["sigTimer(int)"].disconnect(laser_moveto_pos);
 
 }
