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

function portchanged()
{
    print("port changed!");
    
    if(IoPort.getPort(0) & PORT_9)
   {
	print ("0x4 ");
	//IoPort.setPort(0, 0x100);
	print("Axis z pos:", Axis.getPosition(2));
	//Axis.move(2, 500.6);
	//print(IoPort.setPort(0, 0x100));
     }
}

const PORT_9 = 0x4;


function main()
{
  System.sigQueryStart.connect(onQueryStart);
  System.sigLaserStop.connect(onLaserStop);
  System.sigLaserStart.connect(onLaserStart);
  System.sigLaserEnd.connect(onLaserEnd);
  System["sigLaserError(int)"].connect(onLaserError);
  System.sigClose.connect(onClose);
  // TODO

  
  IoPort.checkPort(0);
  IoPort.sigInputChange.connect(portchanged);
  
  Axis.move(2, 250);
  print( "Ready !" );
}

