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

var auto_mode = "OFF";
var laser_status = "INACTIVE";

var z_axis_active = 0;
var sb1_v = 25;

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

//flags

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



function set_flags()
{
    if(IoPort.getPort(0) & I_PIN_7){ sen_linija = 1;} else{sen_linija=0;}
    if(IoPort.getPort(0) & I_PIN_8){ sen_laser_dolje = 1;} else{sen_laser_dolje =0;}
    if(IoPort.getPort(0) & I_PIN_9){ sen_laser_gore = 1;} else{sen_laser_gore =0;}     
    if(IoPort.getPort(0) & I_PIN_10){ sen_optika = 1;} else{sen_optika =0;}
    if(IoPort.getPort(0) & I_PIN_11){ sen_bar_dolje = 1;} else{sen_bar_dolje =0;}     
    if(IoPort.getPort(0) & I_PIN_12){ sen_bar_gore = 1;} else{sen_bar_gore =0;}       
    if(IoPort.getPort(0) & I_PIN_19){ reset_tipka = 1;} else{reset_tipka =0;}
    if(IoPort.getPort(0) & I_PIN_20){ reg_fault = 1;} else{reg_fault =0;}
    if(IoPort.getPort(0) & I_PIN_20){ total_stop = 1;} else{total_stop =0;}       
}


function onQueryStart()
{
  // TODO
}
function onLaserStop()
{
    
   laser_status ="INACTIVE"; 

}
function onLaserStart()
{
    laser_status="ACTIVE";

}
function onLaserEnd()
{
  
   laser_status ="INACTIVE";
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
    
    set_flags();
}

function onLneChange(text) {
  print("onLneChange("+text+")");
}

function onOutOfRange () {
  print("onOutOfRange()");
}

function readFile_auto()
{
    if(auto_mode == "OFF" &&  laser_status != "ACTIVE"  && total_stop == 0)
    {	
	auto_mode = "ON";
	readFile();
    }
    else {error_manual_mode(); }
}

function readFile_manual()
{
    if(auto_mode == "OFF" && laser_status != "ACTIVE" && total_stop == 0)
    {
	readFile();
    }
    else { error_auto_mode(); }
}

function stop_auto(){      
	auto_mode = "OFF";
	System.stopLaser();
	laser_status = "INACTIVE";
    }

function stop_m_manual(){
    if(auto_mode == "OFF")
    {
	System.stopLaser();
	laser_status = "INACTIVE"; 
    }
    else { error_auto_mode(); }
}

function error_auto_mode()
{
    MessageBox.critical( "First stop auto mode!", MessageBox.Ok );
}

function error_manual_mode()
{
    MessageBox.critical( "Wait until marking is finished!", MessageBox.Ok );
}

function readFile()
{  
    var nm = num.value;
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
	       var obj =  h_Document.getLaserObject(laser_objects[i]);
	       obj.text = objects[i];
	   }
	   
	   var l = objects[ (objects.length - 2)];
	   var m = objects[(objects.length - 1)];
	   var logo = h_Document.getLaserImported("logo");
	   
	   //logo.importFile("D:\\LASER_IMP_SINEL\\Predloge\\" + l + ".xlp"); 
	   logo.importFile("F:\\LASER_IMP_SINEL\\Predloge\\" + l + ".xlp"); 
	   
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
    if (auto_mode == "OFF")
    {
	print( "Current Z axis poz: " + Math.round(Axis.getPosition(2)));
	Axis.move(2, (Axis.getPosition(2) + sb1_v) );
	Axis.stopMoreAxis(2);
    }
    else { error_auto_mode(); }
}

function move_down()
{
    if (auto_mode == "OFF")
    {
	print( "Current Z axis poz: " + Math.round(Axis.getPosition(2)));
	Axis.move(2, (Axis.getPosition(2) - sb1_v) );
	Axis.stopMoreAxis(2);
    }
    else { error_auto_mode(); }
}

function stop_axis()
{	
    if (auto_mode == "OFF")
    {
	print( "Current Z axis poz: " + Math.round(Axis.getPosition(2)));
	Axis.stop(2);
	print ("Stop!");
    }
    else { error_auto_mode(); }
 }

