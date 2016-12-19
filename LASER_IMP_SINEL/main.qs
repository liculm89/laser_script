// Excel File path
var xlsPath ="F:\\LASER_IMP_SINEL\\TabelaNMTPLUS.xlsx";
var logPath= "F:\\LASER_IMP_SINEL\\writeLog.txt";

//var xlsPath = "D:\\LASER_IMP_SINEL\\TabelaNMTPLUS.xlsx";
//var logPath = "D:\\LASER_IMP_SINEL\\writeLog.txt";



// Varibales
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
    //num_writes +=1;
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
  }
function main()
{
  System.sigQueryStart.connect(onQueryStart);
  System.sigLaserStop.connect(onLaserStop);
  System.sigLaserStart.connect(onLaserStart);
  System.sigLaserEnd.connect(onLaserEnd);
  System["sigLaserError(int)"].connect(onLaserError);
  System.sigClose.connect(onClose);
  
 /* 
  var part_list_file = new File("F:\\LASER_IMP_SINEL\\parts_list.txt");
  part_list_file.open(File.ReadOnly);
  var part_list = []
  var i = 0;		   
 while (!part_list_file.eof )
  {
    part_list[i] = part_list_file.readLine();
    i  += 1;
  }
 box = new ComboBox("Select type:", part_list);
*/
  
  //System.sigClose.connect( Close );
        var  dialog = new Dialog("IMP_Sinel",Dialog.D_NONE,false,0x00040000);
        dialog.caption = "Vnesite P.N.";
        
        
        dialog.okButtonText = "Done"
        dialog.cancelButtonText = "Abort";
        //dialog.okButtonText = "Potrdi"
        //dialog.cancelButtonText = "Preklici";
	

        pna = new LineEdit;
        pna.label = "Prosim vnesite P.N.: ";
        dialog.add( pna );
        //dialog.add(box);
	
        num = new NumberEdit("Prosim vnesite količino: ", 1);
        num.decimals = 0;
        num.minimum = 1;
        num["sigNumberChanged(double)"].connect(onLneChange);
        num["sigOutOfRange()"].connect(onOutOfRange);
        dialog.add( num );
	//dialog.onOK.connect(readFile);
	//dialog.onCancel.connect(Close);
	
       selectedLogo = new Label(txt_selected_logo + "/"); 
       //selectedLogo.text = "";
       dialog.add(selectedLogo);
       
       var btn = PushButton ("ZAPIŠI!");
       btn["sigPressed()"].connect(readFile);
       dialog.add(btn);
      
       dialog.show();        
}

function Start()
{
                        //TODO
}

function Close()
{
                        //dialog.close();
}

function testMe()
{
    //print(this.main(val_pn));
    print(pna.text);
}

function onLneChange(text) {
  print("onLneChange("+text+")");
}

function onOutOfRange () {
  print("onOutOfRange()");
}

function readFile()
{  
    var nm = num.value;
    var pn = pna.text;
    //print( System.getCounterValue("num_writes") );
    //System.setCounterValue("num_writes", nm);
    //print( System.getCounterValue("num_writes"));
    //num_writes.value = nm;
    //print(num_writes);
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
	var res = hDb.exec("SELECT * FROM [List1$] WHERE PN LIKE '" + pn + "'");
	
	if (typeof res[0] == "object")
	{
	    var a = res[0][0];
	    var b = res[0][1];
	    var c = res[0][2];
	    var d = res[0][3];
	    var e = res[0][4];
	    var f = res[0][5];
	    var g = res[0][6];
	    var h = res[0][7];
	    var i = res[0][8];
	    var j = res[0][9];
	    var k = res[0][10];
	    var l = res[0][11];
	    var m = res[0][12];
	    
	    // Select the right template
	    h_Document = new LaserDoc;   
	   // h_Document.load("C:\\LASER_IMP\\Predloge\\" + l + ".XLP");
	    h_Document.load("D:\\LASER_IMP_SINEL\\IMP_SINEL.XLP");
		
	    print ("Read: " + a + ","+ b +"," + c +"," + d +"," + e +"," + f +"," + g +"," + h +"," + i +"," + j +"," + k +"," + l +"," + m);
	    writeLog("Read: " + a+ "," + b +"," + c +"," + d +"," + e +"," + f +"," + g +"," + h +"," + i +"," + j +"," + k +"," + l +"," + m);
	    
	   var obj_a = h_Document.getLaserObject("obj_a");
	   obj_a.text = a;
	   
	   var obj_b = h_Document.getLaserObject("obj_b");
	   obj_b.text = b;
	   
	   var obj_c = h_Document.getLaserObject("obj_c");
	   obj_c.text = c;
	   
	   var obj_d = h_Document.getLaserObject("obj_d");
	   obj_d.text =d;
	   
	   var obj_e = h_Document.getLaserObject("obj_e");
	   obj_e.text = e;
	   
	   var obj_f = h_Document.getLaserObject("obj_f");
	   obj_f.text = f;
	   
	   var obj_g = h_Document.getLaserObject("obj_g");
	   obj_g.text = g;
	   
	   var obj_h = h_Document.getLaserObject("obj_h");
	   obj_h.text = h;
	   
	   var obj_i = h_Document.getLaserObject("obj_i");
	   obj_i.text = i;
	   
	   var obj_j = h_Document.getLaserObject("obj_j");
	   obj_j.text = j;
	   
	   var obj_k = h_Document.getLaserObject("obj_k");
	   obj_k.text = k;
	   
	   //var obj_l = h_Document.getLaserObject("obj_l");
	   //obj_l.text = l;
	   var logo = h_Document.getLaserImported("logo");
	   //logo.importFile("D:\\LASER_IMP_SINEL\\Predloge\\" + l + ".xlp"); 
	   logo.importFile("F:\\LASER_IMP_SINEL\\Predloge\\" + l + ".xlp"); 
	   
	   selectedLogo.text = txt_selected_logo + l;
	   
	   var obj_m = h_Document.getLaserObject("obj_m");
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