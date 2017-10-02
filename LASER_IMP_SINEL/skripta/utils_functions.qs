///////////////////////////////////////////////////
//TIME AND DATE FORMATING
///////////////////////////////////////////////////
Date.prototype.mmyy = function () {
    var mm = this.getMonth() + 1;
    var yy = this.getFullYear();
    yy = yy.toString();
    yy = yy.slice(2);

    return [(mm > 9 ? '' : '0') + mm,
        "/",
        yy,
    ].join('');
};

Date.prototype.ddmmyy = function () {
    var mm = this.getMonth() + 1;
    var yy = this.getFullYear();
    yy = yy.toString();

    var dd = this.getDate();
    return [(dd > 9 ? '' : '0') + dd,
        "_",
    (mm > 9 ? '' : '0') + mm,
        "_",
        yy,
    ].join('');
};

Date.prototype.ddmmyytime = function () {
    var mm = this.getMonth() + 1;
    var yy = this.getFullYear();
    yy = yy.toString();

    var dd = this.getDate();
    var uhr = this.getHours();
    var min = this.getMinutes();
    var sec = this.getSeconds();
    var time = this.getTime();
    return [(dd > 9 ? '' : '0') + dd,
        "/",
    (mm > 9 ? '' : '0') + mm,
        "/",
        yy,
        "-",
    (uhr > 9 ? '' : '0') + uhr,
        ":",
    (min > 9 ? '' : '0') + min,
        ":",
    (sec > 9 ? '' : '0') + sec,
    ].join('');
};

function gen_timestamp() {
    var date = new Date();
    var ts = date.ddmmyytime().toString();
    return ts;
}

/////////////////////////////////
//Setting up log file date
/////////////////////////////////
var date_year = new Date();
var date_year = date_year.getFullYear().toString().slice(2);
var date_init = new Date();
var log_date = date_init.ddmmyy().toString();


//////////////////////
//String to dict
///////////////////////
function to_dict(from_str, c1, c2, split) {
    var arr = from_str;
    arr = arr.split(split);
    var arr_s = arr.slice(arr.indexOf(c1), arr.indexOf(c2) + 1);
    var dict = {};
    arr_s.forEach(function (item) {
        dict[item] = "init_value";
    })
    return dict;
}

//////////////////////////
//String to array
/////////////////////////
function to_arr(from_str, c1, c2) {
    var arr;
    arr = from_str;
    arr = arr.split(" ");
    var arr_s;
    arr_s = arr.slice(arr.indexOf(c1), arr.indexOf(c2) + 1);
    return arr_s;
}

//////////////////////////////////////////////////
//Removes duplicates from array
//////////////////////////////////////////////////
function remove_duplicates(arr) {
    var m = {}, newarr = []
    for (var i = 0; i < arr.length; i++) {
        var v = arr[i];
        if (!m[v]) {
            newarr.push(v);
            m[v] = true;
        }
    }
    return newarr;
}

////////////////////////////////
//S.N. Format check
////////////////////////////////
function check_sn_format_imp(sn) {
    if ((columns_dict["M"] == "ebara") || (ebara_reg.test(columns_dict["M"]))) {
        if (sn.length == 11) {
            return true;
        }
        else {
            return false;
        }
    }
    else {
        if ((imp_reg.test(sn)) && (sn.length == 9)) {
            return true;
        }
        else {
            return false;
        }
    }
}

////////////////////////////////////
//Ebara prefix creation
///////////////////////////////////
function get_ebara_prefix() {
    var S; var P; var M; var LP; var AF;
    var date = new Date();
    var year = date.getFullYear().toString();
    var month = (date.getMonth() + 1);
    S = "S";
    AF = "AF";
    switch (year) {
        case "2017":
            P = "W";
            break;
        case "2018":
            P = "X";
            break;
        case "2019":
            P = "Y";
            break;
    }
    switch (month) {
        default:
            M = month.toString();
            break;
        case 10:
            M = "X";
            break;
        case 11:
            M = "Y";
            break;
        case 12:
            M = "Z";
            break;
    }
    var ebara_prefix = S + P + M + AF;
    return (ebara_prefix);
}

//////////////////////////////////////////////////////////////////////////////////////
//Add zeros to nubmer if number to reach targetLength
/////////////////////////////////////////////////////////////////////////////////////
function leftPad(number, targetLength) {
    var output = number.toString();
    while (output.length < targetLength) {
        output = '0' + output;
    }
    return output;
}

