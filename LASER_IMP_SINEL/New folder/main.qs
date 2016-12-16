//GLOBAL va

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


function onTimer(ID)
{
    if ( timer1 == ID)
    {print( "Timer 1 ");}
    
   
    if (stop_flag = 0)
    {	
     System.killTimer(ID);
     System["sigTimer(int)"].disconnect(onTimer);
    }
}
    
   
function start_check()
{
    System["sigTimer(int)"].connect(onTimer);
}

function stop_check()
{
    System.killTimer(ID);
    System["sigTimer(int)"].disconnect(onTimer);
}

var stop_flag = 1;

function main()
{
  System.sigQueryStart.connect(onQueryStart);
  System.sigLaserStop.connect(onLaserStop);
  System.sigLaserStart.connect(onLaserStart);
  System.sigLaserEnd.connect(onLaserEnd);
  System["sigLaserError(int)"].connect(onLaserError);
  System.sigClose.connect(onClose);
  // TODO
  //var i = 10;
 start_check()

   
   
  


}

