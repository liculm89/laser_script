function readFile_manual()
{
    if(total_stop == 0)
    {
        if(reg_fault == 0)
        {
            if(auto_mode == "OFF" )
            {
                if(laser_status == "Ready for marking")
                {    
                   if(confirm)
		    {
                    mark_auto();
                    signal_ready = 0;
                    timers[7] = System.setTimer(times[7]);
	        start_timer(timers[7], barrier_up_afer_marking_m);
	    }
		   else
		   {
		       error_selection_not_confirmed();
		   }
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
            error_regulator_faul();
        }
    }
    else
    {
        error_total_stop();
    }
}

function barrier_up_afer_marking_m(ID)
{
    if(timers[7] == ID)
    {
        if(IoPort.getPort(0) & I_PIN_11)
        {
            barrier_up_auto();
            laser_marking = 0;
            laser_in_working_pos = 0;
            signal_ready = 1;
            pumps_marked++;
        }
        xls_log();
        
        curr_sn = parseInt(last_sn) + 1;
        last_sn = curr_sn;
        last_sn = leftPad((last_sn),6);	 
        
        
        update_sn();
        disconnect_func(barrier_up_afer_marking_m);
    }
}

function laser_reference()
{
    if(total_stop == 0)
    {
        if(reg_fault == 0)
        {
            if(auto_mode == "OFF")
            {
                barrier_up();
                Axis.reset(2);
                if(debug_mode){print("Laser is moving to reference pos");}
            }
            else
            {
                error_auto_mode();
            }
        }
        else
        {
            error_regulator_faul();
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
        if(laser_status == "Marking is active" || laser_status == "Moving...")
        {
            System.stopLaser();
            disconnect_timers();
        }
        else
        {
	    if(debug_mode){ print("Laser and motor are not active");}
        }
    }
    else
    {
        error_auto_mode();
    }
}

function search_working_pos()
{  
    if(total_stop == 0)
    {
        if(auto_mode == "OFF")
        {
            barrier_down();
            Axis.move(2, (Axis.getPosition(2) - 150));
            timers[1] = System.setTimer(times[1]);
            start_timer(timers[1], stop_search);
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


function stop_search(ID)
{
    if(timers[1] == ID)
    {
        if(IoPort.getPort(0) & I_PIN_10)
        {
            current_pos = Axis.getPosition(2);
             if(!(IoPort.getPort(0) & I_PIN_8))    
            {
                if(debug_mode){print("Laser is moving to working position");}
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
                timers[4] = System.setTimer(times[4]);
                start_timer(timers[4], max_pos_reached);
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
    if(timers[4] == ID && auto_mode == "ON")
    {
        if(IoPort.getPort(0) & I_PIN_9)
        {
            Axis.stop(2);
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
            if(!(IoPort.getPort(0) & I_PIN_8))
            {	
                Axis.move(2, (Axis.getPosition(2) - sb1_v) );
                timers[4] = System.setTimer(times[4]);
                start_timer(timers[4], min_pos_reached);
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
    if(timers[4] == ID)
    {
        if(IoPort.getPort(0) & I_PIN_8)
        {
            if(debug_mode){ print("minimium pos reached");}
            Axis.stop(2);
            disconnect_func(min_pos_reached);
        }
    }
}

function stop_axis()
{	
    if (auto_mode == "OFF")
    {
        Axis.stop(2);
        if(debug_mode){ print ("Stop!");}
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
