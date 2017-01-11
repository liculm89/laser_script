function start_auto_mode()
{
    if(auto_mode == "OFF")
    {	
	auto_mode = "ON";
	start_timer(time2_ms, readFile_auto);
    }
    else{error_manual_mode();}
}


function readFile_auto(ID)
{    
    if(timer2 == ID);
    {
	if(laser_marking == 0 &&  sen_linija == 0) 
	{	
	    if(total_stop == 1)
	    {
		if(laser_status == "INACTIVE") 
		{	
		
		 laser_marking = 1;
		//referenciranje, pozicioniranje i onda readfile();
		
		 if(laser_in_working_pos == 0)
		 {
		      print("searching for working pos...");
		      laser_ref_auto();
		      barrier_down_auto();
		      search_working_pos();	
		 }  
		      readFile();
	                 }
		else {error_manual_mode(); }
	    }
	    else{error_total_stop();}
	}
    }
}

function laser_ref_auto()
{
    if(sen_bar_dolje == 1)
    { 	 
	print("rising barrier");
	barrier_up_auto();
	Axis.reset(2);
     }   
    else
    {Axis.reset(2);}
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
	//System.killTimer(timer2);
	System["sigTimer(int)"].disconnect(readFile_auto);
	//print("timer2 killed");
    }
    else { error_auto_aoff();}
}


function start_timer(ms, funkc, n)
{    
     print("starting timer delay: ", ms, " ms" );  
     System["sigTimer(int)"].connect(funkc);
}