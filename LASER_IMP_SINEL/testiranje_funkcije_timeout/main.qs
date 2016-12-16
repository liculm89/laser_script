var Timer = function()
{
    this.timeout = 1000;
    this.Enable = new Boolean(false);
    this.Tick;
    var timerId = 0;
    var thisObject;
    
    this.Start = function()
{	
	this.Enable = new Boolean(true);
	thisObject = this;
	print("started");
	
	if ( thisObject.Enable)
	{
	    thisObject.timerId = start_timer(thisObject.timeout, thisObject);
	   
	    //thisObject.timerId 
	    // thisObject.Tick();
	}
	
    };
    
    this.Stop = function()
   {
	thisObject.Enable = new Boolean(false);
	clearInterval(thisObject.timerId);
    };
};

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




function delay_func(ID, obj)
{
  //print("Delay reached");
  obj.Tick();
  print ("...killing timer..ID:", ID);
  System.killTimer(ID);
  System["sigTimer(int)"].disconnect(delay_func);
}

function start_timer(ms, obj)
{    
     print("timer delay: ", ms, " ms" );
    // obj.Tick();
     System["sigTimer(int)"].connect(delay_func(System.sigTimer.ID,obj));
     timer1 = System.setTimer(ms);
}


  function timer_tick()
  {
      print("tick");
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
  
  //print( "Starting timer ..." );
  
  //start_timer(2000);
  
 /* 
  for( i = 0; i < 10; i++) {
   print(i);
   start_timer(1500);
  }
*/  
  var obj = new Timer();
  
  
  
  obj.timeout = 3000;
  
  obj.Tick = timer_tick;


  //obj.Tick = timer_tick();

  
  obj.Start();
  
  
}




