/////////////////////////////////////////////////
//AUTO MODE START function
/////////////////////////////////////////////////
function start_auto_mode() {
	if (total_stop == 0) {
		if (reg_fault == 0) {
			if (auto_mode == "OFF") {
				if (laser_status == "Ready for marking") {
					if (confirm) {
						auto_mode = "ON";
						get_quantity();
						if ((IoPort.getPort(0) & I_PIN_11)) {
							barrier_up_auto();
						}
						if (reset_auto == 1) {
							if (sen_linija == 1) {
								timers[10] = System.setTimer(times[10]);
								start_timer(timers[10], send_signal_done);
								reset_auto = 0;
							}
						}
						numWC = 0;
						if (debug_mode) { print("Auto mode started"); }
						laser_in_working_pos = 0;
						laser_barrier_down = 0;
						laser_ref_auto();
						timers[4] = System.setTimer(times[4]);
						start_timer(timers[4], wait_for_pump);
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


//wait_signal()

////////////////////////////////////////////
//STOPS auto mode
//////////////////////////////////////////
function stop_auto(ID) {
	if (auto_mode == "ON") {
		auto_mode = "OFF";
		System.stopLaser();
		laser_marking = 0;
		numWC = 0;
		nom = 0;
		// disconnect_func(wait_for_pump); 
		disconnect_timers();
		//disconnect_func(wait_for_barrier);
	}
	else {
		error_auto_aoff();
	}
}

/////////////////////////////////////////////////////////////
//Function sets laser into reference pos
////////////////////////////////////////////////////////////
function laser_ref_auto() {
	if (total_stop == 0) {
		Axis.reset(2);
	}
}

//////////////////////////////////////////////////////////////////////////////
//Laser auto mode is on, waits for external signal
/////////////////////////////////////////////////////////////////////////////
function wait_for_pump(ID) {
	//print(pump_present);
	if ((timers[4] == ID) && (auto_mode == "ON") && (pump_present == 1)) {
		if (debug_mode) {
			print("nom =" + nom);
			print("laser_in_working_pos: " + laser_in_working_pos);
		}

		for (nom; nom < 1; nom++) {
			if (laser_in_working_pos == 0) {
				barrier_down_auto();
				timers[6] = System.setTimer(times[6]);
				start_timer(timers[6], wait_for_barrier);
			}
			else {
				timers[6] = System.setTimer(times[6]);
				start_timer(timers[6], wait_for_barrier);
			}
		}
	}
}



////////////////////////////////////
//Timer waits for barrier
/////////////////////////////////////
function wait_for_barrier(ID) {

	if (simulation_mode) {
		if ((timers[6] == ID) && (chkb_barriera.checked)) {
			if (debug_mode) { print("laser is seaching for pump"); }
			if (laser_barrier_down == 1) {
				print("laser already in position");
				mark_auto();
				timers[2] = System.setTimer(times[2]);
				start_timer(timers[2], pump_not_present);
			}
			else {
				laser_move_timed();
			}
			disconnect_func(wait_for_barrier);
		}
	}
	else {

		if ((timers[6] == ID) && (IoPort.getPort(0) & I_PIN_11)) {
			if (debug_mode) { print("laser is seaching for pump"); }
			if (laser_barrier_down == 1) {
				print("laser already in position");
				mark_auto();
				timers[2] = System.setTimer(times[2]);
				start_timer(timers[2], pump_not_present);
			}
			else {
				laser_move_timed();
			}

			disconnect_func(wait_for_barrier);

		}
	}
}


//////////////////////////////////////////////////////////////////
//Laser moves and starts timers
//////////////////////////////////////////////////////////////////
function laser_move_timed() {
	if (laser_in_working_pos == 0) {
		Axis.move(2, (Axis.getPosition(2) - search_distance));
		timers[1] = System.setTimer(times[1]);
		start_timer(timers[1], stop_search_auto);
	}
	if (laser_in_working_pos == 1) {
		if (debug_mode) { print("Laser already in pos"); }
		mark_auto();
		//readFile_auto();
		timers[2] = System.setTimer(times[2]);
		start_timer(timers[2], pump_not_present);
	}
}

////////////////////////////////////////////////////////////////////
//Laser moves until working pos. is reached
////////////////////////////////////////////////////////////////////
function stop_search_auto(ID) {
	if (timers[1] == ID && auto_mode == "ON") {
		if (IoPort.getPort(0) & I_PIN_10) {
			current_pos = Axis.getPosition(2);
			if (!(IoPort.getPort(0) & I_PIN_8)) {
				if (debug_mode) { print("Laser is moving to working pos..."); }
			}
			else {
				Axis.stop(2);
				laser_ref_auto();
				barrier_up_auto();
				error_cant_find_pump();
				disconnect_func(stop_search_auto);
				
			}
		}
		else {
			if (debug_mode) { print("Pump in laser focus"); }
			Axis.stop(2);
			laser_in_working_pos = 1;
			laser_barrier_down = 1;

			Axis.move(2, (Axis.getPosition(2) - compensation_distance));
			timers[12] = System.setTimer(times[12]);
			start_timer(timers[12], automatic_marking);
			//mark_auto();
			//timers[2] = System.setTimer(times[2]);
			//start_timer(timers[2], pump_not_present);
			disconnect_func(stop_search_auto);
		}
	}
}


function automatic_marking(ID) {
	if (timers[12] == ID) {
		if (debug_mode) { print("Laser already in pos"); }
		
		mark_auto();
		timers[2] = System.setTimer(times[2]);
		start_timer(timers[2], pump_not_present);
		disconnect_func(automatic_marking);
	}
}

/*function height_compensation(ID)
{

	Axis.move(2, (Axis.getPosition(2) - compensation_distance));
	disconnect_func(height_compensation);
}*/

//////////////////////////////////////////////////////////////////////////////
//If pump is not found, laser moves to ref. position
//////////////////////////////////////////////////////////////////////////////
function pump_not_present(ID) {
	if (timers[2] == ID && pump_present == 0 && auto_mode == "ON") {
		System.stopLaser();
		print("pump not present");
		if (IoPort.getPort(0) & I_PIN_11) {
			barrier_up_auto();
		}
		laser_marking = 0;
		laser_in_working_pos = 0;
		laser_barrier_down = 0;
		//laser_barrier_down = 0;
		nom = 0;
		disconnect_func(pump_not_present);
	}
}

//////////////////////////////////////////////////////////////////////////////////////
//Automatic marking starts, sets timer for barrier rising
//////////////////////////////////////////////////////////////////////////////////////
function readFile_auto() {
	mark_auto();
}

////////////////////////////////////////
//Laser doc execution
///////////////////////////////////////
function mark_auto() {
	if (debug_mode) { print("Read file started"); }
	laser_marking = 1;
	nm = 1;
	laser_doc_update();
	log_arr = [];
	for (i = 0; i < dict_keys.length; i++) {
		log_arr.push(columns_dict[dict_keys[i]]);
	}

	if (simulation_mode) {
		if (chkb_barriera.checked) {
			// h_Doc_new.sigEndMark.connect( barrier_up_afer_marking ); 
			h_Doc_new.execute();
			timers[11] = System.setTimer(times[11]);
			start_timer(timers[11], check_marking);
		}
		else { error_barrier_not_down(); }
	}
	else {
		if (IoPort.getPort(0) & I_PIN_11) {
			h_Doc_new.execute();
			timers[11] = System.setTimer(times[11]);
			start_timer(timers[11], check_marking);
			//System.sigLaserEnd.connect(barrier_up_after_marking);
		}
		else { error_barrier_not_down(); }
	}
}

function check_marking(ID) {
	if (timers[11] == ID) {

		//print(laser_status);
		if (simulation_mode == 1) {
			// print((laser_status == "Marking is active"));
			if ((chkb_barriera.checked) && !(laser_status == "Marking is active")) {
				//barrier_up_afer_marking();
				disconnect_func(check_marking);
			}
			else if ((laser_status = "Marking is active") && !(chkb_barriera.checked)) {
				auto_mode = "OFF";
				System.stopLaser();
				laser_marking = 0;
				//numWC = 0;
				disconnect_timers();
				nom = 0;
			}
		}
		else {
			//    print("Check laser state : "+ check_laser_state(System.getDeviceStatus()));
			//print( check_laser_state(System.getDeviceStatus());
			//if ((IoPort.getPort(0) & I_PIN_11) && (!(laser_status == "Marking is active")) || !(laser_status == "Moving...")  )  {
			if ((IoPort.getPort(0) & I_PIN_11) && !(laser_status == "Marking is active")) {

				barrier_up_afer_marking();
				disconnect_func(check_marking);
			}
			else if ((laser_status = "Marking is active") && !(IoPort.getPort(0) & I_PIN_11)) {
				auto_mode = "OFF";
				System.stopLaser();
				laser_marking = 0;
				numWC = 0;
				nom = 0;
				disconnect_timers();
			}
		}
	}
}

/////////////////////////////////////////
//Barrier up after marking
/////////////////////////////////////////
function barrier_up_afer_marking() {
	barrier_up_auto();
	laser_marking = 0;
	laser_in_working_pos = 0;
	marking_ended();
	if(simulation_mode){}
	timers[5] = System.setTimer(times[5]);
	start_timer(timers[5], reset_laser_marking);
}

////////////////////////////////////
//Automatic barrirer up
///////////////////////////////////
function barrier_up_auto() {
	IoPort.resetPort(0, O_PIN_23);
	bar_dolje = 0;
	IoPort.setPort(0, O_PIN_5);
	bar_gore = 1;
}

////////////////////////////////////////
//Automatic barrier down
////////////////////////////////////////
function barrier_down_auto() {
	IoPort.resetPort(0, O_PIN_5);
	bar_gore = 0;
	IoPort.setPort(0, O_PIN_23);
	bar_dolje = 1;
}

///////////////////////////////////////////////////////////////////////////////////
//Function resets laser marking to wait for pump func
///////////////////////////////////////////////////////////////////////////////////
function reset_laser_marking(ID) {
	if ((timers[5] == ID) && (pump_present == 0)) {
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
			disconnect_func(reset_laser_marking);
		}
		else {
			stop_auto();
			disconnect_func(reset_laser_marking);
			marking_quantity_complete();
			pumps_marked = 0;
			le_num_w = "";
		}
	}
}

////////////////////////////////////////////////////////////////////////////
//Function is triggered when total stop is pressed
////////////////////////////////////////////////////////////////////////////
function total_stop_func() {
	if (auto_mode == "ON") {
		System.stopLaser();
		disconnect_timers();
		laser_marking = 0;
		laser_in_working_pos = 0;
		laser_barrier_down = 0;
		nom = 0;
		auto_mode = "OFF";
	}
	if (auto_mode == "OFF") {

		System.stopLaser();
		disconnect_timers();
	}
}
/////////////////////////////////////////////////////////////////////////////////////////////////////
//IF pump is present, when reset is pressed, automatic mode resets
//////////////////////////////////////////////////////////////////////////////////////////////////////
function reset_auto(ID) {
	if ((timers[5] == ID) && (IoPort.getPort(0) & I_PIN_9)) {
		if (debug_mode) { print("Reseting auto mode!"); }
		reset_auto = 1;
		start_auto_mode();
		disconnect_func(reset_auto);
	}
}

///////////////////////////////////////////////////////////////////////////
//Function is triggered when reset btn is pressed
///////////////////////////////////////////////////////////////////////////
function reset_button_func() {
	if (total_stop == 0) {
		if (auto_mode == "ON") {
			System.stopLaser();
			disconnect_timers();
			laser_marking = 0;
			laser_in_working_pos = 0;
			laser_barrier_down = 0;
			nom = 0;
			auto_mode = "OFF";
			//reset_auto();
			timers[5] = System.setTimer(times[5]);
			start_timer(timers[5], reset_auto);
		}
		if (auto_mode == "OFF") {
			System.stopLaser();
			disconnect_timers();
			laser_reference();
		}
	}
	else {
		error_total_stop();
	}
}
