////////////////////////////////////////////////////////////
//Parts List creation from xls database
///////////////////////////////////////////////////////////
function parts_list()
{
    hDb3 = new Db("QODBC")
    hDb3.dbName = "DRIVER={Microsoft Excel Driver (*.xls, *.xlsx, *.xlsm, *.xlsb)};HDR=yes;ReadOnly=0;Dbq=" + nova_db;
    if(hDb3.open())
    {
        new_list = []; zdelekArr = [];
        zdelek_ext = []; logotips = [];
        var res = hDb3.exec("SELECT Izdelek FROM [Napisne tablice in nalepke sezn$] WHERE Izdelek is not null" );
        template_list = [];
        res.forEach(function(item, index)
        {
            if(res[index][0] != "")
            {
                new_list[index] = res[index][0].toString().slice(0, 9);
            }
        });
        new_list.sort();
        zdelekArr = remove_duplicates(new_list);
        dynamic_ext_list(0);
    }
    hDb3.close()
}

//////////////////////////////////////////////////////////////////////////////////////
//Creates list of templates and logos found in database
/////////////////////////////////////////////////////////////////////////////////////
function gen_lists_from_xls()
{
    hDb3 = new Db("QODBC")
    hDb3.dbName = "DRIVER={Microsoft Excel Driver (*.xls, *.xlsx, *.xlsm, *.xlsb)};HDR=yes;ReadOnly=0;Dbq=" + nova_db;
    if(hDb3.open())
    {
        template_list = [];
        logotips = [];

        var res1 = hDb3.exec("SELECT TEMPLATE FROM [Napisne tablice in nalepke sezn$] WHERE TEMPLATE is not null");
        var res2 = hDb3.exec("SELECT Logotip FROM [Napisne tablice in nalepke sezn$] WHERE Logotip is not null");

        res1.forEach(function(item,index)
        {
            if(res1[index][0] != "")
            {
                template_list.push(res1[index][0])
            }
        });
        template_list.sort();
        template_list_s = remove_duplicates(template_list);
        template_list_s = template_list_s.toString()

        res2.forEach(function(item,index)
        {
            if(res2[index][0] != "")
            {
                logotips.push(res2[index][0])
            }
        });
        logotips.sort();
        logotips_s = remove_duplicates(logotips);
        logotips_s = logotips_s.toString();

    }
    hDb3.close();
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

///////////////////////////////////
//DICTIONARIES 
//////////////////////////////////
function populateTemplateDict()
{
    templates_dict["CAL-G"] = templatesPath + "CALPEDA_GHN.xlp";
    templates_dict["CAL-N"] = templatesPath + "CALPEDA_NMT.xlp";
    templates_dict["EB-G"] = templatesPath + "EB_GHN.xlp";
    templates_dict["EB-N"] = templatesPath + "EB_NMT.xlp";
    templates_dict["EFA-G"] = templatesPath + "EFA_GHN.xlp";
    templates_dict["EFA-N"] = templatesPath + "EFA_NMT.xlp";
    templates_dict["ESP-G"] = templatesPath + "ESP_GHN.xlp";
    templates_dict["IMP-G"] = templatesPath + "IMP_GHN.xlp";
    templates_dict["IMP-GS"] = templatesPath + "IMP_GHNSOL.xlp";
    templates_dict["IMP_N"] = templatesPath + "IMP_NMT.xlp";
    templates_dict["LAD_G"] = templatesPath + "LAD_GHN.xlp";
    templates_dict["LAD-N"] = templatesPath + "LAD_NMT.xlp";
    templates_dict["MAT-G"] = templatesPath + "MATRA_GHN.xlp";
    templates_dict["PER-G"] = templatesPath + "PER_GHN.xlp";
    templates_dict["PER-N"] = templatesPath + "PER_NMT.xlp";
    templates_dict["STA-G"] = templatesPath + "STA_GHN.xlp";
}

function populateLogosDict()
{
    logotips_dict["ADL"] = logosPath + "ADL.xlp";
    logotips_dict["AN"] = logosPath + "ANAVALOS.xlp";
    logotips_dict["AP"] = logosPath + "APPEL.xlp";
    logotips_dict["BE"] = logosPath + "BOMBA ELIAS.xlp";
    logotips_dict["CAL"] = logosPath + "CALPEDA.xlp";
    logotips_dict["COOX"] = logosPath + "COOX.xlp";
    logotips_dict["EBARA"] = logosPath + "EBARA.xlp";
    logotips_dict["EFA"] = logosPath + "EFAFLU.xlp";
    logotips_dict["ESP"] = logosPath + "ESPA.xlp";
    logotips_dict["IDR"] = logosPath + "IDROELETTRICA.xlp";
    logotips_dict["IMP"] = logosPath + "IMP LOGO.xlp";
    logotips_dict["LAD"] = logosPath + "LADDOMAT_NMT.xlp";
    logotips_dict["MAT"] = logosPath + "MATRA.xlp";
    logotips_dict["MH"] = logosPath + "MOBIHEAT.xlp";
    logotips_dict["PER"] = logosPath + "PER.xlp";
    logotips_dict["SEA"] = logosPath + "SEA_NMT.xlp";
    logotips_dict["SEN"] = logosPath + "SENERTEC.xlp";
    logotips_dict["SPE"] = logosPath + "SPERONI.xlp";
    logotips_dict["STA"] = logosPath + "STA.xlp";
}

function populateZnakiDict()
{
    znaki_dict["CCC-1"] = znakiPath + "CCC.xlp"
    znaki_dict["CE-1"] = znakiPath + "CE.xlp";
    znaki_dict["EAC-1"] = znakiPath + "EAC.xlp";
    //znaki_dict["GOST-1"] = znakiPath + "CCC.xpl";
    //znaki_dict["GOST-0"] = znakiPath + "CCC.xpl";
    znaki_dict["puščica-1"] = znakiPath + "STRELCA.xlp";
    znaki_dict["ucraino1"] = znakiPath + "ucraino_ebara.xlp";
}

/////////////////////////////////////////////
//Serial number LABEL update
////////////////////////////////////////////
function serial_input_changed(text)
{	
    lbl_ser.text = "Serial N.:" + text;
}

var sel_init = 0;
var current_selection;
var last_selection = "";

function ext_changed()
{
    if(auto_mode == "OFF")
    {	    
            le_ser.text = "none";
            current_selection = cmb_template.currentItem; 
	if(current_selection != last_selection)
	{	
		//print("init");
		selection_init();
	}
        last_selection = current_selection;	
    }
}

///////////////////////////////
//Serial number init
//////////////////////////////
function init_sn()
{
    if((columns_dict["M"]  == "ebara") || (ebara_reg.test(columns_dict["M"])))
    {
        var  ebara_pre = get_ebara_prefix();
        last_serial= ebara_pre + "000001";
    }
    else
    {
        year = new Date();
        year =  year.getFullYear().toString().slice(2);
        last_serial =  year + "-" + "000001";
    }
    return last_serial;
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
            last_serial = init_sn();
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
    var snArr_i = [];
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
    
    print(snArr);
    snArr.forEach(function(item, index)
    {
        snArr_i[index] = snArr[index].toString().slice(3);
        snArr_i[index] = parseInt(snArr_i[index]);
    });
    
    if (snArr_i.indexOf(sn) >= 0)
    {
        return true;
    }
    else
    {
        return false;
    }
}

/////////////////////////////////////
//Serial number update
////////////////////////////////////
function update_sn()
{
    if((columns_dict["M"]  == "ebara") || (ebara_reg.test(columns_dict["M"])))
    {
        ebara_pre = get_ebara_prefix();
        le_ser.text = ebara_pre + last_sn;
    }
    else
    {
        le_ser.text = date_year + "-" + last_sn;
    }
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
            le_ser.enable = true;
            last_sn = get_last_serial().toString();
            if(debug_mode){print("columns dict m "+ columns_dict["M"] );}
	    
            last_sn = get_serial_int(last_sn);
            if(last_sn == 1)
            {
                last_sn = leftPad((last_sn),6);
            }
            else
            {
                last_sn = leftPad((last_sn + 1),6);
            }
            update_sn();
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
  //  sel_init = 1;
}

///////////////////////////////
//Confirms selection
//////////////////////////////
function confirm_selection()
{   
    if(auto_mode == "OFF")
    {
        confirm = 0;
  //      sel_init = 0;
        if(columns_dict["M"] != "/" && columns_dict["M"] != '' )
        {
            last_sn = get_last_serial().toString();
            sn_update_times = columns_dict["I"];
            last_sn = get_serial_int(last_sn);

            if(last_sn != 1)
            {
                last_sn = last_sn + 1;
                last_sn = leftPad((last_sn), 6);
            }
            else
            {
                last_sn = leftPad((last_sn),6);
            }
            le_sn = le_ser.text;

            if(check_sn_format_imp(le_sn))
            {
                le_sn = get_serial_int(le_sn)
                curr_sn = le_sn;
                le_sn = leftPad((le_sn),6);
                ///////////////////////////////////////////////
                //Check if serial already exist
                /////////////////////////////////////////////
                if(!enable_existing_sn_marking)
                {
                    if(check_sn(curr_sn))
                    {
                        error_sn_exists();
                        confirm = 0;
                    }
                    else
                    {
                        columns_dict["M"] = le_ser.text;
                        confirm = 1;
                    }
                }
                else
                {
                    columns_dict["M"] = le_ser.text;
                    confirm = 1;
                }
            }
            else
            {
                error_sn_false_format();
            }

            le_ser.enable = true;
        }
        else
        {
            le_ser.text = "none";
            le_ser.enable = false;
            confirm = 1;
        }
        sn_marking_times = parseInt(columns_dict["H"]);
        numW = le_num_w.text;
        get_quantity();
	/*if(num_w_reg.test(numW))
	{
		numW = parseInt(numW);
		if(isNaN(numW)){numW=0;}
	}
	else
	{
		error_wrong_quantity_format();
	}
        */
        if(debug_mode){print("genereting laser doc");}
        laser_doc_generate();
    }
    else
    {
        error_auto_started();
    }
}

function get_quantity()
{
        numW = le_num_w.text;
	numW = parseInt(numW);
	if(num_w_reg.test(numW))
	{
		numW = parseInt(numW);
		if(isNaN(numW)){numW=0;}
	}
	else if(typeof(numW == NaN))
	{
		numW = 0;
	}      	
	else 
	{
		error_wrong_quantity_format();
	}
}

//////////////////////////////////////////////////////
//Laser objects updates
//////////////////////////////////////////////////////
function laser_objects_update()
{
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
}
//////////////////////////////////////////////////////
//Laser doc generation
//////////////////////////////////////////////////////
function laser_doc_generate()
{
    h_Doc_new = new LaserDoc;
    var template_file = templates_dict[columns_dict["G"]];
    //var template_file = templatesPath + columns_dict["G"] + ".xlp";
    //print(template_file);
    dict_keys = Object.keys(columns_dict);
    
    if(template_file != "init_value")
    {
        h_Doc_new.load(template_file);
        
        laser_objects_update();
        ////////////////////////////////
        //Sets MONTH/YEAR
        ////////////////////////////////
        if(columns_dict["AH"] == "mm/yy")
        {
            var obj = h_Doc_new.getLaserObject("OBJ_AH");
            if(obj != null)
            {
                var date = new Date();
                columns_dict["AH"] = date.mmyy();
                obj.text = date.mmyy();
            }
        }
         h_preview = h_Doc_new;
         h_preview.move(7.0,0.5);	 
         renderareaPrev.preview(h_preview);
         renderareaPrev_m.preview(h_preview); 
         
         rotate_and_move();
         h_Doc_new.update();
    }
    else
    {
        error_template_missing();
    }
}

function rotate_and_move()
{
    /////////////////////////////////
    //Rotation switch
    /////////////////////////////////
    kut = parseInt(columns_dict["F"]);
    
    switch(kut)
    {
    case 0:
        h_Doc_new.rotate(0-90);
        break;
    case 90:
        h_Doc_new.rotate(90-90);
        break;
    case 180:
        h_Doc_new.rotate(180-90);
        break;
    case 270:
        h_Doc_new.rotate(270-90); 
        break;
    case 360:
        h_Doc_new.rotate(360-90);
    break;
    default:
        h_Doc_new.rotate(0-90);	      
    }
       ///////////////////////////////////////////////
       //Korekcija koordinate lasera
       ///////////////////////////////////////////////
       h_Doc_new.move(7.0, -1.5);   
}

/////////////////////////////////////
//Laser doc update
////////////////////////////////////
function laser_doc_update()
{
    if(columns_dict["M"] != "/" && columns_dict["M"] != '' )
    {
        last_sn = curr_sn;
        last_sn = leftPad((last_sn),6);

        update_sn();
        columns_dict["M"] = le_ser.text;
	
        laser_objects_update(); 
        
         h_preview.rotate(-90);
         h_preview.update();
  
        //renderareaPrev.preview(h_preview);
        //renderareaPrev_m.preview(h_preview); 
        rotate_and_move();
        h_Doc_new.update();
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
    //h_Doc_new.sigEndMark.connect(marking_ended);
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
    if(debug_mode){print(query1);}
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

function writeLog(currentNum)
{
    var today = new Date();
    if(debug_mode){print("Writing to log:" + currentNum);}
    var outFile = new File(logPath);
    outFile.open(File.Append);
    outFile.write("\r\n" + today.toLocaleString() + " - " + currentNum);
    outFile.close();
}
