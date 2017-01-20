/*---------------------------------
 Template and log file paths,
  ----------------------------------*/

var tmplPath ="G:\\LASER_IMP_SINEL\\IMP_SINEL.XLP";
var xlsPath ="G:\\LASER_IMP_SINEL\\TabelaNMTPLUS.xlsx";
var logoPath ="G:\\LASER_IMP_SINEL\\Predloge\\" ;
var logPath= "G:\\LASER_IMP_SINEL\\writeLog.txt";

/*
var tmplPath ="D:\\LASER_IMP_SINEL\\IMP_SINEL.XLP";
var xlsPath ="D:\\LASER_IMP_SINEL\\TabelaNMTPLUS.xlsx";
var logoPath ="D:\\LASER_IMP_SINEL\\Predloge\\" ;
var logPath= "D:\\LASER_IMP_SINEL\\writeLog.txt";
*/

var h_Document,hDb, fw;
var part_list, logos_list = [];
var txt_selected_logo = "Izbran logo: ";
var txt_num_writes = "Število zapisov (od zagona): ";

/*-----------------------------------------------------------------------------------------------
  Template reading, laser document creation and execution function
  -----------------------------------------------------------------------------------------------*/
function readFile()
{  
    print("reading and generating");
    //var nm = num.value;
    nm = 1;
    
    if(auto_mode == "ON")
    {
	var pn = cmb_a.currentItem;
    }
    else
    {
	var pn = cmb.currentItem;
    }
    
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

                var l = objects[(objects.length - 2)];
                var m = objects[(objects.length - 1)];
                var logo = h_Document.getLaserImported("logo");

                logo.importFile(logoPath + l + ".xlp");
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
            //print("Result: " + res + " - Error: " + hDb.lastError());
            writeLog("Result: " + res + " - Error: " + hDb.lastError());
        }
    }        hDb.close();
}


//Log creating/appending function
function writeLog(currentNum)
{
    var today = new Date();
    //print("Writing to log:" + currentNum);
    var outFile = new File(logPath);
    outFile.open(File.Append);
    outFile.write( "\r\n" + today.toLocaleString() + " - " + currentNum );
    outFile.close();
}