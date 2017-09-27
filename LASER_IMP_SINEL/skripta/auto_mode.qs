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
						//retry_stop_choice();
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
function stop_auto() {
	if (auto_mode == "ON") {
		if (laser_status == "Marking is active") {
			disconnect_func(stop_auto);
			if (auto_waiting_to_stop == 0) {
				auto_waiting_to_stop = 1;
				timers[14] = System.setTimer(times[14]);
				start_timer(timers[14], wait_for_marking_end);
			}
		}
		else {
			auto_mode = "OFF";
			System.stopLaser();
			laser_marking = 0;
			numWC = 0;
			nom = 0;
			laser_ref_auto();
			disconnect_timers();
		}
	}
	else {
		error_auto_aoff();
	}
}

////////////////////////////////
//If stop auto pressed 
////////////////////////////////
function wait_for_marking_end(ID) {
	if ((timers[14] == ID) && !(laser_status == "Marking is active")) {
		disconnect_func(wait_for_marking_end);
		auto_waiting_to_stop = 0;
		auto_mode = "OFF";
		System.stopLaser();
		laser_marking = 0;
		numWC = 0;
		nom = 0;
		laser_ref_auto();
		disconnect_timers();
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

	if ((timers[4] == ID) && (auto_mode == "ON") && (pump_present == 1)) {
		if (debug_mode) {
			//print("nom =" + nom);
			//print("laser_in_working_pos: " + laser_in_working_pos);
		}

		for (nom; nom < 1; nom++) {
			if (laser_in_working_pos == 0) {
				barrier_down_auto();
				print("new pump is present. wait for barrier");
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
		print("starting stop search auto");
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
		current_pos = Axis.getPosition(2);

		if ((IoPort.getPort(0) & I_PIN_10)) {
			if (!(IoPort.getPort(0) & I_PIN_8) || !(current_pos <= (home_pos - search_distance))) {
				if (debug_mode) { print("Laser is moving to working pos..."); }
			}
			else {
				Axis.stop(2);
				laser_ref_auto();
				barrier_up_auto();
				disconnect_func(stop_search_auto);
				error_cant_find_pump();
				laser_ref_auto();
				retry_stop_choice();
				//laser_move_timed();
			}
		}
		else {


			if (debug_mode) {
				print("Pump in laser focus");
				//print("+++++++++auto mode ++++:" + auto_mode);
			}
			disconnect_func(stop_search_auto);
			Axis.stop(2);
			laser_in_working_pos = 1;
			laser_barrier_down = 1;
			if (compensation_enabled) {
				Axis.move(2, (Axis.getPosition(2) - compensation_distance));
			}
			timers[12] = System.setTimer(times[12]);
			start_timer(timers[12], automatic_marking);

		}
	}
}


function retry_stop_choice() {

	var rr_dialog = new Dialog("Retry or STOP", Dialog.D_OKCANCEL, false);
	var lbl_question1 = new Label(); lbl_question1.text = "Pump has not been found, retry or stop auto mode?";
	var font6 = "MS Shell Dlg 2,16,-1,5,50,0,0,0,0,0";
	lbl_question1.font = font6;
	rr_dialog.font = font6;
	rr_dialog.add(lbl_question1);
	rr_dialog.okButtonText = "Try again"
	rr_dialog.cancelButtonText = "No, stop Auto mode";

	if (rr_dialog.exec()) {
		print("ok pressed, trying to find pump again");
		laser_move_timed();

	}
	else {
		print("cancel pressed, old serial kept");
		stop_auto();
	}
	delete rr_dialog;


}

function automatic_marking(ID) {
	if (timers[12] == ID) {
		if (debug_mode) { print("Laser in position, starts marking..."); }

		mark_auto();
		disconnect_func(automatic_marking);
		timers[2] = System.setTimer(times[2]);
		start_timer(timers[2], pump_not_present);

	}
}

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
		disconnect_func(pump_not_present);
		laser_marking = 0;
		laser_in_working_pos = 0;
		laser_barrier_down = 0;
		nom = 0;
		//disconnect_func(pump_not_present);

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
	nom = 1;
	laser_doc_update();
	log_arr = [];
	for (i = 0; i < dict_keys.length; i++) {
		log_arr.push(columns_dict[dict_keys[i]]);
	}

	if (simulation_mode) {
		if (chkb_barriera.checked) {
			h_Doc_new.execute();
			//print("simulation auto marking started");
			timers[11] = System.setTimer(times[11]);
			start_timer(timers[11], check_marking);
		}
		else { error_barrier_not_down(); }
	}
	else {
		if (IoPort.getPort(0) & I_PIN_11) {
			print("auto marking started");
			h_Doc_new.execute();
			timers[11] = System.setTimer(times[11]);
			start_timer(timers[11], check_marking);

		}
		else { error_barrier_not_down(); }
	}
}

function check_marking(ID) {
	if (timers[11] == ID) {

		if (simulation_mode) {
			if ((chkb_barriera.checked) && !(laser_status == "Marking is active")) {
				disconnect_func(check_marking);
			}

			else if ((laser_status = "Marking is active") && !(chkb_barriera.checked)) {
				disconnect_func(check_marking);
				//print("disconnecting_func check marking simulation mode");
				auto_mode = "OFF";
				System.stopLaser();
				laser_marking = 0;
				laser_in_working_pos = 0;
				nom = 0;
				error_barrier_not_down();
				laser_reference();
				timers[13] = System.setTimer(times[13]);
				start_timer(timers[13], reset_auto_func);

			}

		}
		else {
			if ((IoPort.getPort(0) & I_PIN_11) && !(laser_status == "Marking is active")) {
				barrier_up_afer_marking();
				disconnect_func(check_marking);
			}
			else if ((laser_status = "Marking is active") && !(IoPort.getPort(0) & I_PIN_11)) {

				System.stopLaser();
				laser_marking = 0;
				laser_in_working_pos = 0;
				nom = 0;
				error_barrier_not_down();
				laser_reference();
				auto_mode = "OFF";
				//print("somethings wrong ........ check marking real");
				disconnect_func(check_marking);
				timers[13] = System.setTimer(times[13]);
				start_timer(timers[13], reset_auto_func);

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
	if (simulation_mode) {
		timers[5] = System.setTimer(times[5]);
		start_timer(timers[5], reset_laser_marking);
	}
	else {
		timers[5] = System.setTimer(times[5]);
		start_timer(timers[5], reset_laser_marking);
	}
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
		//print("writing xls log");
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
function reset_auto_func(ID) {

	if (simulation_mode) {
		if (timers[13] == ID) {

			if (simulation_mode) {
				if (debug_mode) { print("Reseting auto mode! Simulation mode *****************"); }
				reset_auto = 1;
				//disconnect_timers();
				disconnect_func(reset_auto_func);
				serial_choice();
				start_auto_mode();
			}
		}
	}
	else {
		if ((timers[13] == ID) && (IoPort.getPort(0) & I_PIN_9)) {
			if (debug_mode) { print("Reseting auto mode!!!!"); }
			reset_auto = 1;
			//disconnect_timers();
			disconnect_func(reset_auto_func);
			serial_choice();
			start_auto_mode();
		}
	}
}


function serial_choice() {
	/*if (simulation_mode) {
		var ans = MessageBox.information("Create new serial number?", MessageBox.Yes, MessageBox.No);
		if (ans == MessageBox.Yes) {
			print("cancel pressed, old serial kept");
		}
		else {
			//print("mark new");
			print("ok pressed, creating new serial number");
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

		}
	}
	else {*/

	year = new Date();
	year = year.getFullYear().toString().slice(2);
	var ra_dialog = new Dialog("Serial number choice", Dialog.D_OKCANCEL, false);
	var lbl_question = new Label(); lbl_question.text = "Create new serial number?";
	var font6 = "MS Shell Dlg 2,15,-1,5,50,0,0,0,0,0";
	lbl_question.font = font6;
	ra_dialog.font = font6;
	ra_dialog.add(lbl_question);
	ra_dialog.okButtonText = "Yes"
	ra_dialog.cancelButtonText = "No, repeat this S.N. : " + year + "-" + leftPad((curr_sn), 6);
	//disconnect_timers();

	if (ra_dialog.exec()) {
		print("ok pressed, creating new serial number");
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
	}
	else {
		print("cancel pressed, old serial kept");
	}

	delete ra_dialog;

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
			timers[5] = System.setTimer(times[5]);
			start_timer(timers[5], reset_auto_func);
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