function barrier_up()
{
      if (auto_mode == "OFF")
    {
	   	  
	   print("barrier up"); 
	   IoPort.setPort(0, O_PIN_4);
	   bar_gore = 1;
     }
      else { error_auto_mode(); }
}

function barrier_down()
{
     if (auto_mode == "OFF")
    {	
	 IoPort.setPort(0, O_PIN_23);
	 bar_dolje = 1;
	 print("barrier down");
     }
      else { error_auto_mode(); }
 }

function sb1_ch(value)
{
    //print(value);
    sb1_v = value;
}

/*-----------------------------------
  Kreiranje GUI aplikacije
  -----------------------------------*/
function gen_dialog(part_list)
{
  var dialog = new Dialog ("Laser control",Dialog.D_OK,false, 0x00040000);
  dialog.okButtonText = "Done"; dialog.cancelButtonText = "Abort";
  dialog.setFixedSize(450,650);
  /*--------------------------
     GUI - automatski mod
     ------------------------*/
    dialog.newTab("Automatic mode");
    auto_box = new GroupBox(); auto_box.title = "Automatic laser marking";
    dialog.add(auto_box);
    
    cmb_a = new ComboBox("Select type", part_list);
    auto_box.add(cmb_a);

    selectedLogo_a =  new Label(txt_selected_logo + "/"); 
    auto_box.add(selectedLogo_a);
    
    var btn_auto_mode = PushButton ("START AUTO MODE");
    btn_auto_mode["sigPressed()"].connect(readFile_auto);
    auto_box.add(btn_auto_mode);
    
    var btn_auto_stop = PushButton ("STOP AUTO MODE" ); 
    btn_auto_stop["sigPressed()"].connect(stop_auto);
    auto_box.add(btn_auto_stop);
  
    dialog.addSpace(350);
    status_box = new GroupBox(); status_box.title= "Status";
    dialog.add(status_box);
    
    lbl_auto_status = new Label(); lbl_auto_status.text = "Auto mode: " + auto_mode;
    status_box.add(lbl_auto_status);
    
    lbl_marking = new Label(); lbl_marking.text = "Laser status :" + laser_status;
    status_box.add(lbl_marking);
   
    /*--------------------------
     GUI - manualni mod
     ------------------------*/
   dialog.newTab("Manual mode");
   
   //grupa "settings"
   gb = new GroupBox();gb.title = "Settings";
   dialog.add(gb);
   
   lbl1 = new Label(); lbl1.text = "Z axis current position: " + Axis.getPosition(2);  
   gb.add(lbl1);  

  //grupa "laser pos"
  gb_lp = new GroupBox(); gb_lp.title = "Laser position";
  sb1 = new SpinBox("Move distance:", 25);  sb1["sigValueChanged(int)"].connect(sb1_ch);
  gb_lp.add(sb1);
  
  var btn = PushButton ("Move up");
  btn["sigPressed()"].connect(move_up);
  gb_lp.add(btn);
  
  var btn2 = PushButton ("Move down");
  btn2["sigPressed()"].connect(move_down);
  gb_lp.add(btn2);
  
  var btn3 = PushButton ("STOP!");
  btn3["sigPressed()"].connect(stop_axis);
  gb_lp.add(btn3);
  dialog.add(gb_lp);
  
   dialog.okButtonText = "Done"
   dialog.cancelButtonText = "Abort";
   
   //groupa " laser barrier"
   gb_lb = new GroupBox(); gb_lb.title ="Laser barrier";
   
   var btn_bar_up = PushButton("Barrier up");
   btn_bar_up["sigPressed()"].connect(barrier_up);
   gb_lb.add(btn_bar_up);
 	   
   var btn_bar_down = PushButton("Barrier down");
   btn_bar_down["sigPressed()"].connect(barrier_down);
   gb_lb.add(btn_bar_down);
	   
    dialog.add(gb_lb);
  
   //manual laser marking group    
    gb_mark = new GroupBox("Manual Laser Marking");
   
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
    btn["sigPressed()"].connect(readFile_manual);
    gb_mark.add(btn);
    
    var btn_stop_m = PushButton ("STOP MARKING!");
    btn_stop_m["sigPressed()"].connect(stop_m_manual);
    gb_mark.add(btn_stop_m);
     
    dialog.add(gb_mark);
    
    status_box = new GroupBox(); status_box.title= "Status";
    dialog.add(status_box);
    
    lbl_auto_status_m = new Label(); lbl_auto_status.text = "Auto mode: " + auto_mode;
    status_box.add(lbl_auto_status_m);
    
    lbl_marking_m = new Label(); lbl_marking.text = "Laser status :" + laser_status;
    status_box.add(lbl_marking_m);
    
    
    /*-----------------
      I/O Status tab
      -------------------*/
    dialog.newTab("I/O Status");
    
    //groupbox inputs
    gb_inputs = new GroupBox(); gb_inputs.title = "Inputs status";
    dialog.add(gb_inputs);
    lb_sen_linija = new Label(); lb_sen_linija.text = "Senzor linije: " + get_stat(sen_linija);
    gb_inputs.add(lb_sen_linija);
    
    lb_sen_bar_gore = new Label(); lb_sen_bar_gore.text = "Senzor laserske barijere gore:" + get_stat(sen_bar_gore);
    gb_inputs.add(lb_sen_bar_gore);
    
    lb_sen_bar_dolje = new Label(); lb_sen_bar_dolje.text = "Senzor laserske barijere dolje:" + get_stat(sen_bar_dolje);
    gb_inputs.add(lb_sen_bar_dolje);
    
    lb_sen_laser_gore = new Label(); lb_sen_laser_gore.text = "Senzor laserske glave gore:" + get_stat(sen_laser_gore);
    gb_inputs.add(lb_sen_laser_gore);
    
    lb_sen_laser_dolje = new Label(); lb_sen_laser_dolje.text = "Senzor laserske barijere dolje:" + get_stat(sen_laser_dolje);
    gb_inputs.add(lb_sen_laser_dolje);
    
    lb_sen_optika = new Label(); lb_sen_optika.text = "Optički senzor:" + get_stat(sen_optika);
    gb_inputs.add(lb_sen_optika);
    
    lb_reg_fault = new Label(); lb_reg_fault.text = "Regulator fault:" + get_stat(reg_fault);
    gb_inputs.add(lb_reg_fault);
    
    lb_total_stop = new Label(); lb_total_stop.text = "Total stop:" + get_stat(total_stop);
    gb_inputs.add(lb_total_stop);
    
    lb_reset_tipka = new Label(); lb_reset_tipka.text = "Reset tipka:" + get_stat(reset_tipka);
    gb_inputs.add(lb_reset_tipka);
    
    dialog.show();     
    
    time_ms = 100;
    timer1 = System.setTimer(time_ms);
    start_timer(time_ms, gui_update);
}

