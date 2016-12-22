/*---------------------------------
  file paths, etc...
  ----------------------------------*/

var xlsPath ="F:\\LASER_IMP_SINEL\\TabelaNMTPLUS.xlsx";
var logPath= "F:\\LASER_IMP_SINEL\\writeLog.txt";

//var xlsPath = "D:\\LASER_IMP_SINEL\\TabelaNMTPLUS.xlsx";
//var logPath = "D:\\LASER_IMP_SINEL\\writeLog.txt";


var h_Document,hDb, fw;
var txt_selected_logo = "Izbran logo: ";
var txt_num_writes = "Število zapisov (od zagona): ";





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
  
}
function onLaserEnd()
{
  System.incrementCounter("num_writes");
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
    
    if(IoPort.getPort(0) & I_PIN_9)
   {
	print ("pin 9");
	print("Axis z pos:", Axis.getPosition(2));
	
	
     }
}


/*---------------------------------------------------------
  Postavljanje globalnih varijabli PIN-ova
  --------------------------------------------------------*/

//Input PIN-ovi
const I_PIN_7 = 0x1; const I_PIN_8 = 0x2; const I_PIN_9 = 0x4; 
const I_PIN_10 = 0x8; const I_PIN_11 = 0x10; const I_PIN_12 = 0x20; 
const I_PIN_19 = 0x200; const  I_PIN_20 = 0x100;  const  I_PIN_21 = 0x80;  const  I_PIN_22 = 0x40;

//Output PIN-ovi
const O_PIN_2 = 0x1; const O_PIN_3 = 0x4; const O_PIN_4 = 0x10; const O_PIN_5 = 0x40; 
const O_PIN_6 = 0x100; const O_PIN_14 = 0x1000; const O_PIN_15 = 0x2; const O_PIN_16 = 0x08; 
const O_PIN_17 = 0x20; const O_PIN_18 = 0x80; 
const O_PIN_23 = 0x200; const O_PIN_24 = 0x800;

//Definiranje varijabli 
const sb1_v = 25;



function onLneChange(text) {
  print("onLneChange("+text+")");
}

function onOutOfRange () {
  print("onOutOfRange()");
}

function readFile()
{  
    var nm = num.value;
    var pn = cmb.currentItem;
    //var pn = pna.text;
    System.makeCounterVariable("num_writes", 0, 0, nm, 1, 1, 0, 3, 10, true );

if(pn != "" )
{  
    print("Selected P.N.: " + pn );
    print("Number of copies.: " + nm );
    writeLog("Selected P.N.:" + pn);
    hDb = new Db("QODBC");
    hDb.dbName = "DRIVER={Microsoft Excel Driver (*.xls, *.xlsx, *.xlsm, *.xlsb)};HDR=yes;Dbq=" + xlsPath;    
   
    if(hDb.open())
    {
	print("entered");
	var res = hDb.exec("SELECT * FROM [List1$] WHERE PN LIKE '" + pn + "'");	
	var objects = [];
	
	if (typeof res[0] == "object")
	{
	    for ( i = 0; i < res[0].length; i ++)
	    {
		objects[i] = res[0][i];
	    }
	    print(objects);
	    
	    // Select the right template
	    h_Document = new LaserDoc;   
	   // h_Document.load("C:\\LASER_IMP\\Predloge\\" + l + ".XLP");
	    //h_Document.load("D:\\LASER_IMP_SINEL\\IMP_SINEL.XLP");
	    h_Document.load("F:\\LASER_IMP_SINEL\\IMP_SINEL.XLP");
	
	    print("Read:" + objects);
	    writeLog("Read:" + objects);

	    laser_objects = ["obj_a", "obj_b", "obj_c", "obj_d", "obj_e", "obj_f", "obj_g", "obj_h", "obj_i", "obj_j", "obj_k", "obj_l", "obj_m"] ;
	  
	   for( i = 0; i < (laser_objects.length - 2) ; i++)
	   {
	       print(laser_objects[i]);	       
	       var obj =  h_Document.getLaserObject(laser_objects[i]);
	       obj.text = objects[i];
	   }
	   
	   var l = objects[ (objects.length - 2)];
	   var logo = h_Document.getLaserImported("logo");
	   //logo.importFile("D:\\LASER_IMP_SINEL\\Predloge\\" + l + ".xlp"); 
	   //logo.importFile("D:\\LASER_IMP_SINEL\\Predloge\\" + l + ".xlp"); 
	   logo.importFile("F:\\LASER_IMP_SINEL\\Predloge\\" + l + ".xlp"); 
	   
	   selectedLogo.text = txt_selected_logo + l;
	   
	   var obj_m = h_Document.getLaserObject(laser_objects[(laser_objects.length-1)]);
	   obj_m.text = m;
		
	    print( "Document marking..." );
		
	    h_Document.update();	    
	    
	    //for(var i=1; i <= nm; i++ )
	    {		
		h_Document.execute();
		//print("Marking copy " + num_writes.value + " of: "+ nm);
	    }
	}
	else
	{
	     print("Result: " + res + " - Error: " + hDb.lastError());
	     writeLog("Result: " + res + " - Error: " + hDb.lastError());
	}
     }
    
    hDb.close();
    }
}

