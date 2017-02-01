////////////////////////////////////////////////////////////
//Parts List creation from xls database
///////////////////////////////////////////////////////////
function parts_list()
{
    hDb3 = new Db("QODBC")
    hDb3.dbName = "DRIVER={Microsoft Excel Driver (*.xls, *.xlsx, *.xlsm, *.xlsb)};HDR=yes;ReadOnly=0;Dbq=" + nova_db;
    if(hDb3.open())
    {
        new_list = [];
        zdelekArr = [];
        zdelek_ext = [];
        logotips = [];

        var res = hDb3.exec("SELECT Izdelek FROM [Napisne tablice in nalepke sezn$] WHERE Izdelek is not null" );
        var res2 = hDb3.exec("SELECT TEMPLATE FROM [Napisne tablice in nalepke sezn$] WHERE TEMPLATE is not null" );
        var res3 = hDb3.exec("SELECT Logotip FROM [Napisne tablice in nalepke sezn$] WHERE Logotip is not null");

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
        zdelekArr = remove_duplicates(new_list);

        dynamic_ext_list(0);
    }
    hDb3.close()
}

/////////////////////////////////////////////////////////////////////
//Creating part extensions from xls database
/////////////////////////////////////////////////////////////////////
function dynamic_ext_list(part_id)
{
    hDb4 = new Db("QODBC")
    hDb4.dbName = "DRIVER={Microsoft Excel Driver (*.xls, *.xlsx, *.xlsm, *.xlsb)};HDR=yes;Dbq=" + nova_db;

    if(hDb4.open())
    {
        var res2 = hDb4.exec("SELECT Izdelek FROM [Napisne tablice in nalepke sezn$] WHERE Izdelek LIKE '" +  zdelekArr[part_id] +"%'");

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


function serial_input_changed(text)
{	
    lbl_ser.text = "Serial N.:" + text;
}

////////////////////////////////////////
//
////////////////////////////////////////
function ext_changed()
{
    if(auto_mode == "OFF")
    {
        le_ser.text = "none";
        le_ser.enable = true;
        selection_init();
    }
}

///////////////////////////////////////////////////
//Gets the last serial from log file
//////////////////////////////////////////////////
function get_last_serial()
{
    var part = cmb_new.currentItem;
    var ext = cmb_template.currentItem;  

    hDb4 = new Db("QODBC")
    hDb4.dbName = "DRIVER={Microsoft Excel Driver (*.xls, *.xlsx, *.xlsm, *.xlsb)};HDR=yes;Dbq=" + test_log;
    
    if(ext == "      ")
    {
	var query_se = "SELECT [S N] FROM [Napisne tablice in nalepke sezn$] WHERE Izdelek LIKE '" + part  +"'";
    }
    else
    {
	var query_se = "SELECT [S N] FROM [Napisne tablice in nalepke sezn$] WHERE Izdelek LIKE '" + part + ext +"'";
    }
    
    var snArr = [];

    if(hDb4.open())
    {
        var res = hDb4.exec(query_se);
 
        if(res.length != 0)
        {
            res.forEach(function(item, index)
            {
                if(res[index][0] != "")
                {
                    snArr.push(res[index][0]);
                }
            });
            snArr.sort();
	    
            if(res[0] != null)
            {
                var last_serial = snArr[snArr.length - 1];
            }
        }
        else
        {
            last_serial = "17-000001";
        }
    }
    hDb4.close();

    return last_serial;
}

//////////////////////////////////
//Serial number check
//////////////////////////////////
function check_sn(sn)
{
    
    var part = cmb_new.currentItem;
    var ext = cmb_template.currentItem;  
    
    hDb4 = new Db("QODBC");
    hDb4.dbName = "DRIVER={Microsoft Excel Driver (*.xls, *.xlsx, *.xlsm, *.xlsb)};HDR=yes;Dbq=" + test_log;
    
    if(ext == "      ")
    {
	var query_se = "SELECT [S N] FROM [Napisne tablice in nalepke sezn$] WHERE Izdelek LIKE '" + part  +"'";
    }
    else
    {
	var query_se = "SELECT [S N] FROM [Napisne tablice in nalepke sezn$] WHERE Izdelek LIKE '" + part + ext +"'";
    }
    
    var snArr = [];

    if(hDb4.open())
    {
        var res = hDb4.exec(query_se);
 
        if(res.length != 0)
        {
            res.forEach(function(item, index)
            {
                if(res[index][0] != "")
                {
                    snArr.push(res[index][0]);
                }
            });
	}
    }
    hDb4.close();
    /*
    print(snArr);
    print(sn);
    //var test = !!(snArr.includes(sn)+1);
    var test;
    
      for(var i = 0; i < snArr.length; i++) 
      {
	  print(snArr[i]);
	  print(sn);
	  if(snArr[i] == sn)
	  {
	      
	  }
      }
    print(test);
    */
}


/////////////////////////////////////////
//Initial values generation
///////////////////////////////////////
function selection_init()
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
        log_arr = [];
        if(res[0] != null ){
            for( i = 0; i < dict_keys.length; i++)
            {
                columns_dict[dict_keys[i]] = res[0][i];
            }
        }

        if(columns_dict["M"] != "/" && columns_dict["M"] != '' )
        {
            last_sn = get_last_serial().toString();
            last_sn = last_sn.slice(3);
            last_sn = parseInt(last_sn);
	    
            if(last_sn == 1)
            {
                last_sn = leftPad((last_sn), 7);
            }
            else
            {
                last_sn = leftPad((last_sn + 1), 7);
            }
            le_ser.text = date_year + "-" + last_sn;
            le_ser.enable = true;
        }
        else
        {
            le_ser.text = "none";
            le_ser.enable = false;
        }
        lbl_from_db.text = "Izdelek: " + columns_dict["A"];
        lbl_prev_man.text = "Izdelek: " + columns_dict["A"];
        laser_doc_generate();
    }
    hDb4.close();
}

