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

function xls_log()
{

    var date2 = new Date();
    date2 = date2.ddmmyytime().toString();
   
    print(date2);
    hDb3 = new Db("QODBC")
    hDb3.dbName = "DRIVER={Microsoft Excel Driver (*.xls, *.xlsx, *.xlsm, *.xlsb)};HDR=yes;ReadOnly=0;Dbq=" + test_log;
    
    if (hDb3.open())
    {
        hDb3.exec("INSERT INTO [Napisne tablice in nalepke sezn$] (Izdelek) VALUES ('"+date2+"')");
        print( hDb3.lastError());
    }
    hDb3.close();
}

//xls_log();

function serial_input_changed(text)
{	
    columns_dict["M"] = text;
    lbl_ser.text = "Serial N.:" + text;
}

function ext_changed()

{
    show_preview();
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
        if(res[0] != null ){
            for( i = 0; i < dict_keys.length; i++)
            {
                columns_dict[dict_keys[i]] = res[0][i];
            }
        }
        if(columns_dict["M"] != "/")
        {
            le_ser.enable = true;
            columns_dict["M"] = le_ser.text;
        }
        else
        {
            le_ser.enable = false;
        }
        lbl_from_db.text = "Izdelek: " + columns_dict["A"];
        lbl_prev_man.text = "Izdelek: " + columns_dict["A"];

        laser_doc_preview();

    }
    hDb4.close();
}

/*-----------------------------------------------------------------------------------------------
  Template reading, laser document creation and execution function
  -----------------------------------------------------------------------------------------------*/
function mark_auto()
{	
    nm = 1;

    h_Doc_new.execute();
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
    
    h_Doc_new.move(8, 0);
    h_Doc_new.update();
    renderareaPrev.preview(h_Doc_new);
    renderareaPrev_m.preview(h_Doc_new);

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
