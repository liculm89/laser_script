/*
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
*/

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
    if(timer2 == ID)
    {
	print ("delay reached");
	print (ID);
	killT(ID, delay_func);
    }
  }

function delay_func2(ID)
{
    if (timer3 == ID)
    {  
	print ("delay reached2"); 
	print (ID);
	killT(ID, delay_func2);
    }
}

function start_timer(ms, funkc, n)
{    
     print("starting timer delay: ", ms, " ms" );
    
     System["sigTimer(int)"].connect(funkc);
     //timer = System.setTimer(ms);
        
}


  function timer_tick(ID)
  {
      if (timer1 == ID)
      {
	  print("tick");
	  print(ID);
	  killT(ID, timer_tick);
      }
  
  }

  function killT(ID, func)
  {
 //print ("...killing timer..ID:", ID);
  System.killTimer(ID);
  //System["sigTimer(int)"].disconnect(func);
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
  
  
  //f = delay_func;
  
  timer1 = System.setTimer(1000);
  start_timer(1000, timer_tick);

  timer2 = System.setTimer(3000);
  start_timer(3000, delay_func);
 
  timer3 = System.setTimer(6000);
  start_timer(6000, delay_func2);

  
  //start_timer(200, delay_func);
  

  
}




