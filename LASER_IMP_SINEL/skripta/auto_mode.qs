function start_auto_mode()
{
    if(auto_mode == "OFF")
    {	
	auto_mode = "ON";
	laser_ref_auto();
	System["sigTimer(int)"].connect(wait_for_pump);
    }
    else{error_manual_mode();}
}
var nom = 0;

function wait_for_pump(ID)
{
  if(timer5 == ID && auto_mode=="ON" && IoPort.getPort(0) & I_PIN_7)
    {
         print("pump senzor active!");
         if( laser_in_working_pos == 0)
         {
	     for(nom ;nom<1 ; nom++)
	     {   
		barrier_down_auto();
		start_timer(time8_ms, laser_move_timed);
                      }
           }
           else
           {   	     
                     print("*******automatic marking started**********");
	     readFile_auto();
            }
     }
    
}

function laser_move_timed(ID)
{
    if( timer8 == ID)
    {
	if( laser_in_working_pos == 0)
	{
	    Axis.move(2, (Axis.getPosition(2) - 150));
	    start_timer(time7_ms, stop_search_auto);   
	}
	else
	{
	    print("laser already in pos");
	    System["sigTimer(int)"].disconnect(laser_move_timed);
	}
    }
}

function stop_search_auto(ID)
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
function laser_moveto_pos_auto(ID)
{  
    if (timer3 == ID)
    {
	//print("tick move_to_pos");
	if(IoPort.getPort(0) & I_PIN_10)
	{
	    print("laser moving");
                    Axis.move(2, (Axis.getPosition(2)-1));
	}
	else
	{	
	    print("Laser is in working position, beam signal recieved");
	    laser_in_working_pos = 1;
	    //print("killing timer move_to_pos");
	    //System.killTimer(timer3);
            nom = 0;
	    System["sigTimer(int)"].disconnect(laser_moveto_pos_auto);
	}
    }
}
*/

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
	System["sigTimer(int)"].disconnect(wait_for_pump);	
    }
    else { error_auto_aoff();}
}

function reset_laser_marking(ID)
{
    if(timer6 == ID)
    {
                barrier_up_auto;
	laser_marking = 0;
	System["sigTimer(int)"].disconnect(reset_laser_marking);
    }
}


function start_timer(ms, funkc, n)
{    
     print("starting timer delay: ", ms, " ms" );  
     System["sigTimer(int)"].connect(funkc);
}


