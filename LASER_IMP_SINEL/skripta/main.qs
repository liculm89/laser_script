/*---------------------------------
 Template and log file paths, 
  ----------------------------------*/
var tmplPath ="F:\\LASER_IMP_SINEL\\IMP_SINEL.XLP";
var xlsPath ="F:\\LASER_IMP_SINEL\\TabelaNMTPLUS.xlsx";
var logoPath ="D:\\LASER_IMP_SINEL\\Predloge\\" ;
var logPath= "F:\\LASER_IMP_SINEL\\writeLog.txt";

//var xlsPath = "D:\\LASER_IMP_SINEL\\TabelaNMTPLUS.xlsx";
//var logPath = "D:\\LASER_IMP_SINEL\\writeLog.txt";

var h_Document,hDb, fw;
var txt_selected_logo = "Izbran logo: ";
var txt_num_writes = "Število zapisov (od zagona): ";

var auto_mode = "OFF";
var laser_status = "INACTIVE";

var z_axis_active = 0;
var sb1_v = 25;

/*---------------------------------------------------------
  Postavljanje globalnih varijabli PIN-ova
  --------------------------------------------------------*/

//Input PINs
const I_PIN_7 = 0x1; const I_PIN_8 = 0x2; const I_PIN_9 = 0x4; 
const I_PIN_10 = 0x8; const I_PIN_11 = 0x10; const I_PIN_12 = 0x20; 
const I_PIN_19 = 0x200; const  I_PIN_20 = 0x100;  const  I_PIN_21 = 0x80;  const  I_PIN_22 = 0x40;

//Output PINs
const O_PIN_2 = 0x1; const O_PIN_3 = 0x4; const O_PIN_4 = 0x10; const O_PIN_5 = 0x40; 
const O_PIN_6 = 0x100; const O_PIN_14 = 0x1000; const O_PIN_15 = 0x2; const O_PIN_16 = 0x08; 
const O_PIN_17 = 0x20; const O_PIN_18 = 0x80; 
const O_PIN_23 = 0x200; const O_PIN_24 = 0x800;

/*
Popis funkcija pinova
O_PIN 3 - Z os step			- OUTPUT
O_PIN 4 - Cilindar gore                       	- OUTPUT
O_PIN 6 - Z os Current off			- OUTPUT
I_PIN 7 - Senzor prisutnosti linije		- INPUT
I_PIN 8 - Glava lasera dolje		-INPUT
I_PIN 9 - Glava lasera gore		-INPUT
I_PIN 10 - Optički senzor			-INPUT
I_PIN 11 - Laserska barijera dolje		-INPUT
I_PIN 12 - Laserska barijera gore		-INPUT
O_PIN 16 - Z os direction			-OUTPUT
I_PIN 19 - Reset tipkalo			-INPUT
I_PIN 20 - Regulator fault			-INPUT
I_PIN 21 - Total stop input                     	-INPUT
O_PIN 23 - Cilindar dolje                       	-OUTPUT
*/

//Flags declaration

var bar_gore= 0;
var bar_dolje = 0;

var sen_linija = 0;
var sen_laser_gore = 0;
var sen_laser_dolje = 0;
var sen_optika = 0;
var sen_bar_dolje = 0;
var sen_bar_gore = 0;

var reset_tipka = 0;
var reg_fault = 0;
var total_stop = 0;

var laser_marking = 0;
var laser_in_working_pos = 0;

//Timers declaration
time_ms = 100;
timer1 = System.setTimer(time_ms);

time2_ms = 50;
timer2 = System.setTimer(time_ms);

time3_ms = 50;
timer3 = System.setTimer(time3_ms);

/*
  Function is triggered periodicaly with "timer1", reads inputs and sets flags
  */
function set_flags()
{
    if(IoPort.getPort(0) & I_PIN_7){ sen_linija = 1;} else{sen_linija=0;}
    if(IoPort.getPort(0) & I_PIN_8){ sen_laser_dolje = 1;} else{sen_laser_dolje = 0;}
    if(IoPort.getPort(0) & I_PIN_9){ sen_laser_gore = 1;} else{sen_laser_gore = 0;}     
    if(IoPort.getPort(0) & I_PIN_10){ sen_optika = 1;} else{sen_optika = 0;}
    if(IoPort.getPort(0) & I_PIN_11){ sen_bar_dolje = 1;} else{sen_bar_dolje = 0;}     
    if(IoPort.getPort(0) & I_PIN_12){ sen_bar_gore = 1;} else{sen_bar_gore = 0;}       
    if(IoPort.getPort(0) & I_PIN_19){ reset_tipka = 1;} else{reset_tipka = 0;}
    if(IoPort.getPort(0) & I_PIN_20){ reg_fault = 1;} else{reg_fault = 0;}
    if(IoPort.getPort(0) & I_PIN_21){ total_stop = 0;} else{total_stop = 1;}       
}


