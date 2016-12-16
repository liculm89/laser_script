function onQueryStart()
{
  // TODO
}
function onLaserStop()
{
  // TODO
}
function onLaserStart()
{
  // TODO
}
function onLaserEnd()
{
  // TODO
}
function onLaserError(error)
{
  switch(error)
  {
    case System.DSP_IN_HANG:
      System.resetBoard();
      break;
    case System.DSP_ERROR_INIT:
      // This event is triggered each time the script engine starts
      // if the board was not properly loaded
      MessageBox.critical( "Board initialization error", MessageBox.Ok );
      break;
    // TODO
  }
}
function onClose()
{
  // TODO
}




function delay_func(ID)
{
  print("Delay reached");
  
  print ("...killing timer..ID:", ID);
  System.killTimer(ID);
  System["sigTimer(int)"].disconnect(delay_func);
}

function start_timer(ms)
{    
    print("timer delay: ", ms, " ms" );
     System["sigTimer(int)"].connect(delay_func);
     timer1 = System.setTimer(ms);
}

function main()
{
  System.sigQueryStart.connect(onQueryStart);
  System.sigLaserStop.connect(onLaserStop);
  System.sigLaserStart.connect(onLaserStart);
  System.sigLaserEnd.connect(onLaserEnd);
  System["sigLaserError(int)"].connect(onLaserError);
  System.sigClose.connect(onClose);
  // TODO
  
  print( "Starting timer ..." );
  
  start_timer(2000);
}

