function start_auto_mode()
{
    if(auto_mode == "OFF")
    {	
	auto_mode = "ON";
	laser_ref_auto();
	start_timer(time5_ms, wait_for_pump);
	
	/*if( IoPort.getPort(0) & I_PIN_9)
	{
	    start_timer(time3_ms, laser_moveto_pos_auto);	    	    
	    //start_timer(time4_ms, readFile_auto);
	}
	else
	{
	    laser_ref_auto();
	}*/
    }
    else{error_manual_mode();}
}

function wait_for_pump(ID)
{
  if( timer5 == ID && auto_mode=="ON" && IoPort.getPort(0) & I_PIN_7)
    {
         print("pump found!");
         if( laser_in_working_pos == 0)
	 {
	     start_timer(time3_ms, laser_moveto_pos_auto);
	 }
	 else
	 {
	     readFile_auto();
	 }
     }
    
}

function laser_moveto_pos_auto(ID)
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
	    var laser_in_working_pos = 1;
	    print("killing timer move_to_pos");
	    //System.killTimer(timer3);
	    System["sigTimer(int)"].disconnect(laser_moveto_pos_auto);
	}
    }
}

function readFile_auto()
{    
  print("Reading file"); 		
  laser_marking = 1;
  readFile();
			   
}


function laser_ref_auto()
{
    Axis.reset(2);
    print("laser is moving to reference pos");	    	    
}

function barrier_up_auto()
{   	
    IoPort.resetPort(0, O_PIN_23);
    bar_dolje = 0;
    IoPort.setPort(0, O_PIN_4);
    bar_gore = 1;
    print("barrier up"); 
}

function barrier_down_auto() 
{
    IoPort.resetPort(0, O_PIN_4);
    bar_gore = 0;
    IoPort.setPort(0, O_PIN_23);
    bar_dolje = 1;
    print("barrier down");

 }

function stop_auto(ID)
{      	
    if(auto_mode == "ON")
    {
                auto_mode = "OFF";
	System.stopLaser();
	laser_status = "INACTIVE";
	laser_marking = 0;	
	System["sigTimer(int)"].disconnect(wait_for_pump);	
    }
    else { error_auto_aoff();}
}


function start_timer(ms, funkc, n)
{    
     print("starting timer delay: ", ms, " ms" );  
     System["sigTimer(int)"].connect(funkc);
}