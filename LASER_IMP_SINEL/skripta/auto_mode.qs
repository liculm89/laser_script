function start_auto_mode()
{
    if(total_stop == 0)
    {  
            if(auto_mode == "OFF")
            {
                auto_mode = "ON";
                laser_in_working_pos = 0;
                laser_ref_auto();
                timer5 = System.setTimer(time5_ms); 
	start_timer(timer5, wait_for_pump);	
                //System["sigTimer(int)"].connect(wait_for_pump);
            }
            else
            {
                error_manual_mode();
            }
        }
    
    else
    {
       error_total_stop();
    }
}

function laser_ref_auto()
{
    if(total_stop == 0)
    {
        Axis.reset(2);
        print("laser is moving to reference pos");
    }
    else
    {
       //error_total_stop();
    }
}

function wait_for_pump(ID)
{
    if(total_stop == 0)
    {
        if((timer5 == ID) && (auto_mode == "ON") && (pump_present == 1))
        {
            print("senzor linije active");
            print("nom =" + nom);
            print("laser_in_working_pos" + laser_in_working_pos);

            for(nom; nom<1; nom++)
            {
                if(laser_in_working_pos == 0)
                {
                    barrier_down_auto();
	    timer9 = System.setTimer(time9_ms); 	    
                    start_timer(timer9,wait_for_barrier);
                }
                else
                {
                    timer9 = System.setTimer(time9_ms); 
                    start_timer(timer9,wait_for_barrier);
                }
            }
        }
    }
    else
    {
        error_total_stop();
       //System["sigTimer(int)"].disconnect(wait_for_pump);
    }
}

function wait_for_barrier(ID)
{
    if(total_stop == 0)
    {
        if(timer9 == ID && (IoPort.getPort(0) & I_PIN_11) && (auto_mode == "ON"))
        {
            laser_move_timed();
            System["sigTimer(int)"].disconnect(wait_for_barrier);
        }
    }
    else
    {
        error_total_stop();
        //System["sigTimer(int)"].disconnect(wait_for_pump);
        //System["sigTimer(int)"].disconnect(wait_for_barrier);
    }
}

function laser_move_timed()
{   
    if(total_stop == 0)
    {
        if(laser_in_working_pos == 0)
	    {      	    
	        Axis.move(2, (Axis.getPosition(2) - search_distance));
	        timer7 = System.setTimer(time7_ms); 
	        start_timer(timer7, stop_search_auto);   
	    }
	    else
	    {
	        print("laser already in pos");
	        readFile_auto();
	        start_timer(timer11, pump_not_present);	    
	    }
    }
}


function stop_search_auto(ID)
{
    if(timer7 == ID && auto_mode == "ON")
    {
        if(IoPort.getPort(0) & I_PIN_10)
        {
            current_pos = Axis.getPosition(2);
            if((home_pos - current_pos) <= search_distance)
            {
                print("Laser is moving to working position");
            }
            else
            {
                Axis.stop(2);
                laser_ref_auto();
                barrier_up_auto();
                error_cant_find_pump();
                System["sigTimer(int)"].disconnect(stop_search_auto);
            }
        }
        else
        {
            print("pump in laser focus");
            Axis.stop(2);
            readFile_auto();
            laser_in_working_pos = 1;
            timer11 = System.setTimer(time11_ms);    
            start_timer(timer11, pump_not_present);
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
    if((timer11 == ID) && (pump_present == 0) && (auto_mode == "OFF"))
    {
        System["sigTimer(int)"].disconnect(pump_not_present);
    }
}

function readFile_auto()
{    
    if(total_stop == 0)
    {
        print("Reading file");
        laser_marking = 1;
        timer6 = System.setTimer(time6_ms);
        start_timer(timer6, barrier_up_afer_marking);
        readFile();
    }
    else
    {
    	error_total_stop(); 
    }
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
        System["sigTimer(int)"].disconnect(barrier_up_afer_marking);
    }
}

function barrier_up_auto()
{   	
    IoPort.resetPort(0, O_PIN_23);
    bar_dolje = 0;
    IoPort.setPort(0, O_PIN_5);
    bar_gore = 1;
    print("barrier up"); 
}

function barrier_down_auto() 
{
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
    else
    {
        error_auto_aoff();
    }
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

function total_stop_func()
{
    System.stopLaser();
    laser_marking = 0;
    laser_in_working_pos = 0;
    if(auto_mode == "ON")
    {
        auto_mode = "OFF";
        disconnect_timers();
    }
    else
    {
        disconnect_timers();    
    }
}

function reset_button_func()
{
    System.stopLaser();
    laser_marking = 0;
    laser_in_working_pos = 0;
    nom = 0;
    if(auto_mode == "ON")
    {
	    auto_mode = "OFF";
	    disconnect_timers();
	    start_auto_mode();
    }
    else
    {	
        disconnect_timers();
        laser_reference();
    }
}

function start_timer(timer, funkc)
{    
    print("connecting timer:" + timer);  
    System["sigTimer(int)"].connect(funkc);
    timer_list.push(funkc);
}
