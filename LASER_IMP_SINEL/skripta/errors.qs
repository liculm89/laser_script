////////////////////////////////////
///ERORRS MESSAGES
////////////////////////////////////
function onLaserError(error) {
    switch (error) {
        case System.DSP_IN_HANG:
            System.resetBoard();
            break;
        case System.DSP_ERROR_INIT:
            MessageBox.critical("Board initialization error", MessageBox.Ok);
            break;
        case System.DSP_INTERLOCK_ERROR:
            msg_txt = "Interlock error, press and release total stop to reset laser";
            MessageBox.critical(msg_txt, MessageBox.Ok);
            write_log(msg_txt);
            last_error = msg_txt;
            break;
        case System.DSP_TEMPERATURE_ERROR:
            msg_txt = "Temperature error, press and release total stop to restart laser";
            MessageBox.critical(msg_txt, MessageBox.Ok);
            write_log(msg_txt);
            last_error = msg_txt;
            break;
    }
}

function create_mesgbox(txt)
{
    MessageBox.critical(txt, MessageBox.Ok);
    write_log(txt);
}

function process_error(code){
    switch(code){
        case 0:
        var mesg_txt = "First stop auto mode!";
        create_mesgbox(mesg_txt);
        case 1:
        var mesg_txt = "Barrier is not in lowered position, marking is stopped!";
        create_mesgbox(mesg_txt);
        case 2:
        var mesg_txt = "Auto mode already off";
        create_mesgbox(mesg_txt);
        case 3:
        var mesg_txt = "Auto mode already started, or laser marking started in manual mode";
        create_mesgbox(mesg_txt);
        case 4:
        var mesg_txt = "Total stop is active!";
        create_mesgbox(mesg_txt);
        case 5:
        var mesg_txt = "Laser not ready";
        create_mesgbox(mesg_txt);
        case 6:
        var mesg_txt = "Reset key sequence";
        create_mesgbox(mesg_txt);
        case 7:
        var mesg_txt = "Pump not found! Going back to refence position";
        create_mesgbox(mesg_txt);
        case 8:
        var mesg_txt = "Laser is in lowest position!";
        create_mesgbox(mesg_txt);
        case 9:
        var mesg_txt = "Laser is in highest position!";
        create_mesgbox(mesg_txt);
        case 10:
        var mesg_txt = "Initialization failed, database file missing or corrupted";
        create_mesgbox(mesg_txt);
        case 11:
        var mesg_txt = "Regulator fault! Check motor regulator";
        create_mesgbox(mesg_txt);
        case 12:
        var mesg_txt = "S.N. invalid, S.N. already exists";
        create_mesgbox(mesg_txt);
        case 13:
        var mesg_txt = "Auto mode already started, cannot change part during auto mode execution";
        create_mesgbox(mesg_txt);
        case 14:
        var mesg_txt = "Selected part and serial number not confirmed!";
        create_mesgbox(mesg_txt);
        case 15:
        var mesg_txt = "Check serial number format";
        create_mesgbox(mesg_txt);
        case 16:
        var mesg_txt = "Template file not defined";
        create_mesgbox(mesg_txt);
        case 17:
        var mesg_txt = "Check quantity input format";
        create_mesgbox(mesg_txt);
        case 18:
        var mesg_txt = "Logo object ID is not 'OBJ_I' or template file is missing";
        create_mesgbox(mesg_txt);
        case 19:
        var mesg_txt = "Barrier is not in lower position";
        create_mesgbox(mesg_txt);
        break;
    }
}
//0
function error_auto_mode() {
    var mesg_txt = "First stop auto mode!";
    MessageBox.critical(mesg_txt, MessageBox.Ok);
    write_log(mesg_txt);
    last_error = mesg_txt;
}
//1
function error_barrier_up() {
    var mesg_txt = "Barrier is not in lowered position, marking is stopped!";
    MessageBox.critical(mesg_txt, MessageBox.Ok);
    write_log(mesg_txt);
    last_error = mesg_txt;
}
//2
function error_auto_aoff() {
    var mesg_txt = "Auto mode already off";
    MessageBox.critical(mesg_txt, MessageBox.Ok);
    write_log(mesg_txt);
    last_error = mesg_txt;
}
//3
function error_manual_mode() {
    var mesg_txt = "Auto mode already started, or laser marking started in manual mode";
    MessageBox.critical(mesg_txt, MessageBox.Ok);
    write_log(mesg_txt);
    last_error = mesg_txt;
}
//4
function error_total_stop() {
    var mesg_txt = "Total stop is active!";
    MessageBox.critical(mesg_txt, MessageBox.Ok);
    write_log(mesg_txt);
    last_error = mesg_txt;
}
//5
function error_laser_not_rdy() {
    var mesg_txt = "Laser not ready";
    MessageBox.critical(label = mesg_txt, mesg_txt, MessageBox.Ok);
    write_log(mesg_txt);
    last_error = mesg_txt;
}
//6
function error_key_sequence() {
    var mesg_txt = "Reset key sequence";
    MessageBox.critical(mesg_txt, MessageBox.Ok, title = 'Laser not ready');
    write_log(mesg_txt);
    last_error = mesg_txt;
}
//7
function error_cant_find_pump() {
    var mesg_txt = "Pump not found! Going back to refence position";
    MessageBox.critical(mesg_txt, MessageBox.Ok);
    write_log(mesg_txt);
    last_error = mesg_txt;
}
//8
function error_min_pos() {
    var mesg_txt = "Laser is in lowest position!";
    MessageBox.critical(mesg_txt, MessageBox.Ok);
    write_log(mesg_txt);
    last_error = mesg_txt;
}
//9
function error_max_pos() {
    var mesg_txt = "Laser is in highest position!";
    MessageBox.critical(mesg_txt, MessageBox.Ok);
    write_log(mesg_txt);
    last_error = mesg_txt;
}
//10
function error_init_fail() {
    var mesg_txt = "Initialization failed, database file missing or corrupted";
    write_log(mesg_txt);
    MessageBox.critical(mesg_txt, MessageBox.Ok);
}
//11
function error_regulator_fault() {
    var mesg_txt = "Regulator fault! Check motor regulator";
    MessageBox.critical(mesg_txt, MessageBox.Ok);
    write_log(mesg_txt);
    last_error = mesg_txt;
}
//12
function error_sn_exists() {
    var mesg_txt = "S.N. invalid, S.N. already exists";
    MessageBox.critical(mesg_txt, MessageBox.Ok);
    write_log(mesg_txt);
    last_error = mesg_txt;
}
//13
function error_auto_started() {
    var mesg_txt = "Auto mode already started, cannot change part during auto mode execution";
    MessageBox.critical(mesg_txt, MessageBox.Ok);
    write_log(mesg_txt);
    last_error = mesg_txt;
}
//14
function error_selection_not_confirmed() {
    var mesg_txt = "Selected part and serial number not confirmed!";
    MessageBox.critical(mesg_txt, MessageBox.Ok);
    write_log(mesg_txt);
    last_error = mesg_txt;
}
//15
function error_sn_false_format() {
    var mesg_txt = "Check serial number format";
    MessageBox.critical(mesg_txt, MessageBox.Ok);
    write_log(mesg_txt);
    last_error = mesg_txt;
}
//16
function error_template_missing() {
    var mesg_txt = "Template file not defined";
    MessageBox.critical(mesg_txt, MessageBox.Ok);
    write_log(mesg_txt);
    last_error = mesg_txt;
}
//17
function error_wrong_quantity_format() {
    var mesg_txt = "Check quantity input format";
    MessageBox.critical(mesg_txt, MessageBox.Ok);
    write_log(mesg_txt);
    last_error = mesg_txt;
}
//18
function template_file_error() {
    var mesg_txt = "Logo object ID is not 'OBJ_I' or template file is missing";
    MessageBox.critical(mesg_txt, MessageBox.Ok);
    write_log(mesg_txt);
    last_error = mesg_txt;
}
//19
function error_barrier_not_down() {
    var mesg_txt = "Barrier is not in lower position";
    MessageBox.critical(mesg_txt, MessageBox.Ok);
    write_log(mesg_txt);
    last_error = mesg_txt;
}
