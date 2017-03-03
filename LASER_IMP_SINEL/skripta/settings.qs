/////////////////////////////////////////////////////////////////////////////////////////////
// LASER SETTINGS
////////////////////////////////////////////////////////////////////////////////////////////
//sets debugging(on=1 and off=0)
var debug_mode = 0;
var enable_existing_sn_marking = 1;

///////////////////////
//Input PIN-s
//////////////////////
const I_PIN_7 = 0x1; const I_PIN_8 = 0x2; const I_PIN_9 = 0x4;
const I_PIN_10 = 0x8; const I_PIN_11 = 0x10; const I_PIN_12 = 0x20; 
const I_PIN_19 = 0x200; const  I_PIN_20 = 0x100;  const  I_PIN_21 = 0x80;  const  I_PIN_22 = 0x40;
///////////////////////
//Output PIN-s
///////////////////////
const O_PIN_2 = 0x1; const O_PIN_3 = 0x4; const O_PIN_4 = 0x10; const O_PIN_5 = 0x40; 
const O_PIN_6 = 0x100; const O_PIN_14 = 0x1000; const O_PIN_15 = 0x2; const O_PIN_16 = 0x08; 
const O_PIN_17 = 0x20; const O_PIN_18 = 0x80; 
const O_PIN_23 = 0x200; const O_PIN_24 = 0x800;

//////////////////////////////////////////////////////
//Flags and variables declaration
/////////////////////////////////////////////////////
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
////////////////////////////
//File locations
drive_loc = "D:";
//drive_loc = "E:";
//drive_loc = "G:";

var tmplPath = drive_loc + "\\LASER_IMP_SINEL\\IMP_SINEL.XLP";
var xlsPath = drive_loc + "\\LASER_IMP_SINEL\\TabelaNMTPLUS.xlsx";
var logoPath = drive_loc + "\\LASER_IMP_SINEL\\Predloge\\" ;
var logPath= drive_loc + "\\LASER_IMP_SINEL\\writeLog.txt";
var resPath = drive_loc + "\\LASER_IMP_SINEL\\res\\";
var nova_db =  drive_loc + "\\LASER_IMP_SINEL\\tabela_baza.xls";

var templatesPath = drive_loc + "\\LASER_IMP_SINEL\\TEMPLATE\\";
var logosPath = drive_loc + "\\LASER_IMP_SINEL\\LOGOTIP\\XLP-LOGOTIPI\\";
var znakiPath = drive_loc + "\\LASER_IMP_SINEL\\ZNAKI\\XLP - ZNAKI\\";

var test_log =  drive_loc + "\\LASER_IMP_SINEL\\tabela_log.xls";

////////////////////////////////////////
//Dictionary declaration
//////////////////////////////////////
var templates_dict = {};
var logotips_dict = {};
var columns_dict = {};
var znaki_dict = {};

var date = new Date();

///////////////////////////////////
//Variables declaration
//////////////////////////////////
var h_Doc_new;
var h_preview = new LaserDoc;
var h_Document,hDb, fw;
var laser_objects = [];

var part_list = []; var logos_list = []; var logotips = [];
var new_list = []; var zdelekArr = [];
var zdelek_ext = []; var zdelek_ext_s = [];
var template_list = [];

var logotips_s; var template_list_s;
var columns_arr = []; var columns_names_arr = []; var log_arr = [];

var log_sn; var last_sn; var curr_sn; 
var numW = 0; var numWC = 0; var confirm = 0;
var sn_marking_times = 1; var sn_update_times = 0;

var znaki_a = "CCC-1,CE-1,EAC-1,GOST-0,GOST-1,puščica-1,ucraino1"
var columns = "A B C D E F G H I J K L M N O P Q R S T U V W X Y Z AA AB AC AD AE AF AG AH AI AJ";
var columns_names = ["Izdelek","Izdelek_naziv","vgrajenec","ime_nap_tab","sek_klas","rotacija","TEMPLATE",
                     "st_nap_tab","Logotip","Ime_1","ime_2","Art nr","S N","SENERTEC","Ucraino","CCC","EAC","GOST",
                     "CE","Puščica","TF","napetost","zaščita","razred izolacije","PN","ln 1 (min)","ln 2","ln 3 (max)","P 1 (min)",
                     "P 2","P 3 (max)","EEI","Poreklo","datum"];

columns_arr = to_arr(columns, "A", "AJ", " ");

/////////////////////////////////
//Laser objects array
////////////////////////////////
columns_arr.forEach(function(item, index)
{
    laser_objects.push("OBJ_"+columns_arr[index])
});

var laser_objects_J_N = laser_objects.slice(laser_objects.indexOf("OBJ_J"), laser_objects.indexOf("OBJ_N")+1);

var laser_objects_O_T = laser_objects.slice(laser_objects.indexOf("OBJ_O"), laser_objects.indexOf("OBJ_T")+1);
var laser_objects_U_AH = laser_objects.slice(laser_objects.indexOf("OBJ_U"), laser_objects.indexOf("OBJ_AH")+1);

////////////////////
//RegEx 
//////////////////////
//date_year = date_year.getFullYear().toString().slice(2);

var ebara_reg = /\w{5}\d{6}/;


var imp_yy = "\^" + date_year +"\\" + "\-\\d{6}";
var imp_reg_dyn = new RegExp(imp_yy);

var imp_reg = imp_reg_dyn;

var num_w_reg = /\d/;
/*************END OF INPUT-OUTPUT FILES SETTINGS********************/

