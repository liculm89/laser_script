
/*""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""*
FUNCTIONS NEEDED FOR SIMULATION MODE
*"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""*/

function wait_for_pump_sim(ID) {
    if ((timers[4] == ID) && (auto_mode == "ON") && (pump_present == 1)) {
        disconnect_func(wait_for_pump_sim, ID);
        write_log("Simulation - new pump has arrived, barrier going down ...");
        barrier_down_auto();
        gen_timer(6, wait_for_barrier_sim);
    }

}

function wait_for_barrier_sim(ID) {
    if ((timers[6] == ID) && (chkb_barriera.checked)) {
        disconnect_func(wait_for_barrier_sim, ID);
        write_log("Simulation - Barrier is lowered, searching for pump...");
        laser_move_timed();
    }
}

function stop_search_auto_sim(ID) {
    if (timers[1] == ID && auto_mode == "ON") {
        current_pos = Axis.getPosition(2);
        if (!(chkb_lp.checked)) {
            if (!(chkb_optika.checked)) {
                if (!(current_pos <= (home_pos - search_distance))) {
                    if (debug_mode) { print("Laser is moving to working pos..."); }
                }
                else {
                    searching_error(1, ID);
                }
            }
            else {
                write_log("Pump in laser focus");
                disconnect_func(stop_search_auto_sim, ID);
                Axis.stop(2);
                laser_in_working_pos = 1;
                gen_timer(15, compensation);
            }
        }
        else {
            searching_error(2, ID);
        }
    }
}

function mark_auto_sim() {

    laser_marking = 1;
    if (chkb_optika.checked) {
        if (chkb_barriera.checked) {
            h_Doc_new.execute();
            write_log("simulation auto marking started");
            gen_timer(11, check_marking_sim);
        }
        else {
            marking_failed(1);
        }
    }
    else {
        marking_failed(2);
    }
}

function check_marking_sim(ID) {
    if (timers[11] == ID) {
        check_laser_state(System.getDeviceStatus());
        if ((chkb_barriera.checked) && !(laser_status == "Marking is active")) {
            disconnect_func(check_marking_sim, ID);
            barrier_up_after_marking();

        }
        else if ((laser_status = "Marking is active") && !(chkb_barriera.checked)) {
            disconnect_func(check_marking_sim, ID);
            marking_failed(3);
        }
    }
}

function reset_laser_marking_sim(ID) {
    if ((timers[5] == ID) && (pump_present == 0)) {
        disconnect_func(reset_laser_marking_sim, ID);
        write_log("Marking successful, incrementing serial number and setting signal done");

        if ((numW > numWC) || numW == 0) {
            if (auto_waiting_to_stop == 1) {
                gen_timer(14, wait_for_marking_end);
            }
            else {
                write_log("starting wait_for_pump_sim from reset_laser marking");
                gen_timer(4, wait_for_pump_sim);
            }
        }
        else {
            stop_auto();
            write_log("Marking quantity reached! Stoping auto mode");
            marking_quantity_complete();
            pumps_marked = 0;
            le_num_w = "";
        }
        pumps_marked++;
    }
}

function reset_auto_func_sim(ID) {

    if (timers[13] == ID) {
        write_log("Resetting auto mode! Simulation mode *****************");
        disconnect_func(reset_auto_func_sim, ID);
        laser_marking = 0;
        barrier_up_auto();
        if (columns_dict["M"] != "/" && columns_dict["M"] != '') {
            serial_choice();
        }
        else{
            without_serial_choice();
        }

    }
}
/*************************************************
 * END SIMULATION FUNCTIONS
 *************************************************/