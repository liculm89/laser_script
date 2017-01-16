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
    }
}

function error_auto_mode()
{
    MessageBox.critical( "First stop auto mode!", MessageBox.Ok );
}

function error_auto_aoff()
{
    MessageBox.critical( "Auto mode already off", MessageBox.Ok );
}

function error_manual_mode()
{
    MessageBox.critical( "Wait until marking is finished!", MessageBox.Ok );
}

function error_total_stop()
{
    MessageBox.critical( "Total stop is active!", MessageBox.Ok );
}

function error_laser_not_rdy()
{
    MessageBox.critical("Laser is not ready!", MessageBox.Ok);
}

function error_cant_find_pump()
{
    MessageBox.critical("Pump not found! Going back to refence position", MessageBox.Ok);
}