///////////////////////////////
//Confirms selection
//////////////////////////////
function confirm_selection()
{
    if(auto_mode == "OFF")
    {
        if(columns_dict["M"] != "/" && columns_dict["M"] != '' )
        {
            last_sn = get_last_serial().toString();
            last_sn = last_sn.slice(3);
            last_sn = parseInt(last_sn);

            if(last_sn != 1)
            {
                last_sn = last_sn + 1;
                last_sn = leftPad((last_sn), 7);
            }
            else
            {
                last_sn = leftPad((last_sn), 7);
            }
	    
	check_sn(le_ser.text);
            
	le_sn = le_ser.text;    
            le_sn_i = le_sn.slice(3);
            le_sn_i = parseInt(le_sn_i);
            le_sn_i = leftPad((le_sn_i),7);

            if(le_sn_i >= (last_sn))
            {
                columns_dict["M"] = le_ser.text;
            }
            else if(le_sn_i == 000001)
            {
                columns_dict["M"] = le_ser.text;
            }
            else
            {
                error_sn_exists();
            }
            le_ser.enable = true;
        }
        else
        {
            le_ser.text = "none";
            le_ser.enable = false;
        }
        numW = le_num_w.text;
        numW = parseInt(numW);
	if(isNaN(numW)){numW=0;}
      print("from confirm .. numW: " + numW);  
	laser_doc_generate();
    }
    else
    {
        error_auto_started();
    }
}

//////////////////////////////////////////////////////
//Laser doc generation
//////////////////////////////////////////////////////
function laser_doc_generate()
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
    if(columns_dict["F"] == "0")
    {
	 h_Doc_new.move(7, 0);
             h_Doc_new.update();
    }
    else if(columns_dict["F"] == "270")
    {	
	h_Doc_new.rotate(270);
	h_Doc_new.move(7, 0);
            h_Doc_new.update();
    }
    renderareaPrev.preview(h_Doc_new);
    renderareaPrev_m.preview(h_Doc_new);
}

/////////////////////////////////////
//Laser doc update
////////////////////////////////////
function laser_doc_update()
{
    if(columns_dict["M"] != "/" && columns_dict["M"] != '' )
    {
        last_sn = get_last_serial().toString();
        last_sn = last_sn.slice(3);
        last_sn = parseInt(last_sn);
	
        curr_sn = last_sn + 1;
        curr_sn =  leftPad((curr_sn), 7);
	
        le_ser.text = date_year + "-" + curr_sn;
        columns_dict["M"] = le_ser.text;
        laser_doc_generate();
    }
}

////////////////////////////////////////
//Laser doc execution
///////////////////////////////////////
function mark_auto()
{	
    nm = 1;
    laser_doc_update();
    log_arr = [];
    for( i = 0; i < dict_keys.length; i++)
    {
        log_arr.push(columns_dict[dict_keys[i]]);
    }
    h_Doc_new.execute();
}


///////////////////////////////////////////////
//Logging into xls database
//////////////////////////////////////////////
function xls_log()
{
    var date2 = new Date();
    date2 = date2.ddmmyytime().toString();
    
    log_arr.splice(-2,2);
    var colNamesStr = "[" + columns_names.join("],[") +"]";
    
    log_str = "'" + log_arr.join("','") + "'";
    log_str = "'" + date2 + "'," + log_str;
    colNamesStr  = "Time_date," + colNamesStr;
    
    var query1  = "INSERT INTO [Napisne tablice in nalepke sezn$] ("+colNamesStr+") VALUES ("+log_str+")";

    hDb3 = new Db("QODBC")
    hDb3.dbName = "DRIVER={Microsoft Excel Driver (*.xls, *.xlsx, *.xlsm, *.xlsb)};HDR=yes;ReadOnly=0;Dbq=" + test_log;
    
    if (hDb3.open())
    {
        if(!hDb3.exec(query1))
        {
            print(hDb3.lastError());
        }
    }
    hDb3.close();
}

function leftPad(number, targetLength)
{
    var output = number + ' ';
    while(output.length < targetLength) {
        output = '0' + output;
    }
    return output;
}

function writeLog(currentNum)
{
    var today = new Date();
    if(debug_mode){print("Writing to log:" + currentNum);}
    var outFile = new File(logPath);
    outFile.open(File.Append);
    outFile.write("\r\n" + today.toLocaleString() + " - " + currentNum);
    outFile.close();
}
