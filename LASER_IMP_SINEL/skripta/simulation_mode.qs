
/*""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""*
FUNCTIONS NEEDED FOR SIMULATION MODE
*"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""*/

function wait_for_pump_sim(ID) {
    if ((timers[4] == ID) && (auto_mode == "ON") && (pump_present == 1)) {
        disconnect_func(wait_for_pump_sim);
        barrier_down_auto();
        write_log(" Simulation - new pump has arrived, barrier going down ...");
        gen_timer(6, wait_for_barrier_sim);
    }

}

function wait_for_barrier_sim(ID) {
    if ((timers[6] == ID) && (chkb_barriera.checked)) {
        write_log("Barrier is lowered, searching for pump...");
        disconnect_func(wait_for_barrier_sim);
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
                    Axis.stop(2);
                    write_log("Search distance passed but no pump found. Going back to ref...");
                    laser_ref_auto(); barrier_up_auto();
                    disconnect_func(stop_search_auto_sim);
                    retry_stop_choice();
                }
            }
            else {
                write_log("Pump in laser focus");
                disconnect_func(stop_search_auto_sim);
                Axis.stop(2);
                laser_in_working_pos = 1;
                //Input compensation function if needed here
                mark_auto_sim();
            }
        }
        else {
            disconnect_func(stop_search_auto_sim);
            write_log("Laser lower position reached, no pump found, going back to ref...");
            Axis.stop(2);
            laser_ref_auto(); laser_ref_auto();
            barrier_up_auto();
            retry_stop_choice();
        }
    }
}

function mark_auto_sim() {

    laser_marking = 1;
    nom = 1;
    laser_doc_update();
    log_arr = [];
    for (i = 0; i < dict_keys.length; i++) {
        log_arr.push(columns_dict[dict_keys[i]]);
    }
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
        if (chkb_optika.checked) {
            if ((chkb_barriera.checked) && !(laser_status == "Marking is active")) {
                barrier_up_after_marking();
                disconnect_func(check_marking_sim);
            }
            else if ((laser_status = "Marking is active") && !(chkb_barriera.checked)) {
                disconnect_func(check_marking_sim);
                marking_failed(3);
            }
        }
        else {
            disconnect_func(check_marking_sim);
            marking_failed(4);
        }
    }
}

function reset_auto_func_sim(ID) {

    if (timers[13] == ID) {
        write_log("Resetting auto mode! Simulation mode *****************");
        //reset_auto = 1;
        if (auto_mode == "ON"); {
			stop_auto();
		}
        disconnect_func(reset_auto_func_sim);
        if (columns_dict["M"] != "/" && columns_dict["M"] != '') {
            serial_choice();
        }

    }
}
/*************************************************
 * END SIMULATION FUNCTIONS
 *************************************************/