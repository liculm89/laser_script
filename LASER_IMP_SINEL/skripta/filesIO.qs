/*---------------------------------
 Template and log file paths
  ----------------------------------*/
drive_loc = "D:"

var tmplPath = drive_loc + "\\LASER_IMP_SINEL\\IMP_SINEL.XLP";
var xlsPath = drive_loc + "\\LASER_IMP_SINEL\\TabelaNMTPLUS.xlsx";
var logoPath =drive_loc + "\\LASER_IMP_SINEL\\Predloge\\" ;
var logPath= drive_loc + "\\LASER_IMP_SINEL\\writeLog.txt";
var resPath = drive_loc + "\\LASER_IMP_SINEL\\res\\";

var h_Document,hDb, fw;
var part_list, logos_list = [];
var txt_selected_logo = "Izbran logo: ";
var txt_num_writes = "Število zapisov (od zagona): ";

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
        logos_list = [];
        var res = hDb2.exec("SELECT * FROM [List1$]" );
        for (i = 0; i < res.length; i++)
        {
            part_list[i] = res[i][0];
            logos_list[i] = res[i][11];
        }
    }
    else
    {
        if(debug_mode){ print("Result: " + res + " - Error: " + hDb2.lastError());}
        writeLog("Result: " + res + " - Error: " + hDb2.lastError());
    }
    hDb2.close();
}

/*-----------------------------------------------------------------------------------------------
  Template reading, laser document creation and execution function
  -----------------------------------------------------------------------------------------------*/
function readFile()
{  
    print("reading and generating");
    nm = 1;
    
    if(auto_mode == "ON")
    {
        var pn = cmb_a.currentItem;
    }
    else
    {
        var pn = cmb.currentItem;
    }
    
    if(pn != "" )
    {
        print("Selected P.N.: " + pn );
        //print("Number of copies.: " + nm );
        writeLog("Selected P.N.:" + pn);
        hDb = new Db("QODBC");
        hDb.dbName = "DRIVER={Microsoft Excel Driver (*.xls, *.xlsx, *.xlsm, *.xlsb)};HDR=yes;Dbq=" + xlsPath;

        if(hDb.open())
        {
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

                if(debug_mode){print("Read:" + objects);}
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
    if(debug_mode){print("Writing to log:" + currentNum);}
    var outFile = new File(logPath);
    outFile.open(File.Append);
    outFile.write("\r\n" + today.toLocaleString() + " - " + currentNum);
    outFile.close();
}