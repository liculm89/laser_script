function onLaserError(error)
{
    switch(error)
    {
    case System.DSP_IN_HANG:
        System.resetBoard();
        break;
    case System.DSP_ERROR_INIT:
        MessageBox.critical( "Board initialization error", MessageBox.Ok );
        break;
    case System.DSP_INTERLOCK_ERROR:
        msg_txt = "Interlock error, reset laser";
        MessageBox.critical( msg_txt, MessageBox.Ok );
        last_error = msg_txt;
    case System.DSP_TEMPERATURE_ERROR:
        msg_txt = "Temperature error, press total stop to restart laser";
        MessageBox.critical( msg_txt, MessageBox.Ok );
        last_error = msg_txt;	
    }
}

function error_auto_mode()
{
    var mesg_txt = "First stop auto mode!";
    MessageBox.critical( mesg_txt, MessageBox.Ok );
    last_error = mesg_txt;
}

function error_auto_aoff()
{
    var mesg_txt = "Auto mode already off";
    MessageBox.critical( mesg_txt, MessageBox.Ok );
    last_error = mesg_txt;
}

function error_manual_mode()
{
    var mesg_txt = "Auto mode already started, or laser marking started in manual mode";
    MessageBox.critical( mesg_txt, MessageBox.Ok );
    last_error = mesg_txt;
}

function error_total_stop()
{
    var mesg_txt ="Total stop is active!";
    MessageBox.critical( mesg_txt, MessageBox.Ok );
    last_error = mesg_txt;
}

function error_laser_not_rdy()
{
    var mesg_txt = "Laser not ready";
    MessageBox.critical( label =  mesg_txt, mesg_txt, MessageBox.Ok);
    last_error = mesg_txt;
}

function error_key_sequence()
{
    var mesg_txt = "Reset key sequence";
    MessageBox.critical( mesg_txt, MessageBox.Ok, title ='Laser not ready');
    last_error = mesg_txt;
}

function error_cant_find_pump()
{
    var mesg_txt = "Pump not found! Going back to refence position";
    MessageBox.critical( mesg_txt, MessageBox.Ok);
    last_error = mesg_txt;
}

function error_min_pos()
{
    var mesg_txt = "Laser is in lowest position!";
    MessageBox.critical( mesg_txt, MessageBox.Ok);
    last_error = mesg_txt;
}

function error_max_pos()
{
    var mesg_txt = "Laser is in highest position!";
    MessageBox.critical( mesg_txt, MessageBox.Ok);
    last_error = mesg_txt;
}

function error_init_fail()
{
    var mesg_txt = "Initialization failed, database file missing or corrupted";
     MessageBox.critical( mesg_txt, MessageBox.Ok);
}

function error_regulator_fault()
{
   var mesg_txt = "Regulator fault! Check motor regulator";
   MessageBox.critical( mesg_txt, MessageBox.Ok);
   last_error = mesg_txt;
}