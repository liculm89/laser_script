////////////////////////////////////////////////
//  Kreiranje GUI aplikacije
////////////////////////////////////////////////
var dialog = new Dialog ("Laser control",Dialog.D_NONE,false, 0x00040000);
dialog.setFixedSize(1050, 720);
var btn_key = new PushButton();
var btn_enable= new PushButton();

var font1 = "MS Shell Dlg 2,15,-1,5,50,0,0,0,0,0";
var font2 = "Courier New,15,-1,5,80,0,0,0,0,0";
var font_lbls=  "Courier New,12,-1,5,80,0,0,0,0,0";
var font_manual_btns =  "Courier New,15,-1,5,80,0,0,0,0,0";
var lbl_from_db = new Label();
var lbl_prev_man = new Label();
var renderareaPrev = new RenderArea();
var renderareaPrev_m = new RenderArea();
var le_ser = new LineEdit("Serial N.:");

var date_time = new Date();
date_time = date_time.ddmmyytime().toString();

function gen_dialog(part_list)
{  
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////
    //GUI - automatski mod
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////
    dialog.newTab("Automatic mode");

    gb_time = new GroupBox();
    dialog.add(gb_time);
    lbl_date = new Label("");
    lbl_date.font = font_lbls;
    lbl_date.text = "Date-Time:" + date_time;
    
    gb_time.add(lbl_date);

    gb_top = new GroupBox();
    dialog.add(gb_top);
    
    laser_enable_box = new GroupBox("Laser key sequence");
    laser_seq = new GroupBox();
    laser_enable_box.add(laser_seq);
    
    btn_key.text ="KEY ("+ key_state +")"; btn_key["sigPressed()"].connect(laser_key_on);
    btn_key.font = font2; btn_key.setFixedSize(150,60);
    laser_seq.add(btn_key);
    laser_seq.newColumn();

    var btn_shut_down = new PushButton("SHUT DOWN");
    btn_shut_down["sigPressed()"].connect(shut_down);
    btn_shut_down.font = font2; btn_shut_down.setFixedSize(150,60);
    laser_seq.add(btn_shut_down);

    btn_enable["sigPressed()"].connect(enable_pressed); btn_enable.text = "ENABLE (" +enable_state+")";
    btn_enable.font = font2; btn_enable.setFixedSize(350,60);
    laser_enable_box.add(btn_enable);
    
    gb_top.add(laser_enable_box);
    auto_box = new GroupBox(); auto_box.title = "Automatic laser marking";
    gb_top.add(auto_box);
    
    lbl_auto_status = new Label(); lbl_auto_status.text = "Auto mode: " + auto_mode;
    lbl_auto_status.font = font_lbls;
    auto_box.add(lbl_auto_status);
    
    cmb_buttons_auto = new GroupBox();
    var btn_auto_mode = new PushButton("START AUTO MODE");
    btn_auto_mode["sigPressed()"].connect(start_auto_mode);
    btn_auto_mode.font = font2;  btn_auto_mode.setFixedSize(350,60);
    auto_box.add(btn_auto_mode);
    
    cmb_buttons_auto.newColumn();
    var btn_auto_stop = new PushButton("STOP AUTO MODE");
    btn_auto_stop["sigPressed()"].connect(stop_auto);
    btn_auto_stop.font = font2;  btn_auto_stop.setFixedSize(350,60);
    auto_box.add(btn_auto_stop);
    
    gb_top.addSpace(20);
    //Pumps count groupbox
    gb_pump_count = new GroupBox("Pumps count");
    
    lbl_counter = new Label(); lbl_counter.text = "Pumps passed:" + brojac;
    lbl_counter.font = font_lbls;
    gb_pump_count.add(lbl_counter);
    
    lbl_pumps_marked = new Label(); lbl_pumps_marked.text ="Pumps marked:" + pumps_marked;
    lbl_pumps_marked.font = font_lbls;
    gb_pump_count.add(lbl_pumps_marked);
    
    var btn_pump_count = new PushButton("RESET PUMPS COUNTER");
    btn_pump_count["sigPressed()"].connect(reset_pump_count);
    btn_pump_count.font = font2; btn_pump_count.setFixedSize(350,60);
    gb_pump_count.add(btn_pump_count);
    
    gb_top.add(gb_pump_count);

    gb_top.newColumn();
    ////////////////////////////////////
    //Pump selection
    ///////////////////////////////////
    gb_prev_auto = new GroupBox();
    gb_prev = new GroupBox("Part selection");

    gb_top.add(gb_prev_auto);
    gb_prev_auto.add(gb_prev);
    gb_sel = new GroupBox();
    gb_prev.add(gb_sel);
    
    cmb_new = new ComboBox("",zdelekArr);
    cmb_new.font = font2;
    gb_sel.add(cmb_new);
    cmb_new["sigIndexChanged(int)"].connect(dynamic_ext_list);
    gb_sel.newColumn();
    
    cmb_template = new ComboBox("", zdelek_ext_s);
    cmb_template.font = font2;
    cmb_template["sigIndexChanged(int)"].connect(ext_changed);
    gb_sel.add(cmb_template);
    
    /////////////////////////////////
    //Serial number input
    /////////////////////////////////
    le_ser.font = font_lbls;
    le_ser.labelFont = font_lbls;
    le_ser.text = date_year + "-";
    le_ser["sigTextChanged(QString)"].connect(serial_input_changed);
    
    gb_prev.add(le_ser);
    le_num_w = new LineEdit("Quantity :"); le_num_w.font = font_lbls;
    le_num_w.labelFont = font_lbls;
    gb_prev.add(le_num_w);
    
    gb_prev.newColumn();
    gb_confirm = new GroupBox();
    gb_prev.add(gb_confirm);
    
    btn_preview = new PushButton("Confirm selection");
    btn_preview.font = font2;
    btn_preview["sigPressed()"].connect(confirm_selection);
    btn_preview.setFixedSize(215,50);
    
    lbl_from_db.text = "No preview selected";
    lbl_from_db.font = font_lbls;
    gb_confirm.add(btn_preview);
    gb_confirm.add(lbl_from_db);
    
    lbl_ser = new Label();
    lbl_ser.text = "Serial N.:" + le_ser.text;
    lbl_ser.font = font_lbls;
    gb_confirm.add(lbl_ser);

    renderareaPrev.preview(h_Doc_new);
    gb_prev_auto.add(renderareaPrev);

    /////////////////////////////////////////////////////////////////////////
    //LASER STATUS MESSAGES Automatic
    /////////////////////////////////////////////////////////////////////////
    status_box = new GroupBox(); status_box.title= "Status";
    dialog.add(status_box);
    
    lbl_marking = new Label(); lbl_marking.text = "Laser status:" + laser_status;
    lbl_marking.font =  font_lbls;
    status_box.add(lbl_marking);
    
    lbl_last_error = new Label();
    lbl_last_error.text = "Last error:" + last_error;
    lbl_last_error.font = font_lbls;
    status_box.add(lbl_last_error);
    
    ////////////////////////////////////////////////////////////////////////
    //GUI - MANUAL MODE, TAB
    ////////////////////////////////////////////////////////////////////////
    dialog.newTab("Manual mode");
    
    gb_time_m = new GroupBox();
    dialog.add(gb_time_m);
    lbl_date_m = new Label("");
    lbl_date_m.font = font_lbls;
    lbl_date_m.text = "Date-Time:" + date_time;
    gb_time_m.add(lbl_date_m);
    
    gb_top_m = new GroupBox();
    dialog.add(gb_top_m);
    
    gb_left_m = new GroupBox();
    gb_top_m.add(gb_left_m);
    /////////////////////////////
    //grupa "settings"
    /////////////////////////////
    gb_settings = new GroupBox("Settings");
    gb_left_m.add(gb_settings);
    
    lbl1 = new Label(); lbl1.text = "Z axis current position: " + Axis.getPosition(2);
    lbl1.font = font_lbls;
    gb_settings.add(lbl1);
    
    sb1 = new SpinBox("Move distance: ", 25);  sb1["sigValueChanged(int)"].connect(sb1_ch);
    sb1.labelFont = font2;
    sb1.font = font2;
    
    gb_settings.add(sb1);
    gb_lp = new GroupBox(); gb_lp.title = "Laser position";
    
    gb_move_btns = new GroupBox();
    gb_lp.add(gb_move_btns);
    
    var btn_mu = new PushButton("Move up");
    btn_mu["sigPressed()"].connect(move_up);
    btn_mu.font = font_manual_btns; btn_mu.setFixedSize(155,30);
    gb_move_btns.add(btn_mu);
    
    gb_lp.newColumn();
    var btn_md = new PushButton("Move down");
    btn_md["sigPressed()"].connect(move_down);
    btn_md.font = font_manual_btns; btn_md.setFixedSize(155,30);
    gb_move_btns.add(btn_md);
    
    gb_lp.newColumn();
    var btn3 = new PushButton("STOP!");
    btn3["sigPressed()"].connect(stop_axis);
    btn3.font = font_manual_btns; btn3.setFixedSize(125,85);
    gb_lp.add(btn3);
    
    gb_left_m.add(gb_lp);
    
    gb_move_distance = new GroupBox();
    gb_move_distance.newColumn();

    gb_las_r = new GroupBox(); gb_las_r.title ="Laser reference";
    btn_laser_ref = new PushButton("Go to reference position");
    btn_laser_ref["sigPressed()"].connect(laser_reference);
    btn_laser_ref.font = font_manual_btns; btn_laser_ref.setFixedSize(330,30);
    gb_las_r.add(btn_laser_ref);

    btn_laser_pos = new PushButton("Go to working position");
    btn_laser_pos["sigPressed()"].connect(search_working_pos);
    btn_laser_pos.font = font_manual_btns; btn_laser_pos.setFixedSize(330,30);
    gb_las_r.add(btn_laser_pos);
    
    gb_left_m.add(gb_las_r);
    
    ///////////////////////////////////////
    //groupa " laser barrier"
    //////////////////////////////////////
    gb_lb = new GroupBox(); gb_lb.title ="Laser barrier";
    
    var btn_barriera_up = new PushButton("Barrier up");
    btn_barriera_up["sigPressed()"].connect(barrier_up);
    btn_barriera_up.font = font_manual_btns; btn_barriera_up.setFixedSize(160,30);
    gb_lb.add(btn_barriera_up);
    
    gb_lb.newColumn();
    var btn_bar_down = new PushButton("Barrier down");
    btn_bar_down["sigPressed()"].connect(barrier_down);
    btn_bar_down.font = font_manual_btns; btn_bar_down.setFixedSize(160,30);
    gb_lb.add(btn_bar_down);
    
    gb_left_m.add(gb_lb);
    ///////////////////////////////////////////////
    //manual laser marking group
    //////////////////////////////////////////////
    gb_mark = new GroupBox("Manual Laser Marking");
    gb_select_m = new GroupBox();
    
    var btn = new PushButton("MARK!");
    btn["sigPressed()"].connect(readFile_manual);
    btn.setFixedSize(160,30);
    btn.font =  font_manual_btns;
    gb_mark.add(btn);
    gb_mark.newColumn();
    
    var btn_stop_m = new PushButton("STOP MARKING!");
    btn_stop_m["sigPressed()"].connect(stop_m_manual);
    btn_stop_m.setFixedSize(160,30);
    btn_stop_m.font = font_manual_btns;
    gb_mark.add(btn_stop_m);
    
    gb_left_m.add(gb_mark);

    ////////////////////////////
    //Preview Manual
    ////////////////////////////
    gb_top_m.newColumn();
    gb_prev_m = new GroupBox("Marking preview");
    gb_top_m.add(gb_prev_m);

    gb_prev_lbls = new GroupBox();
    gb_prev_m.add(gb_prev_lbls);

    lbl_prev_man.font = font_lbls;
    gb_prev_lbls.add(lbl_prev_man);
    
    gb_prev_lbls.newColumn();
    
    lbl_ser_m = new Label();
    lbl_ser_m.text =  "Serial N.:" + le_ser.text;
    lbl_ser_m.font = font_lbls;
    gb_prev_lbls.add(lbl_ser_m);
    
    lbl_space_prev = new Label("                                                         ");
    lbl_space_prev.font = font_lbls;
    gb_prev_lbls.add(lbl_space_prev);
    renderareaPrev_m.preview(h_Doc_new);
    
    gb_prev_m.add(renderareaPrev_m);
    ////////////////////////////////////////
    //Status Manual mode
    ///////////////////////////////////////
    status_box_m = new GroupBox(); status_box_m.title= "Status";
    dialog.add(status_box_m);
    
    lbl_auto_status_m = new Label(); lbl_auto_status_m.text = "Auto mode:" + auto_mode;
    lbl_auto_status_m.font = font_lbls;
    status_box_m.add(lbl_auto_status_m);

    lbl_marking_m = new Label(); lbl_marking.text = "Laser status:" + laser_status;
    lbl_marking_m.font = font_lbls;
    status_box_m.add(lbl_marking_m);
    
    lbl_last_error_m = new Label(); lbl_last_error_m.text = "Last error:" + last_error;
    lbl_last_error_m.font = font_lbls;
    status_box_m.add(lbl_last_error_m);
    
    if(debug_mode){
        ////////////////////////////////////////////////////////////////////////
        //I/O Status tab
        ////////////////////////////////////////////////////////////////////////
        dialog.newTab("I/O Status");
        ///////////////////////////
        //groupbox inputs
        ////////////////////////////
        gb_inputs = new GroupBox(); gb_inputs.title = "Inputs status";
        dialog.add(gb_inputs);
        lb_sen_linija = new Label(); lb_sen_linija.text = "Senzor linije: " + get_stat(sen_linija);
        lb_sen_linija.font = font_lbls;
        gb_inputs.add(lb_sen_linija);

        lb_sen_bar_gore = new Label(); lb_sen_bar_gore.text = "Senzor laserske barijere gore: " + get_stat(sen_bar_gore);
        lb_sen_bar_gore.font = font_lbls;
        gb_inputs.add(lb_sen_bar_gore);

        lb_sen_bar_dolje = new Label(); lb_sen_bar_dolje.text = "Senzor laserske barijere dolje: " + get_stat(sen_bar_dolje);
        lb_sen_bar_dolje.font = font_lbls;
        gb_inputs.add(lb_sen_bar_dolje);

        lb_sen_laser_gore = new Label(); lb_sen_laser_gore.text = "Senzor laserske glave gore: " + get_stat(sen_laser_gore);
        lb_sen_laser_gore.font = font_lbls;
        gb_inputs.add(lb_sen_laser_gore);

        lb_sen_laser_dolje = new Label(); lb_sen_laser_dolje.text = "Senzor laserske glave dolje: " + get_stat(sen_laser_dolje);
        lb_sen_laser_dolje.font = font_lbls;
        gb_inputs.add(lb_sen_laser_dolje);

        lb_sen_optika = new Label(); lb_sen_optika.text = "Optički senzor: " + get_stat(sen_optika);
        lb_sen_optika.font = font_lbls;
        gb_inputs.add(lb_sen_optika);

        lb_reg_fault = new Label(); lb_reg_fault.text = "Regulator fault: " + get_stat(reg_fault);
        lb_reg_fault.font = font_lbls;
        gb_inputs.add(lb_reg_fault);

        lb_total_stop = new Label(); lb_total_stop.text = "Total stop: " + get_stat(total_stop);
        lb_total_stop.font = font_lbls;
        gb_inputs.add(lb_total_stop);

        lb_reset_tipka = new Label(); lb_reset_tipka.text = "Reset tipka: " + get_stat(reset_tipka);
        lb_reset_tipka.font = font_lbls;
        gb_inputs.add(lb_reset_tipka);
        //////////////////////////////
        //groupbox outputs
        /////////////////////////////
        gb_outputs = new GroupBox(); gb_outputs.title="Output status";
        dialog.add(gb_outputs);

        lbl_lrstatus = new Label(); lbl_lrstatus.text = "Laser ready signal:" + get_stat(signal_ready);
        lbl_lrstatus.font = font_lbls;
        gb_outputs.add(lbl_lrstatus);

        lb_bar_gore = new Label(); lb_bar_gore.text = "Barijera gore: " + get_stat(bar_gore);
        lb_bar_gore.font = font_lbls;
        gb_outputs.add(lb_bar_gore);

        lb_bar_dolje = new Label(); lb_bar_dolje.text = "Barijera dolje: " + get_stat(bar_dolje);
        lb_bar_dolje.font = font_lbls;
        gb_outputs.add(lb_bar_dolje);

    }
    
    ////////////////////////////////////////////////////////////////////////
    //About tab
    ////////////////////////////////////////////////////////////////////////
    dialog.newTab("About");
    font_albls=  "Courier New,9,-1,5,50,0,0,0,0,0";
    
    gb_about = new GroupBox();
    
    gb_ver = new GroupBox("Version");
    gb_about.add(gb_ver);
    dialog.add(gb_about);
    
    lbl_title = new Label("Laser control v0.91");
    lbl_title.font = font_albls;
    gb_ver.add(lbl_title);

    lbl_dscp = new Label("Laser engine script for automatic pump covers marking using VLASE laser.     ");
    lbl_dscp.font = font_albls;
    gb_ver.add(lbl_dscp);
    
    lbl_cu = new Label("Created in Lighter Suite 6.2.3.15944");
    lbl_cu.font = font_albls;
    gb_ver.add(lbl_cu);
    
    lbl_licence = new Label("Licence: GNU General Public Licence, GPL-3.0");
    lbl_licence.font = font_albls;
    gb_ver.add(lbl_licence);
    
    gb_about.addSpace(180);
    
    ////////////////////////
    //About contact
    ////////////////////////
    gb_contact = new GroupBox("Contact");
    dialog.add(gb_contact);
    
    lbl_name = new Label("SINEL Ltd.");
    lbl_name.font = font_albls;
    lbl_name.alignment =1;
    
    gb_about.add(gb_contact);
    gb_contact.add(lbl_name);
    
    lbl_dsc = new Label("Sinel, company for industrial automation, service and trade, limited.       ");
    lbl_dsc.font = font_albls;
    gb_contact.add(lbl_dsc);
    
    lbl_addr = new Label("Rudarska 3 p.p. 101, 52220 Labin, Croatia");
    lbl_addr.font = font_albls;
    gb_contact.add(lbl_addr);
    
    lbl_phone = new Label("Phone: +385 (0) 52 884 000");
    lbl_phone.font = font_albls;
    gb_contact.add(lbl_phone);
    
    lbl_fax = new Label("Fax: +385 (0) 52 884 019");
    lbl_fax.font = font_albls;
    gb_contact.add(lbl_fax);
    
    lbl_email = new Label("email: sinel@sinel.hr");
    lbl_email.font = font_albls;
    gb_contact.add(lbl_email);
    
    lbl_web = new Label("web: www.sinel.hr");
    lbl_web.font =font_albls;
    gb_contact.add(lbl_web);
    
    gb_logo = new GroupBox("Logo");
    gb_about.add(gb_logo);
    
    ///////////////////
    //About logo
    //////////////////
    lbl_sinel_logo = new Label();
    lbl_sinel_logo.loadImage(resPath + "sinel logo.png", aspectRatioMode = 1, w=150, h = 550);
    gb_logo.add(lbl_sinel_logo);
    
    dialog.newColumn();
    lbl_space = new Label("                                                                                          ");
    dialog.add(lbl_space);
    ext_changed();
    dialog.show();
    System["sigTimer(int)"].connect(gui_update);
    dialog.exec();
}

