////////////////////////////////////////////////////////////////////////////////////
//Connected with manual "Start marking" PushButton
/////////////////////////////////////////////////////////////////////////////////////
function readFile_manual() {
    if (total_stop == 0) {
        if (reg_fault == 0) {
            if (auto_mode == "OFF") {
                if (laser_status == "Ready for marking") {
                    if (confirm) {
                        if ((numW > numWC) || numW == 0) {
                            mark_manual();
                        }
                        else {
                            marking_quantity_complete();
                            pumps_marked = 0
                            le_num_w = "";
                        }
                    }
                    else {
                        error_selection_not_confirmed();
                    }
                }
                else {
                    error_key_sequence();
                }
            }
            else {
                error_auto_mode();
            }
        }
        else {
            error_regulator_faul();
        }
    }
    else {
        error_total_stop();
    }
}

function mark_manual() {
    write_log("Manual marking : Read file started");
    laser_marking = 1;
    nm = 1;
    laser_doc_update();
    log_arr = [];
    for (i = 0; i < dict_keys.length; i++) {
        log_arr.push(columns_dict[dict_keys[i]]);
    }
    write_log("Manual layout updated, marking is starting...");
    timers[11] = System.setTimer(times[11]);
    start_timer(timers[11], check_marking_manual);

    h_Doc_new.execute();
}

//
function check_marking_manual(ID) {
    /*  if (timers[11] == ID) {
          if (simulation_mode == 1) {
              if ((chkb_barriera.checked) && !(laser_status == "Marking is active")) {
                  barrier_up_afer_marking_m();
                  disconnect_func(check_marking);
              }
              else if ((laser_status = "Marking is active") && !(chkb_barriera.checked)) {
                  System.stopLaser();
                  laser_marking = 0;
                  nom = 0;
                  disconnect_timers();
              }
          }
          else {
              if ((IoPort.getPort(0) & I_PIN_11) && !(laser_status == "Marking is active")) {
                  barrier_up_afer_marking_m();
                  disconnect_func(check_marking);
              }
              else if ((laser_status = "Marking is active") && !(IoPort.getPort(0) & I_PIN_11)) {
                  System.stopLaser();
                  laser_marking = 0;
                  nom = 0;
                  disconnect_timers();
              }
          }
      }*/
    if (timers[11] == ID) {
        if ((IoPort.getPort(0) & I_PIN_11) && !(laser_status == "Marking is active")) {
            //disconnect_func(check_marking_manual);
            disconnect_func(check_marking_manual, ID);
            //barrier_up_after_marking();
        }
        else if ((laser_status = "Marking is active") && !(IoPort.getPort(0) & I_PIN_11)) {
            //disconnect_func(check_marking_manual);
            disconnect_func(check_marking_manual, ID);
            System.stopLaser();
            laser_marking = 0; laser_in_working_pos = 0;

            laser_ref_auto();
        }
    }
}

///////////////////////////////////////////////
//Raises barrier after marking
///////////////////////////////////////////////
function barrier_up_afer_marking_m() {
    write_log("Manual marking finished");
    if (IoPort.getPort(0) & I_PIN_11) {
        barrier_up_auto();
    }
    laser_marking = 0;
    laser_in_working_pos = 0;
    pumps_marked++;

    numWC++;
    xls_log();

    if (!(numWC % sn_marking_times)) {
        if (columns_dict["M"] != "/" && columns_dict["M"] != '') {
            if (!sn_fixed) {
                curr_sn = parseInt(last_sn, 10) + 1;
                last_sn = curr_sn;
                last_sn = leftPad((last_sn), 6);
                update_sn();
            }
        }
    }
    marking_ended();
}

//////////////////////////////////////////
//Manual laser referencing
//////////////////////////////////////////
function laser_reference() {
    if (total_stop == 0) {
        if (reg_fault == 0) {
            if (auto_mode == "OFF") {
                barrier_up();
                Axis.reset(2);
                if (debug_mode) { print("Laser is moving to reference pos"); }
            }
            else {
                error_auto_mode();
            }
        }
        else {
            error_regulator_faul();
        }
    }
    else {
        error_total_stop();
    }
}

////////////////////////////////////////////////////
//Connected with Stop pushbutton
////////////////////////////////////////////////////
function stop_m_manual() {
    if (auto_mode == "OFF") {
        if (laser_status == "Marking is active" || laser_status == "Moving...") {
            System.stopLaser();
            disconnect_timers();
        }
        else {
            if (debug_mode) { print("Laser and motor are not active"); }
        }
    }
    else {
        error_auto_mode();
    }
}

