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

        res.forEach(function(item, index)
        {
            part_list[index] = res[index][0];
            logos_list[index] = res[index][11];
        })
    }
    else
    {
        if(debug_mode){ print("Result: " + res + " - Error: " + hDb2.lastError());}
        writeLog("Result: " + res + " - Error: " + hDb2.lastError());
    }
    hDb2.close();

}

function new_parts_list()
{
    hDb3 = new Db("QODBC")
    hDb3.dbName = "DRIVER={Microsoft Excel Driver (*.xls, *.xlsx, *.xlsm, *.xlsb)};HDR=yes;Dbq=" + nova_db;

    if(hDb3.open())
    {
        zdelek_ext = [];
        new_list = [];
        var logotips = [];

        var res = hDb3.exec("SELECT Izdelek FROM [Napisne tablice in nalepke sezn$] WHERE Izdelek is not null" );
        var res2 = hDb3.exec("SELECT TEMPLATE FROM [Napisne tablice in nalepke sezn$] WHERE TEMPLATE is not null" );
        var res3 = hDb3.exec("SELECT Logotip FROM [Napisne tablice in nalepke sezn$] WHERE Logotip is not null")

        template_list = [];
        res.forEach(function(item, index)
        {
            if(res[index][0] != "")
            {
                new_list[index] = res[index][0].toString().slice(0, 9);
            }
        });

        if(debug_mode){
        res2.forEach(function(item,index)
        {
            if(res2[index][0] != "")
            {
                template_list.push(res2[index][0])
            }
        });

        res3.forEach(function(item,index)
        {
            if(res3[index][0] != "")
            {
                logotips.push(res3[index][0])
            }
         });
        }
        template_list.sort();
        template_list_s = remove_duplicates(template_list);
        
        logotips.sort();
        var logotips_s;
        
        logotips_s = remove_duplicates(logotips);
        
        new_list.sort();
        newarr = remove_duplicates(new_list);

        dynamic_template_list(0);
    }
    hDb3.close()
}

function dynamic_template_list(part_id)
{
    hDb4 = new Db("QODBC")
    hDb4.dbName = "DRIVER={Microsoft Excel Driver (*.xls, *.xlsx, *.xlsm, *.xlsb)};HDR=yes;Dbq=" + nova_db;

    if(hDb4.open())
    {
        var res2 = hDb4.exec("SELECT Izdelek FROM [Napisne tablice in nalepke sezn$] WHERE Izdelek LIKE '" + newarr[part_id] +"%'");

        zdelek_ext_s = [];
        res2.forEach(function(item, index)
        {
            if(res2[index][0] != "")
            {
                zdelek_ext_s[index] = res2[index][0].toString().slice(9);
                if(zdelek_ext_s[index] == "")
                {
                    zdelek_ext_s[index] = "      ";
                }
            }
        })

        zdelek_ext_s.sort();
        zdelek_ext_s = remove_duplicates(zdelek_ext_s);
        cmb_template.itemList = zdelek_ext_s;
    }
    hDb4.close();
}

function read_from_db()
{
    hDb5 = new Db("QODBC")
    hDb5.dbName = "DRIVER={Microsoft Excel Driver (*.xls, *.xlsx, *.xlsm, *.xlsb)};HDR=yes;Dbq=" + nova_db;

    if(hDb4.open())
    {

    }
    hDb5.close();

}