//////////////////////////
//GUI UPDATE
///////////////////////////
function gui_update(ID)
{
    if (timers[0] == ID)
    {
        var date_time = new Date();
        date_time = date_time.ddmmyytime().toString();

        lbl1.text = "Z axis current position: " + Math.round(Axis.getPosition(2));
        lbl_auto_status_m.text= lbl_auto_status.text = "Auto mode: " + auto_mode;

        check_laser_state(System.getDeviceStatus());
        lbl_marking_m.text = lbl_marking.text = "Laser status:" + laser_status;
        lbl_last_error.text = "Last error:" + last_error;
        lbl_last_error_m.text = "Last error:" + last_error;
        lbl_counter.text = "Pumps counter:" + brojac;
        lbl_pumps_marked.text ="Pumps marked:" + pumps_marked;
        btn_key.text ="KEY ("+ key_state +")";
        btn_enable.text = "ENABLE (" +enable_state+")";
        lbl_ser_m.text =  "Serial N.:" + le_ser.text;
        lbl_date.text = "Date-Time:" + date_time;
        lbl_date_m.text = "Date-Time:" + date_time;

        if(debug_mode)
        {
            lb_sen_linija.text = "Senzor linije: " + get_stat(sen_linija);
            lb_sen_bar_gore.text = "Senzor laserske barijere gore:" + get_stat(sen_bar_gore);
            lb_sen_bar_dolje.text = "Senzor laserske barijere dolje:" + get_stat(sen_bar_dolje);
            lb_sen_laser_gore.text = "Senzor laserske glave gore:" + get_stat(sen_laser_gore);
            lb_sen_laser_dolje.text = "Senzor laserske glave dolje:" + get_stat(sen_laser_dolje);
            lb_sen_optika.text = "Optički senzor:" + get_stat(sen_optika);
            lb_reg_fault.text = "Regulator fault:" + get_stat(reg_fault);
            lb_total_stop.text = "Total stop:" + get_stat(total_stop);
            lb_reset_tipka.text = "Reset tipka:" + get_stat(reset_tipka);
            lb_bar_gore.text = "Barijera gore:" + get_stat(bar_gore);
            lb_bar_dolje.text = "Barijera dolje:" + get_stat(bar_dolje);
        }
    }
}

cmb_template = new ComboBox("");

function sb1_ch(value)
{
    sb1_v = value;
}

function get_stat(input)
{
    if(input == 1 ){stat= "Active";} else {stat="Inactive";}
    return stat;
}

function get_laser_stat(input)
{
    if(input == 1){stat = "Ready for marking";} else {stat = "Not ready for marking!"}
    return stat;
}

function get_motor_status(input)
{
    if(input == 1 ){stat= "Moving";} else {stat="Holding position";}
    return stat;
}

///////////////////////////////////////////
//Script Shut down function
///////////////////////////////////////////
function shut_down()
{
    if( auto_mode == "OFF")
    {
        IoPort.resetPort(0, O_PIN_2);
        print("Shutdown started");
        System.stopLaser();
        disconnect_timers();
        System.killAllTimers();
        enable_break();
        dialog.OK();
        dialog.close();
    }
    else
    {
        error_auto_mode();
    }
}

function reset_pump_count()
{
    brojac = 0;
    pumps_marked = 0;
}