function writeLog(currentNum)
{
    var today = new Date();
    
    print("Writing to log:" + currentNum);
    var outFile = new File(logPath);
    outFile.open(File.Append);
    
    outFile.write( "\r\n" + today.toLocaleString() + " - " + currentNum );

    outFile.close();
}



function move_up()
{
    print( "Current Z axis poz: " + Axis.getPosition(2));
    Axis.move(2, (Axis.getPosition(2) + sb1_v) );
}

function move_down()
{
    print( "Current Z axis poz: " + Axis.getPosition(2));
    Axis.move(2, (Axis.getPosition(2) - sb1_v) );
}

function stop_axis()
{	
        
     print( "Current Z axis poz: " + Axis.getPosition(2));
     Axis.stop(2);
     print ("Stop!");
 }

function sb1_ch(value)
{
    print(value);
    sb1_v = value;
}

 
function gen_dialog(part_list)
{
  var dialog = new Dialog ("Laser control",Dialog.D_OK,false, 0x00040000);
  dialog.okButtonText = "Done"; dialog.cancelButtonText = "Abort";
  dialog.setFixedSize(400,450);
  /*--------------------------
     GUI - automatski mod
     ------------------------*/
   dialog.newTab("Automatic");
   
   
   /*--------------------------
     GUI - manualni mod
     ------------------------*/
   dialog.newTab("Manual");
   
   gb = new GroupBox();gb.title = "Settings";
   dialog.add(gb);
   
   lbl1 = new Label(); lbl1.text = "Z axis current position: " + Axis.getPosition(2);  
   gb.add(lbl1);  
  
   
  sb1 = new SpinBox("Move distance:", 25);  sb1["sigValueChanged(int)"].connect(sb1_ch);
  dialog.add(sb1);
  
  var btn = PushButton ("Move up");
  btn["sigPressed()"].connect(move_up);
  dialog.add(btn);
  
  var btn2 = PushButton ("Move down");
  btn2["sigPressed()"].connect(move_down);
  dialog.add(btn2);
  
  var btn3 = PushButton ("STOP!");
  btn3["sigPressed()"].connect(stop_axis);
  dialog.add(btn3);
       
  
   dialog.okButtonText = "Done"
   dialog.cancelButtonText = "Abort";
       
    gb_mark = new GroupBox("Laser Marking");
    dialog.add(gb_mark);
    cmb = new ComboBox("Select type", part_list);
    gb_mark.add(cmb);
   
       
	
    num = new NumberEdit("Prosim vnesite količino: ", 1);
    num.decimals = 0;  num.minimum = 1;
      
    num["sigNumberChanged(double)"].connect(onLneChange);
    num["sigOutOfRange()"].connect(onOutOfRange);
    gb_mark.add( num );	
	
    selectedLogo = new Label(txt_selected_logo + "/"); 
    gb_mark.add(selectedLogo);
       
    var btn = PushButton ("ZAPIŠI!");
    btn["sigPressed()"].connect(readFile);
    gb_mark.add(btn);
   
    dialog.show();     
    
}

const num_writes;
function main()
{
  System.sigQueryStart.connect(onQueryStart);
  System.sigLaserStop.connect(onLaserStop);
  System.sigLaserStart.connect(onLaserStart);
  System.sigLaserEnd.connect(onLaserEnd);
  System["sigLaserError(int)"].connect(onLaserError);
  System.sigClose.connect(onClose);
   
  var nm;
  
  System.makeCounterVariable("num_writes", 0, 0, nm, 1, 1, 0, 3, 10, true );
  
  
  IoPort.checkPort(0);
  IoPort.sigInputChange.connect(portchanged);
  
  /*------------------------------------------------
    Čitanje liste komada iz excel tabele
    ------------------------------------------------*/
   hDb2 = new Db("QODBC");
   hDb2.dbName = "DRIVER={Microsoft Excel Driver (*.xls, *.xlsx, *.xlsm, *.xlsb)};HDR=yes;Dbq=" + xlsPath;    
   
    if(hDb2.open())
    {	
	part_list = [];
	print("opened");
	var res = hDb2.exec("SELECT * FROM [List1$]" );
	for (i = 0; i < res.length; i++)
	{	   
	    part_list[i] = res[i][0];
	}	
    }
    else
	{
	     print("Result: " + res + " - Error: " + hDb2.lastError());
	     writeLog("Result: " + res + " - Error: " + hDb2.lastError());
	}
    
  //pozivanje funcije koja podiže GUI aplikaciju
  gen_dialog(part_list);
   
}

