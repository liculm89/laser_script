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
    case System.DSP_DSP_INTERLOCK_ERROR:
        msg_txt = "Interlock error, reset laser";
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
    var mesg_txt = "Wait until marking is finished!";
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
    var mesg_txt = "Laser is not ready!";
    MessageBox.critical( mesg_txt, MessageBox.Ok);
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
