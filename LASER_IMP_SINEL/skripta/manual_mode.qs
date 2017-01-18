function readFile_manual()
{
    if(total_stop == 0)
    {
        if(auto_mode == "OFF" )
        {
            if(laser_status == "Ready for marking")
            {
                readFile();
            }
            else
            {
                error_key_sequence();
            }
        }
        else
        {
            error_auto_mode();
        }
    }
    else
    {
        error_total_stop();
    }
}

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

function stop_m_manual()
{
    
    if(auto_mode == "OFF")
    {
        if(laser_status == "Marking is active" || laser_status == "Moving...")
        {
            System.stopLaser();
            disconnect_timers();
        }
        else
        {
            print("Laser and motor are not active");
        }
    }
    else
    {
        error_auto_mode();
    }
}

function search_working_pos()
{  
    barrier_down();
    Axis.move(2, (Axis.getPosition(2) - 150));
    timer7 = System.setTimer(time7_ms);
    start_timer(timer7, stop_search);
}

function stop_search(ID)
{
    if(timer7 == ID)
    {
        if(IoPort.getPort(0) & I_PIN_10)
        {
            current_pos = Axis.getPosition(2);
            if((home_pos - current_pos) <= search_distance)
            {
                //print("Laser is moving to working position");
            }
            else
            {
                Axis.stop(2);
                error_cant_find_pump();
                laser_reference();
                disconnect_func(stop_search);
            }
        }
        else
        {
            Axis.stop(2);
            laser_in_working_pos = 1;
            disconnect_func(stop_search);
        }
    }
}

function move_up()
{ 
    if(total_stop == 0)
    {
        if (auto_mode == "OFF")
        {
            if(!(IoPort.getPort(0) & I_PIN_9))
            {
                Axis.move(2, (Axis.getPosition(2) + sb1_v) );
                laser_in_working_pos = 0;
                timer7 = System.setTimer(time7_ms);
                start_timer(timer7, max_pos_reached);
            }
            else
            {
                error_max_pos();
            }
        }
        else
        {
            error_auto_mode();
        }
    }
    else
    {
        error_total_stop();
    }
}

function max_pos_reached(ID)
{
    if(timer7 == ID)
    {
        if(IoPort.getPort(0) & I_PIN_9)
        {
            Axis.stop(2);
            error_max_pos();
            disconnect_func(max_pos_reached);
        }
    }
}

function move_down()
{
    if(total_stop == 0)
    {
        if (auto_mode == "OFF")
        {
            current_pos = Axis.getPosition(2);
            if(!(IoPort.getPort(0) & I_PIN_8))
            {
                Axis.move(2, (Axis.getPosition(2) - sb1_v) );
                timer7 = System.setTimer(time7_ms);
                start_timer(timer7, min_pos_reached);
                laser_in_working_pos = 0;
            }
            else
            {
                error_min_pos();
            }
        }
        else
        {
            error_auto_mode();
        }
    }
    else
    {
        error_total_stop();
    }
}

function min_pos_reached(ID)
{
    if(timer7 == ID)
    {
        if(IoPort.getPort(0) & I_PIN_8)
        {
            Axis.stop(2);
            error_min_pos();
            disconnect_func(min_pos_reached);
        }
    }
}

function stop_axis()
{	
    if (auto_mode == "OFF")
    {
        Axis.stop(2);
        print ("Stop!");
        disconnect_timers();
    }
    else
    {
        error_auto_mode();
    }
}

function barrier_up()
{
    if(total_stop == 0)
    {
        if(auto_mode == "OFF")
        {
            IoPort.resetPort(0, O_PIN_23);
            bar_dolje = 0;
            IoPort.setPort(0, O_PIN_5);
            bar_gore=1;
        }
        else
        {
            error_auto_mode();
        }
    }
    else
    {
        error_total_stop();
    }
}

function barrier_down()
{
    if(total_stop == 0)
    {
        if (auto_mode == "OFF")
        {
            IoPort.resetPort(0, O_PIN_5);
            bar_gore = 0;
            IoPort.setPort(0, O_PIN_23);
            bar_dolje = 1;
        }
        else
        {
            error_auto_mode();
        }
    }
    else
    {
        error_total_stop();
    }
}
