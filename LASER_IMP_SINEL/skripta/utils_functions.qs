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


function delayed_ref() {
}

/*""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""*
FUNCTIONS NEEDED FOR SIMULATION MODE
*"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""*/

function wait_for_pump_sim(ID)
{
    if ((timers[4] == ID) && (auto_mode == "ON") && (pump_present == 1))
    {
        disconnect_func(wait_for_pump_sim);
        barrier_down_auto();
        write_log(" Simulation - new pump has arrived, barrier going down ...");
        gen_timer(6, wait_for_barrier_sim);
    }

}

function wait_for_barrier_sim(ID) {

    if ((timers[6] == ID) && (chkb_barriera.checked)) {
        if (debug_mode) { print("laser is waiting for barrier to be lowered"); }
        if (laser_barrier_down == 1) {
            print("laser already in position");
            mark_auto_sim();
            gen_timer(2, pump_not_present);
        }
        else {
            disconnect_func(wait_for_barrier_sim);
            laser_move_timed();
        }
        disconnect_func(wait_for_barrier_sim);
    }

}

function stop_search_auto_sim(ID) {

    if (timers[1] == ID && auto_mode == "ON") {
        current_pos = Axis.getPosition(2);
        //if (!sen_bar_gore) { barrier_down_auto(); }
        if (!(chkb_lp.checked)) {
            if (!(chkb_optika.checked)) {

                if (!(current_pos <= (home_pos - search_distance))) {
                    if (debug_mode) { print("Laser is moving to working pos..."); }
                }
                else {
                    Axis.stop(2);
                    write_log("Search distance passed but no pump found. Going back to ref...");
                    laser_ref_auto(); laser_ref_auto();
                    barrier_up_auto();
                    disconnect_func(stop_search_auto_sim);
                    retry_stop_choice();
                }
            }
            else {
                write_log("Pump in laser focus");
                disconnect_func(stop_search_auto_sim);
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
            laser_marking = 0;
            laser_in_working_pos = 0;
            laser_barrier_down = 0;
            //nom = 0;
            write_log("Barrier is not down, laser goes in reference position");
            disconnect_timers();
            laser_ref_auto();
            gen_timer(13, reset_auto_func_sim);
        }
    }
    else {
        System.stopLaser();
        laser_marking = 0;
        laser_in_working_pos = 0;
        laser_barrier_down = 0;
        //nom = 0;
        write_log("Optical sensor is not seeing pump, laser goes in reference position");
        disconnect_timers();
        laser_ref_auto();
        gen_timer(13, reset_auto_func_sim);
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
                System.stopLaser();
                laser_marking = 0;
                laser_in_working_pos = 0;
                laser_barrier_down = 0;
                //nom = 0;
                auto_mode = "OFF";
                barrier_up_auto();
                laser_ref_auto();
                write_log("Barrier not down during laser marking");
                gen_timer(13, reset_auto_func_sim);
            }
        }
        else {
            disconnect_func(check_marking_sim);
            System.stopLaser();
            laser_marking = 0;
            laser_in_working_pos = 0;
            laser_barrier_down = 0;
            //nom = 0;
            auto_mode = "OFF";
            write_log("Optical sensor is not seeing pump, laser goes in reference position");
            disconnect_timers();
            laser_ref_auto();
            barrier_up_auto();
            gen_timer(13, reset_auto_func_sim);
        }
    }
}

function reset_auto_func_sim(ID) {

    if (timers[13] == ID) {
        write_log("Resetting auto mode! Simulation mode *****************");
        reset_auto = 1;
        //disconnect_func(wait_for_pump); //Most important disconnect
        disconnect_func(reset_auto_func_sim);
        start_auto_mode();
        if (columns_dict["M"] != "/" && columns_dict["M"] != '') {
            serial_choice();
        }

    }
}


/*************************************************
 * END SIMULATION FUNCTIONS
 *************************************************/

function serial_choice_stop()
{
    
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

    if (ra_dialog.exec()) {
        write_log(" Ok pressed, creating new serial number");
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
	reset_auto = 1 ;
       // start_auto_mode();
    }
    else {
        write_log("Cancel pressed, keeping current serial: " + year + "-" + leftPad((curr_sn), 6));
      //  start_auto_mode();
	reset_auto =0 ;
	//barrier_down_auto();
	//laser_move_timed();
    }



    delete ra_dialog;
    System.collectGarbage();
    
}

function serial_choice() {

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

    if (ra_dialog.exec()) {
        write_log(" Ok pressed, creating new serial number");
        if (!(numWC % sn_marking_times)) {
            if (columns_dict["M"] != "/" && columns_dict["M"] != '') {
                if (!sn_fixed) {
                    curr_sn = parseInt(last_sn, 10) + 1;
                    last_sn = curr_sn;
                    last_sn = leftPad((last_sn), 6);
                    //update_sn();
                }
            }
        }
        start_auto_mode();
    }
    else {
        write_log("Cancel pressed, keeping current serial: " + year + "-" + leftPad((curr_sn), 6));
        start_auto_mode();
    }



    delete ra_dialog;
    System.collectGarbage();
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
        write_log("ok pressed, trying to find pump again");
        laser_move_timed();
	if(auto_mode == "ON")
	{
        		stop_auto();
		    }
		disconnect_func(wait_for_pump);
		disconnect_timers();
		start_auto_mode();
    }
    else {
        write_log("cancel pressed, stoping auto_mode");
        if (simulation_mode) {
           disconnect_func(wait_for_pump);
             disconnect_timers();
	     if(auto_mode == "ON"){
		 stop_auto();}
        }
        else {
	    disconnect_func(wait_for_pump);
             disconnect_timers();
             if(auto_mode == "ON"){
		 stop_auto();}
           // stop_auto();
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
        laser_barrier_down = 0;
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
        if (auto_mode == "ON") {
            write_log("Reset button pressed during Auto mode");
            System.stopLaser();
            disconnect_func(wait_for_pump);
            laser_marking = 0;
            laser_in_working_pos = 0;
            laser_barrier_down = 0;
            //nom = 0;
            laser_ref_auto();
            barrier_up_auto();
            if (simulation_mode) {
                gen_timer(13, reset_auto_func_sim);
            }
            else {
		gen_timer(14, wait_for_marking_end);
                //n_timer(13, reset_auto_func);
            }
        }
        if (auto_mode == "OFF") {
            write_log("Reset button pressed while not in Auto mode");
            System.stopLaser();
            laser_ref_auto();
        }
    }
    else {
        error_total_stop();
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

    var plog_file = new File(plog_loc + log_date + ".log");
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

