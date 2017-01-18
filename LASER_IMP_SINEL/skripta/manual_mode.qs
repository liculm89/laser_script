function readFile_manual()
{
    if(total_stop == 0)
    {
        if(auto_mode == "OFF" && laser_status != "ACTIVE")
        {
            readFile();
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

function stop_m_manual()
{
    if(auto_mode == "OFF")
    {
        System.stopLaser();
        laser_status = "INACTIVE";
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
                //System["sigTimer(int)"].disconnect(stop_search);
            }
        }
        else
        {
            Axis.stop(2);
            laser_in_working_pos = 1;
            disconnect_func(stop_search);    
            //System["sigTimer(int)"].disconnect(stop_search);
        }
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

function move_up()
{ 
    if(total_stop == 0)
    {
        if (auto_mode == "OFF")
        {
            print( "Current Z axis poz before: " + Math.round(Axis.getPosition(2)));
            Axis.move(2, (Axis.getPosition(2) + sb1_v) );
            laser_in_working_pos = 0;
            print( "Current Z axis poz after: " + Math.round(Axis.getPosition(2)));
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

function move_down()
{
    if(total_stop == 0)
    {
        if (auto_mode == "OFF")
        {
            current_pos = Axis.getPosition(2);
            if(!(IoPort.getPort(0) & I_PIN_8) && (current_pos - sb1_v >= min_pos))
            {  
		
                Axis.move(2, (Axis.getPosition(2) - sb1_v) );
                laser_in_working_pos = 0;
                print( "Current Z axis poz after: " + Math.round(Axis.getPosition(2)));
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

function stop_axis()
{	
    if (auto_mode == "OFF")
    {
        print( "Current Z axis poz: " + Math.round(Axis.getPosition(2)));
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