////////////////////////////////////////////////////////
//Manual search for working pos
///////////////////////////////////////////////////////
function search_working_pos() {
    if (total_stop == 0) {
        if (auto_mode == "OFF") {
            barrier_down();
            Axis.move(2, (Axis.getPosition(2) - search_distance));
            gen_timer(1, stop_search);
        }
        else {
            error_auto_mode();
        }
    }
    else {
        error_total_stop();
    }
}

////////////////////////////////////////////////////////////////////////////
//Function stops working pos. search
////////////////////////////////////////////////////////////////////////
function stop_search(ID) {
    if (timers[1] == ID && auto_mode == "OFF") {
        current_pos = Axis.getPosition(2);
        if (!(IoPort.getPort(0) & I_PIN_8)) { //***** Laser lowest position sensor
            if ((IoPort.getPort(0) & I_PIN_10)) {  //***** Optika
                if (!(current_pos <= (home_pos - search_distance))) {
                    if (debug_mode) { print("Laser is moving to working pos..."); }
                }
                else {
                    disconnect_func(stop_search, ID);
                    searching_error_manual(1); //Search distance reached
                }
            }
            else {
                Axis.stop(2);
                disconnect_func(stop_search, ID);
                write_log("Pump in laser focus");
                laser_in_working_pos = 1;
            }
        }
        else {
            disconnect_func(stop_search, ID);
            searching_error_manual(2); //LASER LOWEST POSITION
        }
    }
}

////////////////////////////
//Move laser up
//////////////////////////
function move_up() {
    if (total_stop == 0) {
        if (auto_mode == "OFF") {
            if (!(IoPort.getPort(0) & I_PIN_9)) {
                Axis.move(2, (Axis.getPosition(2) + sb1_v));
                laser_in_working_pos = 0;
                /*timers[4] = System.setTimer(times[4]);
                start_timer(timers[4], max_pos_reached);*/
                gen_timer(4, max_pos_reached);
            }
            else {
                error_max_pos();
            }
        }
        else {
            error_auto_mode();
        }
    }
    else {
        error_total_stop();
    }
}

/////////////////////////////////////////////////////
//Checks if laser max pos reached
/////////////////////////////////////////////////////
function max_pos_reached(ID) {
    if (timers[4] == ID && auto_mode == "ON") {
        if (IoPort.getPort(0) & I_PIN_9) {
            Axis.stop(2);
            disconnect_func(max_pos_reached, ID);
        }
    }
}

//////////////////////////////
//Move laser down
/////////////////////////////
function move_down() {
    if (total_stop == 0) {
        if (auto_mode == "OFF") {
            if (!(IoPort.getPort(0) & I_PIN_8)) {
                current_pos = Axis.getPosition(2);
                if (!(current_pos <= (home_pos - search_distance))) {
                    //if (debug_mode) { print("Laser is moving to working pos..."); }
                    Axis.move(2, (Axis.getPosition(2) - sb1_v));
                    timers[4] = System.setTimer(times[4]);
                    start_timer(timers[4], min_pos_reached);
                    laser_in_working_pos = 0;
                }
                else {
                    error_min_pos();
                    //searching_error(1); //Search distance reached
                }

            }
            else {
                error_min_pos();
            }
        }
        else {
            error_auto_mode();
        }
    }
    else {
        error_total_stop();
    }
}

/////////////////////////////////////////////////////
//Checks if laser min pos. reached
/////////////////////////////////////////////////////
function min_pos_reached(ID) {
    if (timers[4] == ID) {
        if (IoPort.getPort(0) & I_PIN_8) {
            if (debug_mode) { print("minimium pos reached"); }
            Axis.stop(2);
            disconnect_func(min_pos_reached);
        }
    }
}

/////////////////////////////////////////
//Laser axis movement stop
////////////////////////////////////////
function stop_axis() {
    if (auto_mode == "OFF") {
        Axis.stop(2);
        if (debug_mode) { print("Stop!"); }
        disconnect_timers();
    }
    else {
        error_auto_mode();
    }
}

//////////////////////////////////////
//Manual barrier rising
/////////////////////////////////////
function barrier_up() {
    if (total_stop == 0) {
        if (auto_mode == "OFF") {
            IoPort.resetPort(0, O_PIN_23);
            bar_dolje = 0;
            IoPort.setPort(0, O_PIN_5);
            bar_gore = 1;
        }
        else {
            error_auto_mode();
        }
    }
    else {
        error_total_stop();
    }
}

/////////////////////////////////////////
//Manual barrier lowering
/////////////////////////////////////////
function barrier_down() {
    if (total_stop == 0) {
        if (auto_mode == "OFF") {
            IoPort.resetPort(0, O_PIN_5);
            bar_gore = 0;
            IoPort.setPort(0, O_PIN_23);
            bar_dolje = 1;
        }
        else {
            error_auto_mode();
        }
    }
    else {
        error_total_stop();
    }
}
