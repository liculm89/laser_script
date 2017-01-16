function start_auto_mode()
{
    if(laser_rdy == 1)
    {		
	if(auto_mode == "OFF")
	{	
	    auto_mode = "ON";
	    laser_in_working_pos = 0;
	    laser_ref_auto();
	    System["sigTimer(int)"].connect(wait_for_pump);
	}
	else{error_manual_mode();}
    }
    else{error_laser_not_rdy();}
}

function laser_ref_auto()
{
    Axis.reset(2);
    print("laser is moving to reference pos");	    	    
}

var nom = 0;

function wait_for_pump(ID)
{
  if(timer5 == ID && auto_mode=="ON" && pump_present==1)
    {
      print("senzor linije active");
      print("nom =" + nom);
      print("laser_in_working_pos" + laser_in_working_pos);
      
        for(nom ;nom<1 ; nom++)
      {
	    if( laser_in_working_pos == 0 )
	    {
		barrier_down_auto();
		start_timer(time9_ms,wait_for_barrier);
	    }
	    else
	    {
	               start_timer(time9_ms,wait_for_barrier);
	    }
       }
     }
}

function wait_for_barrier(ID)
{
    if(timer9 == ID && (IoPort.getPort(0) & I_PIN_11) && (auto_mode == "ON"))
    {
        laser_move_timed();
        System["sigTimer(int)"].disconnect(wait_for_barrier);
    }
}

function laser_move_timed()
{   
	if( laser_in_working_pos == 0)
	{	    
	    Axis.move(2, (Axis.getPosition(2) - 150));
	    start_timer(time7_ms, stop_search_auto);   
	}
	else
	{
	    print("laser already in pos");
	    readFile_auto();
	    start_timer(time11_ms, pump_not_present);	    
	}  
}

function stop_search_auto(ID)
{
    if(timer7 == ID && auto_mode == "ON")
    {
	if(IoPort.getPort(0) & I_PIN_10)
	{ 	       
	    print("Laser is moving to working position");
	}
	else
	{
	    print("pump in laser focus");
	    Axis.stop(2);
	    readFile_auto();
	    laser_in_working_pos = 1;
	    start_timer(time11_ms, pump_not_present);	    
	    System["sigTimer(int)"].disconnect(stop_search_auto);	
	}
    }
    if(timer7 == ID && auto_mode =="OFF")
    {
            System["sigTimer(int)"].disconnect(stop_search_auto);
    }
}


function pump_not_present(ID)
{
        if(timer11 == ID && pump_present == 0 && auto_mode == "ON")
        {
                System.stopLaser();
	if(IoPort.getPort(0) & I_PIN_11)
	{
	    barrier_up_auto();
                }
	laser_marking = 0;
	laser_in_working_pos = 0;
	nom = 0; 
	System["sigTimer(int)"].disconnect(pump_not_present);
         }
        if(timer11 == ID && pump_present == 0 && auto_mode == "OFF")
       {
	    System["sigTimer(int)"].disconnect(pump_not_present);
        }
}


function readFile_auto()
{    
    if(laser_rdy == 1)
    {
	print("Reading file"); 		
	laser_marking = 1;
	readFile();
    }
    else{ error_laser_not_rdy(); }
}

function barrier_up_afer_marking(ID)
{
    if(timer6 == ID)
    {
	if(IoPort.getPort(0) & I_PIN_11)
	{    
	    barrier_up_auto();
	    laser_marking = 0;
	    laser_in_working_pos = 0;
	}
     System["sigTimer(int)"].disconnect(barrier_up_after_marking);
    }
}

function barrier_up_auto()
{   	
    print(auto_mode);
    IoPort.resetPort(0, O_PIN_23);
    bar_dolje = 0;
    //IoPort.setPort(0, O_PIN_2);
    IoPort.setPort(0, O_PIN_5);
    bar_gore = 1;
    print("barrier up"); 
}

function barrier_down_auto() 
{
    //IoPort.resetPort(0, O_PIN_2);
    IoPort.resetPort(0, O_PIN_5);
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
	nom= 0;
	System["sigTimer(int)"].disconnect(wait_for_pump);	
    }
    else { error_auto_aoff();}
}

function reset_laser_marking(ID)
{
    if(timer10 == ID && pump_present == 0)
    {	
	if(IoPort.getPort(0) & I_PIN_11)
	{    
	    barrier_up_auto();
                }
	laser_marking = 0;
	laser_in_working_pos = 0;
	nom = 0; 
	System["sigTimer(int)"].disconnect(reset_laser_marking);
    }
}


function start_timer(ms, funkc)
{    
    print("starting timer delay: " + ms + " ms");  
     System["sigTimer(int)"].connect(funkc);
}


