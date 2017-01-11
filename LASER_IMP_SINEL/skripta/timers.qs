function start_auto_mode()
{
    if(auto_mode == "OFF")
    {	
	auto_mode = "ON";
	time2_ms = 50;
	timer2 = System.setTimer(time_ms);
	start_timer(time2_ms, readFile_auto);
    }
    else{error_manual_mode();}
}

function stop_auto(ID)
{      	
    if( timer2 == ID)
    {
	auto_mode = "OFF";
	System.stopLaser();
	laser_status = "INACTIVE";
	System.killTimer(timer2);
	System["sigTimer(int)"].disconnect(readFile_auto);
	print("timer2 killed");
    }
}



function start_timer(ms, funkc, n)
{    
     print("starting timer delay: ", ms, " ms" );  
     System["sigTimer(int)"].connect(funkc);
}