///////////////////////////////////
//get serial number int
//////////////////////////////////
function get_serial_int(sn_str) {
    var serial_str = sn_str;
    var serial_int;
    if ((columns_dict["M"] == "ebara") || (ebara_reg.test(columns_dict["M"]))) {
        serial_str = serial_str.slice(5);
        serial_int = parseInt(serial_str, 10);
    }
    else {
        serial_str = serial_str.slice(3);
        serial_int = parseInt(serial_str, 10);
    }
    return serial_int;
}

function chk_and_increment_sn() {
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

function delayed_ref() {
}

function searching_error(fail_code) {
    if (fail_code == 1) { write_log("Search distance passed but no pump found. Going back to ref..."); }
    if (fail_code == 2) {
        laser_ref_auto();
        write_log("Laser lower position reached, no pump found, going back to ref...");
    }
    disconnect_timers();
    if (simulation_mode) {
        disconnect_func(stop_search_auto_sim);
    }
    else {
        disconnect_func(stop_search_auto);
    }
    Axis.stop(2);
    laser_ref_auto(); barrier_up_auto();
    retry_stop_choice();

}

function marking_failed(fail_code) {
    if (fail_code == 1) { write_log("Barrier is not down, laser goes in reference position"); }
    if (fail_code == 2) { write_log("Optical sensor is not seeing pump, laser goes in reference position"); }
    if (fail_code == 3) { write_log("Barrier not down during laser marking"); }
    if (fail_code == 4) {
        write_log("Optical sensor error during marking, laser goes in reference position");
    }
    System.stopLaser();
    laser_marking = 0; laser_in_working_pos = 0;
    disconnect_timers();
    laser_ref_auto();
    if (simulation_mode) {
        gen_timer(13, reset_auto_func_sim);
    }
    else {
        gen_timer(13, reset_auto_func);
    }
}


function serial_choice_stop() {

    var ra_dialog = gen_sc_dialog();
    if (ra_dialog.exec()) {
        write_log("Yes pressed, repeating marking with S.N." + year + "-" + leftPad((curr_sn), 6));
        reset_auto = 0;
        if (auto_mode == "ON") {
            stop_auto();}
    }
    else {
        write_log("No pressed, continuing onto next pump...");
		numWC++;
		xls_log();
		//write_log("Marking successful, raising barrier up and setting signal DONE..");
		chk_and_increment_sn();
        reset_auto = 1;
        if (auto_mode == "ON") {
            stop_auto();}
    }
	/*if(reset_pressed)
    {reset_pressed = 0;}*/
     try {
        delete ra_dialog;
        System.collectGarbage();
    }
    catch (e) {
        write_log("Exception: " + e);
    }

}

function serial_choice() {
    var ra_dialog = gen_sc_dialog();
    
    if (ra_dialog.exec()) {
        write_log("Yes pressed, repeating marking with S.N." + year + "-" + leftPad((curr_sn), 6));
        barrier_down_auto();
        if (simulation_mode) {
            gen_timer(6, wait_for_barrier_sim);
        }
        else {
            gen_timer(6, wait_for_barrier);
        }
    }
    else {
        write_log("No pressed, continuing onto next pump...");
        barrier_up_after_marking();
    }

    if(reset_pressed)
    {reset_pressed = 0;}
    try {
        delete ra_dialog;
        System.collectGarbage();
    }
    catch (e) {
        write_log("Exception: " + e);
    }

}

function without_serial_choice() {
    var wos_dialog = gen_wos_dialog();
    if (wos_dialog.exec()) {
        write_log("Yes pressed, laser is repeating marking ...");
        barrier_down_auto();
        if (simulation_mode) {
            gen_timer(6, wait_for_barrier_sim);
        }
        else {
            gen_timer(6, wait_for_barrier);
        }
    }
    else {
        write_log("No pressed, continuing onto next pump...");
        barrier_up_after_marking();
    }

    if(reset_pressed)
    {reset_pressed = 0;}
    try {
        delete wos_dialog;
        System.collectGarbage();
    }
    catch (e) {
        write_log("Exception: " + e);
    }
}

function retry_stop_choice() {
    var rr_dialog = gen_rr_dialog();

    if (rr_dialog.exec()) {
        write_log("ok pressed, trying to find pump again");
        if (simulation_mode) {
            barrier_down_auto();
            gen_timer(6, wait_for_barrier_sim);
        }
        else {
            barrier_down_auto();
            gen_timer(6, wait_for_barrier);
        }
    }
    else {
        write_log("cancel pressed, stoping auto_mode");
        if (auto_mode == "ON") {
            stop_auto();
        }

    }
    delete rr_dialog;
    System.collectGarbage();
}

/////////////////////////////////////////////////////////////
//Function sets laser into reference pos
////////////////////////////////////////////////////////////
function laser_ref_auto() {
    if (total_stop == 0) {
        write_log("Automatic laser referencing initiated");
        Axis.reset(2);
    }
}

//////////////////////////////////////////////////////////////////////////////////////
//Automatic marking starts, sets timer for barrier rising
//////////////////////////////////////////////////////////////////////////////////////
function readFile_auto() {
    mark_auto();
}

////////////////////////////////////
//Automatic barrirer up
///////////////////////////////////
function barrier_up_auto() {
    IoPort.resetPort(0, O_PIN_23);
    bar_dolje = 0;
    write_log("Automatic barrier rising");
    IoPort.setPort(0, O_PIN_5);
    bar_gore = 1;
}

////////////////////////////////////////
//Automatic barrier down
////////////////////////////////////////
function barrier_down_auto() {
    IoPort.resetPort(0, O_PIN_5);
    bar_gore = 0;
    write_log("Automatic barrier lowering");
    IoPort.setPort(0, O_PIN_23);
    bar_dolje = 1;
}

////////////////////////////////////////////////////////////////////////////
//Function is triggered when total stop is pressed
////////////////////////////////////////////////////////////////////////////
function total_stop_func() {
    if (auto_mode == "ON") {
        write_log("Total stop pressed during Auto mode");
        disconnect_func(wait_for_pump);
        System.stopLaser();
        laser_marking = 0;
        laser_in_working_pos = 0;
        nom = 0;
        auto_mode = "OFF";
    }
    if (auto_mode == "OFF") {
        write_log("Total stop pressed while not in Auto mode");
        System.stopLaser();
    }
}

///////////////////////////////////////////////////////////////////////////
//Function is triggered when reset btn is pressed
///////////////////////////////////////////////////////////////////////////
function reset_button_func() {
    if (total_stop == 0) {
 
        if (!reset_pressed) {
            if (auto_mode == "ON") {
		     reset_pressed = 1;
                write_log("Reset button pressed during Auto mode");
                System.stopLaser();
                laser_marking = 0;
                laser_in_working_pos = 0;
                laser_ref_auto();
                barrier_up_auto();
                if (simulation_mode) {
                    gen_timer(13, reset_auto_func_sim);
                }
                else {
                    gen_timer(13, reset_auto_func);
                }
            }
            if (auto_mode == "OFF") {
                write_log("Reset button pressed while not in Auto mode");
                System.stopLaser();
                laser_ref_auto();
				
            }
        }
        
    }
    else {
        error_total_stop();
    }
}

function auto_mode_check() {
    if (total_stop == 0) {
        if (reg_fault == 0) {
            if (auto_mode == "OFF") {
                if (laser_status == "Ready for marking") {
                    if (confirm) {
                        return true;
                    }
                    else {
                        process_error(14); return false;
                    }
                }
                else {
                    error_key_sequence(); return false;
                }
            }
            else {
                error_manual_mode(); return false;
            }
        }
        else {
            error_regulator_fault(); return false;
        }
    }
    else {
        error_total_stop(); return false;
    }
}

function log_creator() {
    var date_init = new Date();
    var timestamp = gen_timestamp();
    var log_date = date_init.ddmmyy().toString();
    var plog_file = new File(plog_loc + log_date + ".log");
    plog_file.open(File.ReadWrite);
    plog_file.close();

    if (plog_file.exists) {
        plog_file.open(File.Append);

        var line1 = timestamp + " *** Process logging started *** \r\n";
        var line2 = "=================================================== \r\n";
        plog_file.writeLine(line2);
        plog_file.writeLine(line1);
        plog_file.writeLine(line2);
    }
    plog_file.close();
}

function write_log(logstr) {

    plog_file = new File(plog_loc + log_date + ".log");
    var timestamp = gen_timestamp();
    if (plog_file.exists) {
        plog_file.open(File.Append);
        var line = timestamp + " --- " + logstr;
        print(line);
        plog_file.writeLine(line);
        plog_file.writeLine("\r\n");
        plog_file.close();
    }
    else {
        log_creator();
    }

}

