/*---------------------------------
 Template and log file paths
  ----------------------------------*/
/*TEMPLATES
  /,ADL-G,AN-G,BE-G,CAL-G,CAL-N,DEL-G,DEL-GS,DUP-G,EB-G,EB-N,EFA-G,EFA-N,EMS-G,ESP-G,EXP-G,EXP-N,GHN-G,GS-G,
GUT-G,IMP-G,IMP-GS,IMP-N,INT-G,KIR-N,LAD-G,LAD-N,MAT-G,MIL-G,PER-G,PER-N,SLD-G,SOM-G,SOME-N,
SOML-N,SPE-G,STA-G,UNI-G

LOGOS
  ADL,AN,AP,BE,CAL,COOX,DEL,DUP,EB,EBARA,EFA,EMS,ENRJ,ESP,EXP,GS,GUT,IDR,IMP,INT,
KIR,LAD,LATITUDE,MAT,MH,MI,PER,PL,SAE,SEA,SEN,SLD,SOM,SPE,ST,STA,TC5,UNI,VEX,calpeda1
*/

var date = new Date();
print(date.mmyy());


//drive_loc = "G:";
//drive_loc = "D:";
drive_loc = "E:";

var tmplPath = drive_loc + "\\LASER_IMP_SINEL\\IMP_SINEL.XLP";
var xlsPath = drive_loc + "\\LASER_IMP_SINEL\\TabelaNMTPLUS.xlsx";
var logoPath = drive_loc + "\\LASER_IMP_SINEL\\Predloge\\" ;
var logPath= drive_loc + "\\LASER_IMP_SINEL\\writeLog.txt";
var resPath = drive_loc + "\\LASER_IMP_SINEL\\res\\";
var nova_db =  drive_loc + "\\LASER_IMP_SINEL\\tabela_baza2.xls";

var templates_a = "/,ADL-G,AN-G,BE-G,CAL-G,CAL-N,DEL-G,DEL-GS,DUP-G,EB-G,EB-N,EFA-G,EFA-N,EMS-G,ESP-G,EXP-G,EXP-N,GHN-G,GS-G,GUT-G,IMP-G,IMP-GS,IMP-N,INT-G,KIR-N,LAD-G,LAD-N,MAT-G,MIL-G,PER-G,PER-N,SLD-G,SOM-G,SOME-N,SOML-N,SPE-G,STA-G,UNI-G";

var logotips_a = "ADL,AN,AP,BE,CAL,COOX,DEL,DUP,EB,EBARA,EFA,EMS,ENRJ,ESP,EXP,GS,GUT,IDR,IMP,INT,KIR,LAD,LATITUDE,MAT,MH,MI,PER,PL,SAE,SEA,SEN,SLD,SOM,SPE,ST,STA,TC5,UNI,VEX,calpeda1";

var znaki_a = "CCC-1,CE-1,EAC-1,GOST-0,GOST-1,puščica-1,ucraino1"

var templatesPath = drive_loc + "\\LASER_IMP_SINEL\\TEMPLATE\\";
var logosPath = drive_loc + "\\LASER_IMP_SINEL\\LOGOTIP\\XLP-LOGOTIPI\\";
var znakiPath = drive_loc + "\\LASER_IMP_SINEL\\ZNAKI\\XLP - ZNAKI\\";

var columns = "A B C D E F G H I J K L M N O P Q R S T U V W Z Y AA AB AC AD AE AF AG AH AI AJ";

var h_Doc_new;
var h_Document,hDb, fw;
var laser_objects = [];

var part_list = []; 
var logos_list = [];
var new_list = [];
var newarr = [];
var zdelek_ext = [];
var zdelek_ext_s = [];
var template_list = [];
var template_list_s = [];
var columns_arr = [];

var txt_selected_logo = "Selected logo: ";

function to_dict(from_str, c1, c2, split)
{
    arr = from_str;
    arr = arr.split(split);
    arr_s = arr.slice(arr.indexOf(c1), arr.indexOf(c2) + 1);
    var dict = {};
    arr_s.forEach(function(item)
    {
        dict[item] = "init_value";
    })
    return dict;
}

function to_arr(from_str, c1, c2)
{
    var arr;
    arr = from_str;
    arr = arr.split(" ");
    var arr_s;
    arr_s = arr.slice(arr.indexOf(c1), arr.indexOf(c2) + 1);
    return arr_s;
}

var templates_dict = {};
var logotips_dict = {};
var columns_dict = {};
var znaki_dict = {};

templates_dict = to_dict(templates_a, "/", "UNI-G", ",");
logotips_dict = to_dict(logotips_a, "ADL","calpeda1",",");

columns_dict = to_dict(columns, "A", "AJ", " ");
columns_arr = to_arr(columns, "A", "AJ", " ");

znaki_dict = to_dict(znaki_a, "CCC-1","ucraino1", ",");


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
    znaki_dict["CCC-1"] = znakiPath + "CCC.xpl";
    znaki_dict["CE-1"] = znakiPath + "CE.xpl";
    znaki_dict["EAC-1"] = znakiPath + "EAC.xpl";
    //znaki_dict["GOST-1"] = znakiPath + "CCC.xpl";
    //znaki_dict["GOST-0"] = znakiPath + "CCC.xpl";
    znaki_dict["puščica-1"] = znakiPath + "STRELCA.xpl";
    znaki_dict["ucraino1"] = znakiPath + "ucraino_ebara.xpl";
}

populateTemplateDict();
populateLogosDict();
populateZnakiDict();

columns_arr.forEach(function(item, index)
{
    laser_objects.push("OBJ_"+columns_arr[index])
});

var laser_objects_O_T = laser_objects.slice(laser_objects.indexOf("OBJ_O"), laser_objects.indexOf("OBJ_T")+1);
var laser_objects_U_AH = laser_objects.slice(laser_objects.indexOf("OBJ_U"), laser_objects.indexOf("OBJ_AH")+1);

function remove_duplicates(arr)
{
    var m = {}, newarr = []
    for (var i = 0; i < arr.length; i++){
        var v = arr[i];
        if(!m[v])
        {
            newarr.push(v);
            m[v]= true;
        }
    }
    return newarr;
}

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
            columns_dict[dict_keys[i]] = res[0][i];
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
    renderarea.preview(h_Document);
}

function laser_doc_preview()
{

    h_Doc_new = new LaserDoc;
    var file_loc = templates_dict[columns_dict["G"]];
    
    dict_keys = Object.keys(columns_dict);
    print(dict_keys);

    h_Doc_new.load(file_loc);

    dict_keys_U_AH =  dict_keys.slice(dict_keys.indexOf("U"), dict_keys.indexOf("AH")+1);
    
    for( i = 0; i < ( laser_objects_U_AH.length) ; i++)
    {
        var obj =  h_Doc_new.getLaserObject(laser_objects_U_AH[i]);
        if( obj != null)
        {
            obj.text = columns_dict[dict_keys_U_AH[i]];
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