function get_stat(input)
{
    if(input){stat= "Active";} else {stat="Inactive";}
    return stat;
}

function start_timer(ms, funkc, n)
{    
     print("starting timer delay: ", ms, " ms" );  
     System["sigTimer(int)"].connect(funkc);
     //timer = System.setTimer(ms);        
}

function gui_update(ID)
{
    if (timer1 == ID)
      {	
	lbl1.text = "Z axis current position: " + Math.round(Axis.getPosition(2));
                lbl_auto_status_m.text= lbl_auto_status.text = "Auto mode: " + auto_mode;
	lbl_marking_m.text = lbl_marking.text = "Laser status :" + laser_status;	
	
	 lb_sen_bar_gore.text = "Senzor laserske barijere gore:" + get_stat(sen_bar_gore);
	 lb_sen_bar_dolje.text = "Senzor laserske barijere dolje:" + get_stat(sen_bar_dolje);
	 lb_sen_laser_gore.text = "Senzor laserske glave gore:" + get_stat(sen_laser_gore);
	 lb_sen_laser_dolje.text = "Senzor laserske barijere dolje:" + get_stat(sen_laser_dolje);
	 lb_sen_optika.text = "Optički senzor:" + get_stat(sen_optika);
	 lb_reg_fault.text = "Regulator fault:" + get_stat(reg_fault);
	 lb_total_stop.text = "Total stop:" + get_stat(total_stop);
	 lb_reset_tipka.text = "Reset tipka:" + get_stat(reset_tipka); 
      }
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
  
  set_flags();
  
  /*------------------------------------------------
    Generiranje liste komada iz excel tabele
    ------------------------------------------------*/
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
    
  //pozivanje funcije koja generira GUI aplikaciju
  gen_dialog(part_list);
 
}

