////////////////////////////////////////////////////////////
//Parts List creation from xls database
///////////////////////////////////////////////////////////
function parts_list() {
    hDb3 = new Db("QODBC")
    hDb3.dbName = "DRIVER={Microsoft Excel Driver (*.xls, *.xlsx, *.xlsm, *.xlsb)};HDR=yes;ReadOnly=0;Dbq=" + nova_db;
    if (hDb3.open()) {
        new_list = []; zdelekArr = [];
        zdelek_ext = []; logotips = [];
        var res = hDb3.exec("SELECT Izdelek FROM [Napisne tablice in nalepke sezn$] WHERE Izdelek is not null");
        template_list = [];
        res.forEach(function (item, index) {
            if (res[index][0] != "") {
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
function gen_lists_from_xls() {
    hDb3 = new Db("QODBC")
    hDb3.dbName = "DRIVER={Microsoft Excel Driver (*.xls, *.xlsx, *.xlsm, *.xlsb)};HDR=yes;ReadOnly=0;Dbq=" + nova_db;
    if (hDb3.open()) {
        template_list = [];
        logotips = [];

        var res1 = hDb3.exec("SELECT TEMPLATE FROM [Napisne tablice in nalepke sezn$] WHERE TEMPLATE is not null");
        var res2 = hDb3.exec("SELECT Logotip FROM [Napisne tablice in nalepke sezn$] WHERE Logotip is not null");

        res1.forEach(function (item, index) {
            if (res1[index][0] != "") {
                template_list.push(res1[index][0])
            }
        });
        template_list.sort();
        template_list_s = remove_duplicates(template_list);
        template_list_s = template_list_s.toString()

        res2.forEach(function (item, index) {
            if (res2[index][0] != "") {
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
function dynamic_ext_list(part_id) {
    hDb4 = new Db("QODBC")
    hDb4.dbName = "DRIVER={Microsoft Excel Driver (*.xls, *.xlsx, *.xlsm, *.xlsb)};HDR=yes;Dbq=" + nova_db;

    if (hDb4.open()) {
        var res2 = hDb4.exec("SELECT Izdelek FROM [Napisne tablice in nalepke sezn$] WHERE Izdelek LIKE '" + zdelekArr[part_id] + "%'");
        zdelek_ext_s = [];
        res2.forEach(function (item, index) {
            if (res2[index][0] != "") {
                zdelek_ext_s[index] = res2[index][0].toString().slice(9);
                if (zdelek_ext_s[index] == "") {
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

/////////////////////////////////////////////
//Serial number LABEL update
////////////////////////////////////////////
function serial_input_changed(text) {
    lbl_ser.text = "Serial N.:" + text;
}
var sel_init = 0;
var current_selection;
var last_selection = "";

function ext_changed() {
    if (auto_mode == "OFF") {
        le_ser.text = "none";
        current_selection = cmb_template.currentItem;
        if (current_selection != last_selection) {
            selection_init();
        }
        last_selection = current_selection;
    }
}

///////////////////////////////
//Serial number init
//////////////////////////////
function init_sn() {
    if ((columns_dict["M"] == "ebara") || (ebara_reg.test(columns_dict["M"]))) {
        var ebara_pre = get_ebara_prefix();
        last_serial = ebara_pre + "000001";
    }
    else {
        year = new Date();
        year = year.getFullYear().toString().slice(2);
        last_serial = year + "-" + "000001";
    }
    return last_serial;
}

///////////////////////////////////////////////////
//Gets the last serial from log file
//////////////////////////////////////////////////
function get_last_serial() {
    var part = cmb_new.currentItem;
    var ext = cmb_template.currentItem;

    hDb4 = new Db("QODBC")
    hDb4.dbName = "DRIVER={Microsoft Excel Driver (*.xls, *.xlsx, *.xlsm, *.xlsb)};HDR=yes;Dbq=" + test_log;

    if (ext == "      ") {
        var query_se = "SELECT [S N] FROM [Napisne tablice in nalepke sezn$] WHERE Izdelek LIKE '" + part + "'";
    }
    else {
        var query_se = "SELECT [S N] FROM [Napisne tablice in nalepke sezn$] WHERE Izdelek LIKE '" + part + ext + "'";
    }

    var snArr = [];
    if (hDb4.open()) {
        var res = hDb4.exec(query_se);

        if (res.length != 0) {
            res.forEach(function (item, index) {
                if (res[index][0] != "") {
                    snArr.push(res[index][0]);
                }
            });
            snArr.sort();

            if (res[0] != null) {
                var last_serial = snArr[snArr.length - 1];
            }
        }
        else {
            last_serial = init_sn();
        }
    }
    hDb4.close();

    return last_serial;
}

//////////////////////////////////
//Serial number check
//////////////////////////////////
function check_sn(sn) {

    var part = cmb_new.currentItem;
    var ext = cmb_template.currentItem;

    hDb4 = new Db("QODBC");
    hDb4.dbName = "DRIVER={Microsoft Excel Driver (*.xls, *.xlsx, *.xlsm, *.xlsb)};HDR=yes;Dbq=" + test_log;

    if (ext == "      ") {
        var query_se = "SELECT [S N] FROM [Napisne tablice in nalepke sezn$] WHERE Izdelek LIKE '" + part + "'";
    }
    else {
        var query_se = "SELECT [S N] FROM [Napisne tablice in nalepke sezn$] WHERE Izdelek LIKE '" + part + ext + "'";
    }

    var snArr = [];
    var snArr_i = [];
    if (hDb4.open()) {
        var res = hDb4.exec(query_se);

        if (res.length != 0) {
            res.forEach(function (item, index) {
                if (res[index][0] != "") {
                    snArr.push(res[index][0]);
                }
            });
        }
    }
    hDb4.close();

    snArr.forEach(function (item, index) {
        snArr_i[index] = snArr[index].toString().slice(3);
        snArr_i[index] = parseInt(snArr_i[index]);
    });

    if (snArr_i.indexOf(sn) >= 0) {
        return true;
    }
    else {
        return false;
    }
}

/////////////////////////////////////
//Serial number update
////////////////////////////////////
function update_sn() {
    if ((columns_dict["M"] == "ebara") || (ebara_reg.test(columns_dict["M"]))) {
        ebara_pre = get_ebara_prefix();
        le_ser.text = ebara_pre + last_sn;
    }
    else {
        le_ser.text = date_year + "-" + last_sn;
    }
}

/////////////////////////////////////////
//Initial values generation
///////////////////////////////////////
function selection_init() {

    hDb4 = new Db("QODBC")
    hDb4.dbName = "DRIVER={Microsoft Excel Driver (*.xls, *.xlsx, *.xlsm, *.xlsb)};HDR=yes;Dbq=" + nova_db;
    var part = cmb_new.currentItem;
    var ext = cmb_template.currentItem;

    if (cmb_template.currentItem == "      ") {
        ext = "";
    }

    dict_keys = Object.keys(columns_dict);
    if (hDb4.open()) {
        var res = hDb4.exec("SELECT * FROM [Napisne tablice in nalepke sezn$] WHERE Izdelek LIKE '" + part + ext + "'");
        log_arr = [];
        if (res[0] != null) {
            for (i = 0; i < dict_keys.length; i++) {
                columns_dict[dict_keys[i]] = res[0][i];
            }
        }

        if (columns_dict["M"] != "/" && columns_dict["M"] != '') {
            le_ser.enable = true;
            last_sn = get_last_serial().toString();
            //if (debug_mode) { print("columns dict m " + columns_dict["M"]); }

            last_sn = get_serial_int(last_sn);
            if (last_sn == 1) {
                last_sn = leftPad((last_sn), 6);
            }
            else {
                last_sn = leftPad((last_sn + 1), 6);
            }
            update_sn();
            le_ser.enable = true;
        }
        else {
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
function confirm_selection() {

    if (auto_mode == "OFF") {
        confirm = 0;
        if (columns_dict["M"] != "/" && columns_dict["M"] != '') {
            last_sn = get_last_serial().toString();

            sn_update_times = columns_dict["H"];
            last_sn = get_serial_int(last_sn);

            if (last_sn != 1) {
                last_sn = last_sn + 1;
                last_sn = leftPad((last_sn), 6);
            }
            else {
                last_sn = leftPad((last_sn), 6);
            }
            le_sn = le_ser.text;

            if (check_sn_format_imp(le_sn)) {
                le_sn = get_serial_int(le_sn)
                curr_sn = le_sn;
                le_sn = leftPad((le_sn), 6);
                ///////////////////////////////////////////////
                //Check if serial already exist
                /////////////////////////////////////////////
                if (!enable_existing_sn_marking) {
                    if (check_sn(curr_sn)) {
                        error_sn_exists();
                        confirm = 0;
                    }
                    else {
                        columns_dict["M"] = le_ser.text;
                        confirm = 1;
                    }
                }
                else {
                    columns_dict["M"] = le_ser.text;
                    confirm = 1;
                }
            }
            else {
                error_sn_false_format();
            }

            le_ser.enable = true;
        }
        else {
            le_ser.text = "none";
            le_ser.enable = false;
            confirm = 1;
        }
        sn_marking_times = parseInt(columns_dict["H"]);
        numW = le_num_w.text;
        get_quantity();

//        if (debug_mode) { print("genereting laser doc"); }
        laser_doc_generate();
    }
    else {
        error_auto_started();
    }
}

function get_quantity() {
    numW = le_num_w.text;
    numW = parseInt(numW);
    if (num_w_reg.test(numW)) {
        numW = parseInt(numW);
        if (isNaN(numW)) { numW = 0; }
    }
    else if (typeof (numW == NaN)) {
        numW = 0;
    }
    else {
        error_wrong_quantity_format();
    }
}

//////////////////////////////////////////////////////
//Laser objects updates
//////////////////////////////////////////////////////
function laser_objects_update() {
    dict_keys_J_N = dict_keys.slice(dict_keys.indexOf("J"), dict_keys.indexOf("N") + 1);
    dict_keys_O_T = dict_keys.slice(dict_keys.indexOf("O"), dict_keys.indexOf("T") + 1);
    dict_keys_U_AH = dict_keys.slice(dict_keys.indexOf("U"), dict_keys.indexOf("AH") + 1);

    //////////////////////////////////////////
    //Učitavanja logo-a u template
    //////////////////////////////////////////
    if (columns_dict["I"] != "/" && columns_dict["I"] != '') {
        var obj = h_Doc_new.getLaserImported("OBJ_I");
        if (obj != null) {
            obj.importFile(logosPath + columns_dict["I"] + ".xlp");
            obj.update();
        }
        else {
            template_file_error();
        }
    }
    /////////////////////////////////////////////////
    //Učitavanje tekstualnih objekata
    //////////////////////////////////////////////////
    for (i = 0; i < (laser_objects_J_N.length); i++) {
        var obj = h_Doc_new.getLaserObject(laser_objects_J_N[i]);
        if (obj != null) {
            if (columns_dict[dict_keys_J_N[i]] != "/") {
                obj.text = columns_dict[dict_keys_J_N[i]];
                obj.update();
            }
        }
    }

    /////////////////////////////
    //Učitavanje znakova
    /////////////////////////////
    for (i = 0; i < (laser_objects_O_T.length); i++) {
      //  print((laser_objects_O_T[i]));
        var obj = h_Doc_new.getLaserImported(laser_objects_O_T[i]);
      //  print(obj);
        if (obj != null) {
          //  print((columns_dict[dict_keys_O_T[i]] != "/"));
            if (columns_dict[dict_keys_O_T[i]] != "/") {

              //  print("Dict column " + columns_dict[dict_keys_O_T[i]]);
                obj.importFile(znakiPath + columns_dict[dict_keys_O_T[i]] + ".xlp");
                obj.update();
            }
            else {
             //   print("removing objects:" + obj.id);
                h_Doc_new.removeLaserObject(obj.id)
                h_Doc_new.update();
            }
        }
    }

    for (i = 0; i < (laser_objects_U_AH.length); i++) {
        var obj = h_Doc_new.getLaserObject(laser_objects_U_AH[i]);
        if (obj != null) {
            if (columns_dict[dict_keys_U_AH[i]] != "/") {
                obj.text = columns_dict[dict_keys_U_AH[i]];
                obj.update();
            }
        }
    }

    if (columns_dict["AI"] != "/" && columns_dict["AI"] != '') {
        var obj = h_Doc_new.getLaserImported("OBJ_AI");
        if (obj != null) {
            obj.importFile(znakiPath + columns_dict["AI"] + ".xlp");
            obj.update();
        }
        else {
           // print("object does not exist");
        }
    }

}
//////////////////////////////////////////////////////
//Laser doc generation
//////////////////////////////////////////////////////
function laser_doc_generate() {
    h_Doc_new = new LaserDoc;
    var template_file = templatesPath + columns_dict["G"] + ".xlp";

    dict_keys = Object.keys(columns_dict);

    if (h_Doc_new.load(template_file)) {
        h_Doc_new.load(template_file);
        laser_objects_update();
        ////////////////////////////////
        //Sets MONTH/YEAR
        ////////////////////////////////
        if (columns_dict["AH"] == "mm/yy") {
            var obj = h_Doc_new.getLaserObject("OBJ_AH");
            if (obj != null) {
                var date = new Date();
                columns_dict["AH"] = date.mmyy();
                obj.text = date.mmyy();
            }
        }
        h_preview = h_Doc_new;
        //h_preview.move(marking_loc[0], marking_loc[1]);
        renderareaPrev.preview(h_preview);
        renderareaPrev_m.preview(h_preview);
        rotate_and_move();
        h_Doc_new.update();
    }
    else {
        error_template_missing();
    }
}

function rotate_and_move() {
    /////////////////////////////////
    //Rotation switch
    /////////////////////////////////
    kut = parseInt(columns_dict["F"]);

    switch (kut) {
        case 0:
            h_Doc_new.rotate(0 - 90);
            break;
        case 90:
            h_Doc_new.rotate(90 - 90);
            break;
        case 180:
            h_Doc_new.rotate(180 - 90);
            break;
        case 270:
            h_Doc_new.rotate(270 - 90);
            break;
        case 360:
            h_Doc_new.rotate(360 - 90);
            break;
        default:
            h_Doc_new.rotate(0 - 90);
    }
    ///////////////////////////////////////////////
    //Korekcija koordinate lasera
    ///////////////////////////////////////////////
    get_xy_loc();
    h_Doc_new.move(marking_loc[0], marking_loc[1]);

}

/////////////////////////////////////
//Laser doc update
////////////////////////////////////
function laser_doc_update() {
    if (columns_dict["M"] != "/" && columns_dict["M"] != '') {
        last_sn = curr_sn;
        last_sn = leftPad((last_sn), 6);
        update_sn();
        columns_dict["M"] = le_ser.text;
        laser_objects_update();
        h_preview.rotate(-90);
        h_preview.update();

        rotate_and_move();
        h_Doc_new.update();
    }
}

///////////////////////////////////////////////
//Logging into xls database
//////////////////////////////////////////////
function xls_log() {
    var date2 = new Date();
    date2 = date2.ddmmyytime().toString();

    log_arr.splice(-2, 2);
    var colNamesStr = "[" + columns_names.join("],[") + "]";

    log_str = "'" + log_arr.join("','") + "'";
    log_str = "'" + date2 + "'," + log_str;
    colNamesStr = "Time_date," + colNamesStr;

    var query1 = "INSERT INTO [Napisne tablice in nalepke sezn$] (" + colNamesStr + ") VALUES (" + log_str + ")";
    if (debug_mode) { print("writing_log"); }
    hDb3 = new Db("QODBC")
    hDb3.dbName = "DRIVER={Microsoft Excel Driver (*.xls, *.xlsx, *.xlsm, *.xlsb)};HDR=yes;ReadOnly=0;Dbq=" + test_log;

    if (hDb3.open()) {
        if (!hDb3.exec(query1)) {
            print(hDb3.lastError());
        }
    }
    hDb3.close();
}

function writeLog(currentNum) {
    var today = new Date();
    if (debug_mode) { print("Writing to log:" + currentNum); }
    var outFile = new File(logPath);
    outFile.open(File.Append);
    outFile.write("\r\n" + today.toLocaleString() + " - " + currentNum);
    outFile.close();
}