function onQueryStart()
{
  
}

/*
  Function is triggered when laser marking is interupted
  */
function onLaserStop()
{
   print("laser stoped"); 
   laser_status ="INACTIVE"; 
   laser_marking = 0;

}

/*
  Function is triggered when one of axis starts(moving) and on start of laser marking process
  */
function onLaserStart()
{
    laser_status="ACTIVE";

}

/*
  Function is triggered when one of axis stops movement or when marking proces i finished
  */
function onLaserEnd()
{
  
  laser_status ="INACTIVE";
  laser_marking = 0;
  //System.incrementCounter("num_writes");
}

function onClose()
{
 
}

function onLneChange(text) 
{print("onLneChange("+text+")");}

function onOutOfRange () 
{print("onOutOfRange()");}

/*-----------------------------------------------------------------------------------------------
  Template reading, laser document creation and execution function
  -----------------------------------------------------------------------------------------------*/
function readFile()
{  
    print("reading and generating");
    //var nm = num.value;
    nm = 1;
    var pn = cmb.currentItem;

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

	    h_Document = new LaserDoc;   
	    h_Document.load(tmplPath);
	
	    print("Read:" + objects);
	    writeLog("Read:" + objects);

	    laser_objects = ["obj_a", "obj_b", "obj_c", "obj_d", "obj_e", "obj_f", "obj_g", "obj_h", "obj_i", "obj_j", "obj_k", "obj_l", "obj_m"] ;
	  
	   for( i = 0; i < (laser_objects.length - 2) ; i++)
	   {	          
	       var obj =  h_Document.getLaserObject(laser_objects[i]);
	       obj.text = objects[i];
	   }
	   
	   var l = objects[ (objects.length - 2)];
	   var m = objects[(objects.length - 1)];
	   var logo = h_Document.getLaserImported("logo");
	   
	   logo.importFile(logoPath + l + ".xlp");
	   //logo.importFile("D:\\LASER_IMP_SINEL\\Predloge\\" + l + ".xlp"); 
	   //logo.importFile("F:\\LASER_IMP_SINEL\\Predloge\\" + l + ".xlp"); 
	   
	   selectedLogo.text = selectedLogo_a.text = txt_selected_logo + l;
	   	   
	   var obj_m = h_Document.getLaserObject(laser_objects[(laser_objects.length-1)]);
	   obj_m.text = m;
	   
	    print( "Document marking..." );		
	    h_Document.update();	    
	    h_Document.execute();
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

//Log creating/appending function
function writeLog(currentNum)
{
    var today = new Date();
    
    print("Writing to log:" + currentNum);
    var outFile = new File(logPath);
    outFile.open(File.Append);
    
    outFile.write( "\r\n" + today.toLocaleString() + " - " + currentNum );
    outFile.close();
}


const num_writes;

  /*------------------------------------------------
    Generiranje liste komada iz excel tabele
    ------------------------------------------------*/
function parts_list_gen()
{
  
   hDb2 = new Db("QODBC");
   hDb2.dbName = "DRIVER={Microsoft Excel Driver (*.xls, *.xlsx, *.xlsm, *.xlsb)};HDR=yes;Dbq=" + xlsPath;    
   
    if(hDb2.open())
    {	
	part_list = [];
	var res = hDb2.exec("SELECT * FROM [List1$]" );
	for (i = 0; i < res.length; i++){part_list[i] = res[i][0];}	
    }
    else
    {
	print("Result: " + res + " - Error: " + hDb2.lastError());
	writeLog("Result: " + res + " - Error: " + hDb2.lastError());
     }
}

var part_list;

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
  IoPort.sigInputChange.connect(set_flags);
  
  
  barrier_up();
  
  //manually set_flags only for debuging
  set_flags();
  
  Axis.reset(2);
  
  parts_list_gen(); 
  
  //pozivanje funcije koja generira GUI aplikaciju
  gen_dialog(part_list);
 
}

