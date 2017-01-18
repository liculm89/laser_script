function start_auto_mode()
{
    if(total_stop == 0)
    {
        if(auto_mode == "OFF")
        {
            if(laser_status == "Ready for marking")
            {
                auto_mode = "ON";
                laser_in_working_pos = 0;
                laser_ref_auto();
                timer5 = System.setTimer(time5_ms);
                start_timer(timer5, wait_for_pump);
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

function laser_ref_auto()
{
    if(total_stop == 0)
    {
        Axis.reset(2);
    }
}

function wait_for_pump(ID)
{
    if((timer5 == ID) && (auto_mode == "ON") && (pump_present == 1))
    {
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

function wait_for_barrier(ID)
{
    if((timer9 == ID) && (IoPort.getPort(0) & I_PIN_11))
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
        timer7 = System.setTimer(time7_ms);
        start_timer(timer7, stop_search_auto);
    }
    if(laser_in_working_pos == 1)
    {
        print("laser already in pos");
        readFile_auto();
        start_timer(timer11, pump_not_present);
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
                disconnect_func(stop_search_auto);
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
            disconnect_func(stop_search_auto);
        }
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
        disconnect_func(pump_not_present);
    }
}

function readFile_auto()
{    
    print("Reading file");
    laser_marking = 1;
    timer6 = System.setTimer(time6_ms);
    start_timer(timer6, barrier_up_afer_marking);
    readFile();
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
            timer10 = System.setTimer(time10_ms);
            start_timer(timer10, reset_laser_marking);
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
        laser_marking = 0;
        nom= 0;
        disconnect_func(wait_for_pump);
    }
    else
    {
        error_auto_aoff();
    }
}

function reset_laser_marking(ID)
{
    if((timer10 == ID) && (pump_present == 0))
    {
        /*
        if(IoPort.getPort(0) & I_PIN_11)
        {
            barrier_up_auto();
        }*/
        //laser_marking = 0;
        //laser_in_working_pos = 0;
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
        error_total_stop();
    }
    if(auto_mode == "OFF")
    {
        System.stopLaser();
        disconnect_timers();
    }
}

function reset_button_func()
{
    if(auto_mode == "ON")
    {
        System.stopLaser();
        disconnect_timers();
        laser_marking = 0;
        laser_in_working_pos = 0;
        nom = 0;
        auto_mode = "OFF";
        timer11 = System.setTimer(time11_ms);
        start_timer(timer11, reset_auto);
    }
    if(auto_mode == "OFF")
    {
        System.stopLaser();
        disconnect_timers();
        laser_reference();
    }
}

function reset_auto(ID)
{
    if((timer11 == ID) && (IoPort.getPort(0) & I_PIN_9))
    {
        start_auto_mode();
        disconnect_func(reset_auto);
    }
}
