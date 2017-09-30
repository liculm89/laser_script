/////////////////////////////////////////////////
//AUTO MODE START function
/////////////////////////////////////////////////

function start_auto_mode() {
	if (auto_mode_check()) {
		System.collectGarbage();
		auto_mode = "ON";
		get_quantity();
		barrier_up_auto();
		if (reset_auto == 1) {
			if (sen_linija == 1) {
				marking_ended();
				reset_auto = 0;
			}
			else {
				reset_auto = 0;
			}
		}
		numWC = 0;
		write_log("Auto mode started");
		auto_waiting_to_stop = 0;
		laser_in_working_pos = 0;
		laser_ref_auto();
		if (simulation_mode) {
			gen_timer(4, wait_for_pump_sim);
		}
		else {
			gen_timer(4, wait_for_pump);
		}
	}
}

//////////////////////////////////////////////////////////////////////////////
//Laser auto mode is on, waits for external signal
/////////////////////////////////////////////////////////////////////////////
function wait_for_pump(ID) {
	if ((timers[4] == ID) && (auto_mode == "ON") && (pump_present == 1)) {
		disconnect_func(wait_for_pump);
		barrier_down_auto();
		write_log("Signal from line recieved, barrier going down ...");
		gen_timer(6, wait_for_barrier);
	}
}

////////////////////////////////////
//Laser waits for barrier
/////////////////////////////////////
function wait_for_barrier(ID) {
	//Laser waits for barrier to be lowered 
	if ((timers[6] == ID) && (IoPort.getPort(0) & I_PIN_11)) {
		write_log("Barrier is lowered, searching for pump...");
		disconnect_func(wait_for_barrier);
		laser_move_timed();
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
			if (sen_bar_gore) { barrier_down_auto(); }
			gen_timer(1, stop_search_auto_sim);
		}
		else {
			if (IoPort.getPort(0) & I_PIN_21) { barrier_down_auto(); }
			gen_timer(1, stop_search_auto);
		}
	}
	else {
		write_log("Laser already in position, initiating marking process...");
		if (simulation_mode) {
			mark_auto_sim();
		}
		else {
			mark_auto();
		}

	}
}

////////////////////////////////////////////////////////////////////
//Laser moves until working pos. is reached
////////////////////////////////////////////////////////////////////
function stop_search_auto(ID) {
	if (timers[1] == ID && auto_mode == "ON") {
		current_pos = Axis.getPosition(2);
		if (!(IoPort.getPort(0) & I_PIN_8)) { //***** Laser lowest position sensor
			if ((IoPort.getPort(0) & I_PIN_10)) {  //***** Optika
				if (!(current_pos <= (home_pos - search_distance))) {
					if (debug_mode) { print("Laser is moving to working pos..."); }
				}
				else {
					searching_error(1); //Search distance reached
				}
			}
			else {
				write_log("Pump in laser focus");
				disconnect_func(stop_search_auto);
				Axis.stop(2);
				laser_in_working_pos = 1;
				if (compensation_enabled) {
					Axis.move(2, (Axis.getPosition(2) - compensation_distance));
				}
				mark_auto();
			}
		}
		else {
			searching_error(2); //LASER LOWEST POSITION
		}
	}
}

/*
MARKING DELAY FUNCTION
*/
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
	}
}

////////////////////////////////////////
//Laser marking execution
///////////////////////////////////////
function mark_auto() {
	laser_marking = 1;
	laser_doc_update();
	log_arr = [];
	for (i = 0; i < dict_keys.length; i++) {
		log_arr.push(columns_dict[dict_keys[i]]);
	}
	if (!(IoPort.getPort(0) & I_PIN_10)) {
		if (IoPort.getPort(0) & I_PIN_11) {
			write_log("Auto marking started");
			h_Doc_new.execute();
			gen_timer(11, check_marking);
		}
		else {
			marking_failed(1);
		}
	}
	else {
		marking_failed(2);
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
				marking_failed(3);
			}
		}
		else {
			disconnect_func(check_marking);
			marking_failed(4);
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
			if (simulation_mode) {
				write_log("starting wait_for_pump_sim from reset_laser marking");
				gen_timer(4, wait_for_pump_sim);
			}
			else {
				if (auto_waiting_to_stop == 1) {
					gen_timer(14, wait_for_marking_end);
				}
				else {
					gen_timer(4, wait_for_pump);
				}
			}
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
		if (auto_mode == "ON"); {
			stop_auto();
		}
		disconnect_func(reset_auto_func);
		if (columns_dict["M"] != "/" && columns_dict["M"] != '') {
			serial_choice();
		}
	}
}

////////////////////////////////////////////
//STOPS auto mode
//////////////////////////////////////////
function stop_auto() {
	if (auto_mode == "ON") {
		if (laser_status == "Marking is active") {
			if (auto_waiting_to_stop == 0) {
				write_log("Stop auto mode has been pressed while marking was active");
				auto_waiting_to_stop = 1;
				gen_timer(14, wait_for_marking_end);
			}
		}
		else {
			if(auto_mode == "ON"){auto_mode = "OFF";}
			System.stopLaser();
			laser_marking = 0;
			laser_in_working_pos = 0;
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
		System.stopLaser();
		laser_marking = 0;
		disconnect_timers();
		laser_ref_auto();
		barrier_up_auto();
		serial_choice_stop();
	}
}