function show_preview()
{
    hDb4 = new Db("QODBC")
    hDb4.dbName = "DRIVER={Microsoft Excel Driver (*.xls, *.xlsx, *.xlsm, *.xlsb)};HDR=yes;Dbq=" + nova_db;
    var part = cmb_new.currentItem;
    var ext = cmb_template.currentItem;
    if (cmb_template.currentItem == "      ")
    {
        ext = "";
    }

    dict_keys = Object.keys(columns_dict);
    
    if(hDb4.open())
    {
        var  res = hDb4.exec("SELECT * FROM [Napisne tablice in nalepke sezn$] WHERE Izdelek LIKE '" + part + ext +"'");
        for( i = 0; i < dict_keys.length; i++)
        {
	print(dict_keys[i]);
            columns_dict[dict_keys[i]] = res[0][i];
	print(columns_dict[dict_keys[i]]);
        }

        lbl_from_db.text = columns_dict["A"];
        laser_doc_preview();
    }
    hDb4.close();
}
/*-----------------------------------------------------------------------------------------------
  Template reading, laser document creation and execution function
  -----------------------------------------------------------------------------------------------*/
function readFile()
{
    nm = 1;
    pn = get_pn();

    if(debug_mode){print("Reading and executing");}
    laser_doc_update(pn);
    h_Document.execute();
}

function get_pn()
{
    var pn;
    if(auto_mode == 1)
    {
        pn = cmb_a.currentItem;
    }
    else
    {
        pn = cmb.currentItem;
    }
}

function generate_laser_doc(auto, init)
{
    nm = 1;
    if(init == 0)
    {
        pn = get_pn();
    }
    else
    {
        pn = part_list[0];
    }
    if(debug_mode){print("Reading and creating preview");}
    laser_doc_update(pn);
   // renderarea.preview(h_Document);
}

function laser_doc_preview()
{
    h_Doc_new = new LaserDoc;
    var file_loc = templates_dict[columns_dict["G"]];
   
    dict_keys = Object.keys(columns_dict);
    h_Doc_new.load(file_loc);
    
    dict_keys_J_N =  dict_keys.slice(dict_keys.indexOf("J"), dict_keys.indexOf("N")+1);
    dict_keys_O_T = dict_keys.slice(dict_keys.indexOf("O"), dict_keys.indexOf("T")+1);
    dict_keys_U_AH = dict_keys.slice(dict_keys.indexOf("U"), dict_keys.indexOf("AH")+1);
    
    
      for( i = 0; i < ( laser_objects_J_N.length) ; i++)
    {
        var obj =  h_Doc_new.getLaserObject(laser_objects_J_N[i]);
        if( obj != null)
        {
	if(columns_dict[dict_keys_J_N[i]] != "/")
	{
	    obj.text = columns_dict[dict_keys_J_N[i]];
	}
        }
    }
    
      for( i = 0; i < ( laser_objects_O_T.length) ; i++)
    {
        var obj =  h_Doc_new.getLaserImported(laser_objects_O_T[i]);
        if( obj != null)
        {
	if(columns_dict[dict_keys_O_T[i]] != "/")
	{
	    print("Importing file..." + znaki_dict[ columns_dict[dict_keys_O_T[i]]]);
	    obj.importFile(znaki_dict[ columns_dict[dict_keys_O_T[i]]]);
	}
        }
    }   
     
    for( i = 0; i < ( laser_objects_U_AH.length) ; i++)
    {
        var obj =  h_Doc_new.getLaserObject(laser_objects_U_AH[i]);
        if( obj != null)
        {
	if(columns_dict[dict_keys_U_AH[i]] != "/")
	{
	    obj.text = columns_dict[dict_keys_U_AH[i]];
	}
        }
    }
    
    if(columns_dict["AH"] == "mm/yy")
    {    
	var obj = h_Doc_new.getLaserObject("OBJ_AH");
            if( obj != null)
	{
	var date = new Date();
            obj.text = date.mmyy();
	}
    }
    
    h_Doc_new.update();
    renderareaPrev.preview(h_Doc_new);
}

function laser_doc_update(pn)
{
    if(pn != "" )
    {
        print("Selected P.N.: " + pn );
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

                h_Document.update();
            }
        }
        else
        {
            if(debug_mode){print("Result: " + res + " - Error: " + hDb.lastError());}
            writeLog("Result: " + res + " - Error: " + hDb.lastError());
        }
    }
    hDb.close();
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
