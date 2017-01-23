function start_auto_mode()
{
    if(total_stop == 0)
    {
        if(auto_mode == "OFF")
        {
            if(laser_status == "Ready for marking")
            {
                auto_mode = "ON";
                if(debug_mode){ print("Auto mode started");}
                laser_in_working_pos = 0;
                laser_ref_auto();
                timers[4] = System.setTimer(times[4]);
                start_timer(timers[4], wait_for_pump);
            }
            else
            {
                error_key_sequence();
            }
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

function stop_auto(ID)
{      	
    if(auto_mode == "ON")
    {
        auto_mode = "OFF";
        System.stopLaser();
        laser_marking = 0;
        nom= 0;
        disconnect_func(wait_for_pump);
    }
    else
    {
        error_auto_aoff();
    }
}


function laser_ref_auto()
{
    if(total_stop == 0)
    {
        Axis.reset(2);
    }
}

function wait_for_pump(ID)
{
    if((timers[4] == ID) && (auto_mode == "ON") && (pump_present == 1))
    {
        if(debug_mode)
	{ 
	    print("nom =" + nom);  
	    print("laser_in_working_pos" + laser_in_working_pos); 
	}
        for(nom; nom<1; nom++)
        {
            if(laser_in_working_pos == 0)
            {
                barrier_down_auto();
                timers[6] = System.setTimer(times[6]);
                start_timer(timers[6],wait_for_barrier);
            }
            else
            {
                timers[6] = System.setTimer(times[6]);
                start_timer(timers[6],wait_for_barrier);
            }
        }
    }
}

function wait_for_barrier(ID)
{
    if((timers[6] == ID) && (IoPort.getPort(0) & I_PIN_11))
    {
        laser_move_timed();
        disconnect_func(wait_for_barrier);
    }
}

function laser_move_timed()
{      
    if(laser_in_working_pos == 0)
    {
        Axis.move(2, (Axis.getPosition(2) - search_distance));
        timers[1] = System.setTimer(time[1]);
        start_timer(timers[1], stop_search_auto);
    }
    if(laser_in_working_pos == 1)
    {
        if(debug_mode){ print("Laser already in pos");}
        readFile_auto();
        timers[2] = System.setTimer(times[2]);
        start_timer(timers[2], pump_not_present);
    }
}

function stop_search_auto(ID)
{
    if(timers[1] == ID && auto_mode == "ON")
    {
        if(IoPort.getPort(0) & I_PIN_10)
        {
            current_pos = Axis.getPosition(2);
            if((home_pos - current_pos) <= search_distance)
            {
                if(debug_mode){print("Laser is moving to working pos...");}
            }
            else
            {
                Axis.stop(2);
                laser_ref_auto();
                barrier_up_auto();
                error_cant_find_pump();
                disconnect_func(stop_search_auto);
            }
        }
        else
        {
            if(debug_mode){ print("Pump in laser focus");}
            Axis.stop(2);
            readFile_auto();
            laser_in_working_pos = 1;
            timers[2] = System.setTimer(times[2]);
            start_timer(timers[2], pump_not_present);
            disconnect_func(stop_search_auto);
        }
    }
}

function pump_not_present(ID)
{
    if(timers[2] == ID && pump_present == 0 && auto_mode == "ON")
    {
        System.stopLaser();
        if(IoPort.getPort(0) & I_PIN_11)
        {
            barrier_up_auto();
        }
        laser_marking = 0;
        laser_in_working_pos = 0;
        nom = 0;
        disconnect_func(pump_not_present);
    }
}

function readFile_auto()
{    
    if(debug_mode){ print("Read file started");}
    laser_marking = 1;
    timers[7] = System.setTimer(times[7]);
    start_timer(timers[7], barrier_up_afer_marking);
    readFile();
}
    
function barrier_up_afer_marking(ID)
{
    if(timers[7] == ID)
    {
        if(IoPort.getPort(0) & I_PIN_11)
        {
            barrier_up_auto();
            laser_marking = 0;
            laser_in_working_pos = 0;
            timers[5] = System.setTimer(times[5]);
            start_timer(timers[5], reset_laser_marking);
        }
        disconnect_func(barrier_up_afer_marking);
    }
}

function barrier_up_auto()
{   	
    IoPort.resetPort(0, O_PIN_23);
    bar_dolje = 0;
    IoPort.setPort(0, O_PIN_5);
    bar_gore = 1;
}

function barrier_down_auto() 
{
    IoPort.resetPort(0, O_PIN_5);
    bar_gore = 0;
    IoPort.setPort(0, O_PIN_23);
    bar_dolje = 1;
}

function reset_laser_marking(ID)
{
    if((timers[5] == ID) && (pump_present == 0))
    {
        nom = 0;
        disconnect_func(reset_laser_marking);
    }
}

function total_stop_func()
{
    if(auto_mode == "ON")
    {
        System.stopLaser();
        disconnect_timers();
        laser_marking = 0;
        laser_in_working_pos = 0;
        nom = 0;
        auto_mode = "OFF";
    }
    if(auto_mode == "OFF")
    {
        System.stopLaser();	
        disconnect_timers();
    }
}

function reset_auto(ID)
{
    if((timers[5] == ID) && (IoPort.getPort(0) & I_PIN_9))
    {
        if(debug_mode){ print("Reseting auto mode!");}
        start_auto_mode();
        disconnect_func(reset_auto);
    }
}

function reset_button_func()
{
    if(total_stop == 0)
    {
	if(auto_mode == "ON")
	{
	    System.stopLaser();
	    disconnect_timers();
	    laser_marking = 0;
	    laser_in_working_pos = 0;
	    nom = 0;
	    auto_mode = "OFF";
	    timers[5] = System.setTimer(times[5]);
	    start_timer(timers[5], reset_auto);
	}
	if(auto_mode == "OFF")
	{
	    System.stopLaser();
	    disconnect_timers();
	    laser_reference();
	}
    }
    else
    {
	error_total_stop();
    }
}
