/////////////////////////////////////////////////////////////////////////////////////////////
// LASER SETTINGS
////////////////////////////////////////////////////////////////////////////////////////////
//sets debugging(on=1 and off=0)
debug_mode = 0;

/*---------------------------------------------------------
 Inputs and outputs
  --------------------------------------------------------*/
/*
Popis funkcija pinova
O_PIN 2 - Busy signal                - OUTPUT
O_PIN 3 - Z os step                 - OUTPUT
O_PIN 4 - Motor brake               - OUTPUT
O_PIN 5 - Cilindar gore             - OUTPUT
O_PIN 6 - Z os Current off			- OUTPUT
O_PIN 16 - Z os direction			- OUTPUT
O_PIN 17 - Laser ext Key 		-OUTPUT
O_PIN 18 Laser ext enable 	-OUTPUT
O_PIN 23 - Cilindar dolje           - OUTPUT
I_PIN 7 - Senzor prisutnosti linije	- INPUT
I_PIN 8 - Glava lasera dolje		- INPUT
I_PIN 9 - Glava lasera gore         - INPUT
I_PIN 10 - Optički senzor			- INPUT
I_PIN 21 - Laserska barijera dolje	- INPUT
I_PIN 12 - Laserska barijera gore	- INPUT
I_PIN 19 - Reset tipkalo			- INPUT
I_PIN 20 - Regulator fault			- INPUT
I_PIN 11 - Total stop input         - INPUT
*/
//Input PINs
const I_PIN_7 = 0x1; const I_PIN_8 = 0x2; const I_PIN_9 = 0x4;
const I_PIN_10 = 0x8; const I_PIN_11 = 0x10; const I_PIN_12 = 0x20; 
const I_PIN_19 = 0x200; const  I_PIN_20 = 0x100;  const  I_PIN_21 = 0x80;  const  I_PIN_22 = 0x40;

//Output PINs
const O_PIN_2 = 0x1; const O_PIN_3 = 0x4; const O_PIN_4 = 0x10; const O_PIN_5 = 0x40; 
const O_PIN_6 = 0x100; const O_PIN_14 = 0x1000; const O_PIN_15 = 0x2; const O_PIN_16 = 0x08; 
const O_PIN_17 = 0x20; const O_PIN_18 = 0x80; 
const O_PIN_23 = 0x200; const O_PIN_24 = 0x800;

/*-------------------------------------------
Flags and variables declaration
--------------------------------------------*/
var auto_mode = "OFF";
var laser_status = "INACTIVE";
var last_error = "no errors";

var nom = 0; var bar_gore = 0; var bar_dolje = 0; var sen_linija = 0;
var sen_laser_gore = 0;  var sen_laser_dolje = 0; var sen_optika = 0;
var sen_bar_dolje = 0; var sen_bar_gore = 0; var reset_tipka = 0;
var reg_fault = 0; var total_stop = 0; var laser_marking = 0;
var laser_in_working_pos = 0;
var brake_status = 0;

var signal_ready = 0;
var z_axis_active = 0;
var sb1_v = 25;
var min_pos = 5;
var search_distance = 130;
var home_pos = 120;
var current_pos = 0;
const num_writes;
var pumps_marked = 0;

var senz_state = 0; 
var last_senz_state = 0;
var pump_present = 0;
var brojac = 0;

/*************END OF LASER SETTINGS********************/


//////////////////////////////////////////////////////////////////////////////////
//INPUT -OUTPUT FILES SETTINGS
/////////////////////////////////////////////////////////////////////////////////
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

var date = new Date();
print(date.mmyy());


//drive_loc = "G:";
drive_loc = "D:";
//drive_loc = "E:";

var tmplPath = drive_loc + "\\LASER_IMP_SINEL\\IMP_SINEL.XLP";
var xlsPath = drive_loc + "\\LASER_IMP_SINEL\\TabelaNMTPLUS.xlsx";
var logoPath = drive_loc + "\\LASER_IMP_SINEL\\Predloge\\" ;
var logPath= drive_loc + "\\LASER_IMP_SINEL\\writeLog.txt";
var resPath = drive_loc + "\\LASER_IMP_SINEL\\res\\";
var nova_db =  drive_loc + "\\LASER_IMP_SINEL\\tabela_baza.xls";

var test_log =  drive_loc + "\\LASER_IMP_SINEL\\tabela_log.xls";


var templates_a = "/,ADL-G,AN-G,BE-G,CAL-G,CAL-N,DEL-G,DEL-GS,DUP-G,EB-G,EB-N,EFA-G,EFA-N,EMS-G,ESP-G,EXP-G,EXP-N,GHN-G,GS-G,GUT-G,IMP-G,IMP-GS,IMP-N,INT-G,KIR-N,LAD-G,LAD-N,MAT-G,MIL-G,PER-G,PER-N,SLD-G,SOM-G,SOME-N,SOML-N,SPE-G,STA-G,UNI-G";

var logotips_a = "ADL,AN,AP,BE,CAL,COOX,DEL,DUP,EB,EBARA,EFA,EMS,ENRJ,ESP,EXP,GS,GUT,IDR,IMP,INT,KIR,LAD,LATITUDE,MAT,MH,MI,PER,PL,SAE,SEA,SEN,SLD,SOM,SPE,ST,STA,TC5,UNI,VEX,calpeda1";

var znaki_a = "CCC-1,CE-1,EAC-1,GOST-0,GOST-1,puščica-1,ucraino1"

var templatesPath = drive_loc + "\\LASER_IMP_SINEL\\TEMPLATE\\";
var logosPath = drive_loc + "\\LASER_IMP_SINEL\\LOGOTIP\\XLP-LOGOTIPI\\";
var znakiPath = drive_loc + "\\LASER_IMP_SINEL\\ZNAKI\\XLP - ZNAKI\\";

var columns = "A B C D E F G H I J K L M N O P Q R S T U V W X Y Z AA AB AC AD AE AF AG AH AI AJ";

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

var templates_dict = {};
var logotips_dict = {};
var columns_dict = {};
var znaki_dict = {};

templates_dict = to_dict(templates_a, "/", "UNI-G", ",");
logotips_dict = to_dict(logotips_a, "ADL","calpeda1",",");
columns_dict = to_dict(columns, "A", "AJ", " ");
znaki_dict = to_dict(znaki_a, "CCC-1","ucraino1", ",");

columns_arr = to_arr(columns, "A", "AJ", " ");

populateTemplateDict();
populateLogosDict();
populateZnakiDict();

columns_arr.forEach(function(item, index)
{
    laser_objects.push("OBJ_"+columns_arr[index])
});

var laser_objects_J_N = laser_objects.slice(laser_objects.indexOf("OBJ_J"), laser_objects.indexOf("OBJ_N")+1);
var laser_objects_O_T = laser_objects.slice(laser_objects.indexOf("OBJ_O"), laser_objects.indexOf("OBJ_T")+1);
var laser_objects_U_AH = laser_objects.slice(laser_objects.indexOf("OBJ_U"), laser_objects.indexOf("OBJ_AH")+1);



/*************END OF INPUT-OUTPUT FILES SETTINGS********************/