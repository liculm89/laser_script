////////////////////////////////////////////
//Read inputs and sets flags
////////////////////////////////////////////
function set_flags() {
    if (simulation_mode == 1) {
        if (chkb_linija.checked) { sen_linija = 1; } else { sen_linija = 0; }
        if (chkb_optika.checked) { sen_optika = 0; } else { sen_optika = 1; }
        if (chkb_barriera.checked) { sen_bar_dolje = 1; } else { sen_bar_dolje = 0; }
        if (chkb_reset.checked) { reset_tipka = 1; reset_button_func(); } else { reset_tipka = 0; }
        if (chkb_lp.checked) { sen_bar_dolje = 1; } else { sen_bar_dolje = 0; }
    }
    else {
        if (IoPort.getPort(0) & I_PIN_7) { sen_linija = 1; } else { sen_linija = 0; }
        if (IoPort.getPort(0) & I_PIN_10) { sen_optika = 1; } else { sen_optika = 0; }
        if (IoPort.getPort(0) & I_PIN_11) { sen_bar_dolje = 1; } else { sen_bar_dolje = 0; }
        if (IoPort.getPort(0) & I_PIN_19) {
            reset_tipka = 1;
            reset_button_func();
        }
        else {
            reset_tipka = 0;
        }

        if (IoPort.getPort(0) & I_PIN_8) { sen_laser_dolje = 1; } else { sen_laser_dolje = 0; }
        if (IoPort.getPort(0) & I_PIN_9) { sen_laser_gore = 1; } else { sen_laser_gore = 0; }
        if (IoPort.getPort(0) & I_PIN_21) { sen_bar_gore = 1; } else { sen_bar_gore = 0; }
        if (IoPort.getPort(0) & I_PIN_20) {
            if (simulation_mode == 1) { reg_fault = 1; }
            else { reg_fault = 0; }

        }
        else {
            if (simulation_mode == 1) { reg_fault = 0; }
            else { reg_fault = 1; }
        }
        if (IoPort.getPort(0) & I_PIN_12) {
            total_stop = 1;
            total_stop_func();
            reset_sequence();
            if (brake_status == 0) {
                enable_break()
            };
        }
        else {
            if (brake_status == 1) {
                disable_break()
            };
            total_stop = 0;
        }
    }
}
///////////////////////////////////////////////////////////////////
//Counts pumps and sets pump_present flag
//////////////////////////////////////////////////////////////////
function pump_counter(ID) {
    if (timers[3] == ID) {
        if (simulation_mode) {
            if (chkb_linija.checked) { senz_state = 1; } else { senz_state = 0; }
        }
        else {
            if (IoPort.getPort(0) & I_PIN_7) { senz_state = 1; } else { senz_state = 0; }
        }
        if (senz_state != last_senz_state) {

            if (senz_state == 1) {
                brojac++;
                write_log("pump counter:" + brojac);
                pump_present = 1;
            }
            else {
                write_log("pump left");
                pump_present = 0;
            }
        }
        last_senz_state = senz_state;
    }
}
//////////////////////////////////////
//Init function
/////////////////////////////////////
function init_func() {
    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    /*Connects function set_flags() to trigger on input signal change
    Initial flags setup
    Generates parts_list[] from excel database
    Reads from xls database, gets templates and logos
    Pump counter and laser movement functions connection
    */
    //////////////////////////////////////////////////////////////////////////////////////////////////////
    IoPort.checkPort(0);
    IoPort.sigInputChange.connect(set_flags);
    reset_sequence();
    set_flags();
    parts_list();
    gen_lists_from_xls();
    get_xy_loc();
    System["sigTimer(int)"].connect(pump_counter);
    System["sigTimer(int)"].connect(laser_movement);

    if ((zdelekArr.length != 0) && (reg_fault == 0)) {
        return 0;
    }
    if (zdelekArr.length == 0) {
        return 1;
    }
    if (reg_fault == 1) {
        return 2;
    }
}
function get_xy_loc() {
    var coords_xy = new File(script_loc + "coords");
    coords_xy.open(File.ReadOnly);
    var i = 0;
    while (!coords_xy.eof) {
        marking_loc[i] = coords_xy.readLine();
        i++;
    }
    coords_xy.close();
}

/////////////////////////////////
//MAIN func
////////////////////////////////
function main() {
    System.sigQueryStart.connect(onQueryStart);
    System.sigLaserStop.connect(onLaserStop);
    System["sigLaserEvent(int)"].connect(get_laser_events);
    System["sigLaserError(int)"].connect(onLaserError);
    System.sigClose.connect(onClose);

    ///////////////////////////////////////////////////////////////////////////////////////////
    //Starts initialization function, if success GUI is generated
    ////////////////////////////////////////////////////////////////////////////////////////////

    init_passed = init_func();
    if (init_passed == 0) {
	  print(System.currentThreadId());
        disable_break();
        IoPort.resetPort(0, O_PIN_2);
        write_log("Init passed");
        if (Axis.isReversed(2)) { Axis.reset(2); } else { print("Z axis not reversed"); }

        templates_dict = to_dict(template_list_s, "1", "UNI-G", ",");
        logotips_dict = to_dict(logotips_s, "ADL", "calpeda1", ",");
        columns_dict = to_dict(columns, "A", "AJ", " ");
        znaki_dict = to_dict(znaki_a, "CCC-1", "ucraino1", ",");

        if (sen_linija == 1) {
            timers[10] = System.setTimer(times[10]);
            start_timer(timers[10], send_signal_done);
        }

        log_creator();
	  get_xls_log_name();
	  write_log("Tabela_log : " + xls_log_name);
        //Start GUI generation
        gen_dialog(part_list);
    }
    if (init_passed == 1) {
        write_log("Initialization failed, check if files are present in specified directories...");
        stop_axis();
        error_init_fail();
    }
    if (init_passed == 2) {
        error_regulator_fault();
    }
}
