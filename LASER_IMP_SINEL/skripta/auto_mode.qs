/////////////////////////////////////////////////
//AUTO MODE START function
/////////////////////////////////////////////////
function start_auto_mode() {
	if (total_stop == 0) {
		if (reg_fault == 0) {
			if (auto_mode == "OFF") {
				if (laser_status == "Ready for marking") {
					if (confirm) {
						System.collectGarbage();
						auto_mode = "ON";
						get_quantity();
						barrier_up_auto();
						if (reset_auto == 1) {
							if (sen_linija == 1) {
								delete timers[10];
								timers[10] = System.setTimer(times[10]);
								start_timer(timers[10], send_signal_done);
								reset_auto = 0;
							}
						}
						numWC = 0;
						write_log("Auto mode started");
						auto_waiting_to_stop = 0;
						laser_in_working_pos = 0;
						laser_barrier_down = 0;
						laser_ref_auto();
						gen_timer(4, wait_for_pump);
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
				error_manual_mode();
			}
		}
		else {
			error_regulator_fault();
		}
	}
	else {
		error_total_stop();
	}
}

//////////////////////////////////////////////////////////////////////////////
//Laser auto mode is on, waits for external signal
/////////////////////////////////////////////////////////////////////////////
function wait_for_pump(ID) {

	if ((timers[4] == ID) && (auto_mode == "ON") && (pump_present == 1)) {
		for (nom; nom < 1; nom++) {
			//if (laser_in_working_pos == 0) {
			barrier_down_auto();
			write_log("new pump has arrived, barrier going down ...");

			if (simulation_mode) {
				gen_timer(6, wait_for_barrier_sim);
			}
			else {
				gen_timer(6, wait_for_barrier);
			}
		}
		/*else {
			gen_timer(6, wait_for_barrier);
		}*/
	}
}

////////////////////////////////////
//Laser waits for barrier
/////////////////////////////////////
function wait_for_barrier(ID) {
	//Laser must find pump before laser marking is performed. 
	if ((timers[6] == ID) && (IoPort.getPort(0) & I_PIN_11)) {
		if (debug_mode) { print("Barrier is lowered"); }
		//Laser already found pump in previus step and goes into marking procedue
		if (laser_barrier_down == 1) {
			print("laser already in position");
			mark_auto();
			gen_timer(2, pump_not_present);
		}//Used during initial pump seach
		else {
			disconnect_func(wait_for_barrier);
			laser_move_timed();
		}
		disconnect_func(wait_for_barrier);
	}
}

//////////////////////////////////////////////////////////////////
//Laser moves and starts timers
//////////////////////////////////////////////////////////////////
function laser_move_timed() {
	if (laser_in_working_pos == 0) {
		write_log("Laser is moving into working position, searching for pump...");
		Axis.move(2, (Axis.getPosition(2) - search_distance));
		if (simulation_mode) {
			gen_timer(1, stop_search_auto_sim);
		}
		else {
			gen_timer(1, stop_search_auto);
		}
	}
	//if (laser_in_working_pos == 1) {
	else {
		write_log("Laser already in position, initiating marking process...");
		if (simulation_mode) {
			mark_auto_sim();
		}
		else {
			mark_auto();
		}
		gen_timer(2, pump_not_present);
	}
}

////////////////////////////////////////////////////////////////////
//Laser moves until working pos. is reached
////////////////////////////////////////////////////////////////////
function stop_search_auto(ID) {
	if (timers[1] == ID && auto_mode == "ON") {
		current_pos = Axis.getPosition(2);

		if (!(IoPort.getPort(0) & I_PIN_8)) { //laser lowest position sensor
			if ((IoPort.getPort(0) & I_PIN_10)) {  //Optika

				if (!(current_pos <= (home_pos - search_distance))) {
					if (debug_mode) { print("Laser is moving to working pos..."); }
				}
				else {
					Axis.stop(2);
					write_log("Search distance passed but no pump found. Going back to ref...");
					laser_ref_auto(); laser_ref_auto();
					barrier_up_auto();
					disconnect_func(stop_search_auto);
					retry_stop_choice();
				}
			}
			else {
				write_log("Pump in laser focus");
				disconnect_func(stop_search_auto);
				Axis.stop(2);
				laser_in_working_pos = 1;
				laser_barrier_down = 1;
				if (compensation_enabled) {
					Axis.move(2, (Axis.getPosition(2) - compensation_distance));
				}
				gen_timer(12, automatic_marking);
			}
		}
		else {
			disconnect_func(stop_search_auto);
			write_log("Laser lower position reached, no pump found, going back to ref...");
			Axis.stop(2);
			laser_ref_auto(); laser_ref_auto();
			barrier_up_auto();
			retry_stop_choice();
		}
	}
}

function automatic_marking(ID) {
	if (timers[12] == ID) {
		write_log("Laser in position, starts marking...");

		if (simulation_mode) {
			mark_auto_sim();
		}
		else {
			mark_auto();
		}

		disconnect_func(automatic_marking);
		gen_timer(2, pump_not_present);
	}
}

//////////////////////////////////////////////////////////////////////////////
//If pump is not found, laser moves to ref. position
//////////////////////////////////////////////////////////////////////////////
function pump_not_present(ID) {
	if (timers[2] == ID && pump_present == 0 && auto_mode == "ON") {
		System.stopLaser();
		write_log("pump not present");
		if (IoPort.getPort(0) & I_PIN_11) {
			barrier_up_auto();
		}
		disconnect_func(pump_not_present);
		laser_marking = 0;
		laser_in_working_pos = 0;
		laser_barrier_down = 0;
		nom = 0;
	}
}

////////////////////////////////////////
//Laser doc execution
///////////////////////////////////////
function mark_auto() {
	laser_marking = 1;
	nom = 1;
	laser_doc_update();
	log_arr = [];
	for (i = 0; i < dict_keys.length; i++) {
		log_arr.push(columns_dict[dict_keys[i]]);
	}

	if (!(IoPort.getPort(0) & I_PIN_10)) {

		if (IoPort.getPort(0) & I_PIN_11) {
			write_log("auto marking started");
			h_Doc_new.execute();
			gen_timer(11, check_marking);
		}
		else {
			laser_marking = 0;
			laser_in_working_pos = 0;
			laser_barrier_down = 0;
			nom = 0;
			disconnect_timers();
			write_log("Barrier is not down, laser goes in reference position");
			laser_ref_auto();
			gen_timer(13, reset_auto_func);
		}
	}
	else {
		System.stopLaser();
		laser_marking = 0;
		laser_in_working_pos = 0;
		laser_barrier_down = 0;
		nom = 0;
		write_log("Optical sensor is not seeing pump, laser goes in reference position");
		disconnect_timers();
		laser_ref_auto();
		gen_timer(13, reset_auto_func);
	}

}

function check_marking(ID) {
	if (timers[11] == ID) {

		if (!(IoPort.getPort(0) & I_PIN_10)) {
			if ((IoPort.getPort(0) & I_PIN_11) && !(laser_status == "Marking is active")) {
				barrier_up_after_marking();
				disconnect_func(check_marking);
			}
			else if ((laser_status = "Marking is active") && !(IoPort.getPort(0) & I_PIN_11)) {
				disconnect_func(check_marking);
				System.stopLaser();
				auto_mode = "OFF";
				barrier_up_auto();
				System.stopLaser();
				laser_ref_auto();
				write_log("Barrier not down during laser marking");
			}
		}
		else {
			disconnect_func(check_marking);
			System.stopLaser();
			laser_marking = 0;
			laser_in_working_pos = 0;
			laser_barrier_down = 0;
			nom = 0;
			auto_mode = "OFF";
			write_log("Optical sensor is not seeing pump, laser goes in reference position");
			disconnect_timers();
			laser_ref_auto();
			barrier_up_auto();
			gen_timer(13, reset_auto_func);
		}
	}
}

/////////////////////////////////////////
//Barrier up after marking
/////////////////////////////////////////
function barrier_up_after_marking() {
	barrier_up_auto();
	laser_marking = 0;
	laser_in_working_pos = 0;
	laser_barrier_down = 0;
	marking_ended();
	write_log("Marking successful, raising barrier up and setting signal DONE..");
	gen_timer(5, reset_laser_marking);
}

///////////////////////////////////////////////////////////////////////////////////
//Function resets laser marking to wait for pump func
///////////////////////////////////////////////////////////////////////////////////
function reset_laser_marking(ID) {
	if ((timers[5] == ID) && (pump_present == 0)) {
		disconnect_func(reset_laser_marking);
		write_log("Marking successful, incrementing serial number and setting signal done");
		numWC++;
		xls_log();

		print(numWC % sn_marking_times);
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
		if ((numW > numWC) || numW == 0) {
			nom = 0;
			pumps_marked++;
		}
		else {
			stop_auto();
			write_log("Marking quantity reached! Stoping auto mode");
			marking_quantity_complete();
			pumps_marked = 0;
			le_num_w = "";
		}
	}
}

/////////////////////////////////////////////////////////////////////////////////////////////////////
//IF pump is present, when reset is pressed, automatic mode resets
//////////////////////////////////////////////////////////////////////////////////////////////////////
function reset_auto_func(ID) {

	if ((timers[13] == ID) && (IoPort.getPort(0) & I_PIN_9)) {
		write_log("Reseting auto mode!!!!");
		reset_auto = 1;
		disconnect_func(wait_for_pump);
		disconnect_func(reset_auto_func);
		if (columns_dict["M"] != "/" && columns_dict["M"] != '') {
			serial_choice();
		}
		start_auto_mode();
	}
}

////////////////////////////////////////////
//STOPS auto mode
//////////////////////////////////////////
function stop_auto() {
	if (auto_mode == "ON") {
		if (laser_status == "Marking is active") {
			disconnect_func(stop_auto);
			if (auto_waiting_to_stop == 0) {
				write_log("Stop auto mode has been pressed while marking was active");
				auto_waiting_to_stop = 1;
				gen_timer(14, wait_for_marking_end);
			}
		}
		else {
			auto_mode = "OFF";
			System.stopLaser();
			laser_marking = 0;
			numWC = 0;
			nom = 0;
			laser_ref_auto();
			barrier_up_auto();
			disconnect_timers();
		}
	}
	else {
		error_auto_aoff();
	}
}

//////////////////////////////////////////////////////////////////////////////////////
//If stop auto pressed during automatic mode script waits for laser to finish marking
//////////////////////////////////////////////////////////////////////////////////////
function wait_for_marking_end(ID) {
	if ((timers[14] == ID) && !(laser_status == "Marking is active")) {
		disconnect_func(wait_for_marking_end);
		auto_waiting_to_stop = 0;
		barrier_up_auto();
		laser_ref_auto();
		auto_mode = "OFF";
		System.stopLaser();
		laser_marking = 0;
		numWC = 0;
		nom = 0;
		disconnect_timers();
		gen_timer(5, reset_laser_marking);
		if (columns_dict["M"] != "/" && columns_dict["M"] != '') {
			serial_choice();
		}
	}
}
