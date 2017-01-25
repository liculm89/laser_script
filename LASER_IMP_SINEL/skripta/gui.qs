/*-----------------------------------
  Kreiranje GUI aplikacije
  -----------------------------------*/
 var dialog = new Dialog ("Laser control",Dialog.D_NONE,false, 0x00040000);

function gen_dialog(part_list)
{  
    dialog.setFixedSize(600,720);
    /*--------------------------
     GUI - automatski mod
     ------------------------*/
    font1 = "MS Shell Dlg 2,15,-1,5,50,0,0,0,0,0";
    font2 = "Courier New,15,-1,5,80,0,0,0,0,0";
    font_lbls=  "Courier New,12,-1,5,80,0,0,0,0,0";
    font_manual_btns =  "Courier New,15,-1,5,80,0,0,0,0,0";

    dialog.newTab("Automatic mode");
    auto_box = new GroupBox(); auto_box.title = "Automatic laser marking";
    dialog.add(auto_box);
    
    lbl_auto_status = new Label(); lbl_auto_status.text = "Auto mode: " + auto_mode;
    lbl_auto_status.font = font_lbls;
    auto_box.add(lbl_auto_status);
    
    gb_cmb_box = new GroupBox();
    auto_box.add(gb_cmb_box);
    
    lbl_select_type = new Label(); lbl_select_type.text = "Select type:";
    lbl_select_type.font = font2;
    gb_cmb_box.add(lbl_select_type);
    
    gb_cmb_box.newColumn();
    cmb_a = new ComboBox("",part_list);
    cmb_a.font = font2;
    gb_cmb_box.add(cmb_a);
    cmb_a["sigIndexChanged(int)"].connect(logo_selection);

    selectedLogo_a =  new Label(txt_selected_logo + "/");
    logo_init(cmb_a.currentItem, selectedLogo_a);
    
    selectedLogo_a.font = font_lbls;
    auto_box.add(selectedLogo_a);
    
    cmb_buttons_auto = new GroupBox();
    auto_box.add(cmb_buttons_auto);
    
    var btn_auto_mode = new PushButton("START AUTO MODE");
    //btn_auto_mode["sigPressed()"].connect(readFile_auto);
    btn_auto_mode["sigPressed()"].connect(start_auto_mode);
    btn_auto_mode.font = font2;  btn_auto_mode.setFixedSize(300,60);
    cmb_buttons_auto.add(btn_auto_mode);
    
    var btn_auto_stop = new PushButton("STOP AUTO MODE");
    btn_auto_stop["sigPressed()"].connect(stop_auto);
    btn_auto_stop.font = font2;  btn_auto_stop.setFixedSize(300,60);
    cmb_buttons_auto.add(btn_auto_stop);
   
    dialog.addSpace(50);
    gb_pump_count = new GroupBox();
    
    lbl_counter = new Label(); lbl_counter.text = "Pumps counter:" + brojac;
    lbl_counter.font = font_lbls;
    gb_pump_count.add(lbl_counter);
    
    
    var btn_pump_count = new PushButton("RESET PUMPS COUNTER");
    btn_pump_count["sigPressed()"].connect(reset_pump_count);
    btn_pump_count.font = font2; btn_pump_count.setFixedSize(300,60);
    gb_pump_count.add(btn_pump_count);

    dialog.add(gb_pump_count);
    
    gb_shutdown = new GroupBox();
    dialog.add(gb_shutdown);
    var btn_shut_down = new PushButton("SHUT DOWN");
    btn_shut_down["sigPressed()"].connect(shut_down);
    btn_shut_down.font = font2; btn_shut_down.setFixedSize(300,60);
    gb_shutdown.add(btn_shut_down);
    
    
    status_box = new GroupBox(); status_box.title= "Status";
    dialog.add(status_box);
    
    lbl_marking = new Label(); lbl_marking.text = "Laser status:" + laser_status;
    lbl_marking.font =  font_lbls;
    status_box.add(lbl_marking);
    
    lbl_laser_moving = new Label(); lbl_laser_moving.text = "Laser motor:" + get_motor_status( laser_moving );
    lbl_laser_moving.font = font_lbls;
    status_box.add(lbl_laser_moving);
    
    lbl_last_error = new Label(); lbl_last_error.text = "Last error:" + last_error;
    lbl_last_error.font = font_lbls;
    status_box.add(lbl_last_error);

    /*--------------------------
     GUI - manualni mod
     ------------------------*/
    dialog.newTab("Manual mode");

    //grupa "settings"
    gb = new GroupBox();gb.title = "Settings";
    dialog.add(gb);

    lbl1 = new Label(); lbl1.text = "Z axis current position: " + Axis.getPosition(2);
    lbl1.font = font_lbls;
    gb.add(lbl1);
    
    gb_move_distance = new GroupBox();
    
    sb1 = new SpinBox("", 25);  sb1["sigValueChanged(int)"].connect(sb1_ch);
    sb1.font = font2;
    
    lbl_md = new Label(); lbl_md.text ="Moving distance:";
    lbl_md.font = font2;
    gb_move_distance.add(lbl_md);
				  
    gb_move_distance.newColumn();
    gb_move_distance.add(sb1);
    gb.add(gb_move_distance);

    gb_las_r = new GroupBox(); gb_las_r.title ="Laser reference";
    btn_laser_ref = new PushButton("Move laser to reference position");
    btn_laser_ref["sigPressed()"].connect(laser_reference);
    btn_laser_ref.font = font_manual_btns; btn_laser_ref.setFixedSize(400,50);
    gb_las_r.add(btn_laser_ref);

    btn_laser_pos = new PushButton("Move laser to working  position");
    btn_laser_pos["sigPressed()"].connect(search_working_pos);
    btn_laser_pos.font = font_manual_btns; btn_laser_pos.setFixedSize(400,50);
    gb_las_r.add(btn_laser_pos);

    dialog.add(gb_las_r);

    //grupa "laser pos"
    gb_lp = new GroupBox(); gb_lp.title = "Laser position";

    var btn_mu = new PushButton("Move up");
    btn_mu["sigPressed()"].connect(move_up);
    btn_mu.font = font_manual_btns; btn_mu.setFixedSize(120,50);
    gb_lp.add(btn_mu);

    gb_lp.newColumn();
    var btn_md = new PushButton("Move down");
    btn_md["sigPressed()"].connect(move_down);
    btn_md.font = font_manual_btns; btn_md.setFixedSize(120,50);
    gb_lp.add(btn_md);

    gb_lp.newColumn();
    var btn3 = new PushButton("STOP!");
    btn3["sigPressed()"].connect(stop_axis);
    btn3.font = font_manual_btns; btn3.setFixedSize(120,50);
    gb_lp.add(btn3);
    dialog.add(gb_lp);

    dialog.okButtonText = "Done"
    dialog.cancelButtonText = "Abort";

    //groupa " laser barrier"
    gb_lb = new GroupBox(); gb_lb.title ="Laser barrier";

    var btn_barriera_up = new PushButton("Barrier up");
    btn_barriera_up["sigPressed()"].connect(barrier_up);
    btn_barriera_up.font = font_manual_btns; btn_barriera_up.setFixedSize(160,50);
    gb_lb.add(btn_barriera_up);

    gb_lb.newColumn();

    var btn_bar_down = new PushButton("Barrier down");
    btn_bar_down["sigPressed()"].connect(barrier_down);
    btn_bar_down.font = font_manual_btns; btn_bar_down.setFixedSize(160,50);
    gb_lb.add(btn_bar_down);

    dialog.add(gb_lb);

    //manual laser marking group
    gb_mark = new GroupBox("Manual Laser Marking");
    
    gb_select_m = new GroupBox();
    
    gb_mark.add(gb_select_m);
    cmb = new ComboBox("", part_list);
    cmb.font = font_manual_btns;
    cmb["sigIndexChanged(int)"].connect(logo_selection_m);
    lbl_select_m = new Label(); lbl_select_m.text = ("Select type:");
    lbl_select_m.font =font_manual_btns;
    gb_select_m.add(lbl_select_m);					  
    
    gb_select_m.newColumn();
    gb_select_m.add(cmb);

    selectedLogo = new Label(txt_selected_logo + "/");
    selectedLogo.font = font_lbls;
    logo_init(cmb.currentItem, selectedLogo);
    gb_mark.add(selectedLogo);

    gb_mark.newColumn();
    var btn = new PushButton("ZAPIŠI!");
    btn["sigPressed()"].connect(readFile_manual);
    btn.setFixedSize(160,50);
    btn.font =  font_manual_btns;
    gb_mark.add(btn);   
    
    var btn_stop_m = new PushButton("STOP MARKING!");
    btn_stop_m["sigPressed()"].connect(stop_m_manual);
    btn_stop_m.setFixedSize(160,50);
    btn_stop_m.font = font_manual_btns;
    gb_mark.add(btn_stop_m);

    dialog.add(gb_mark);
    
    status_box = new GroupBox(); status_box.title= "Status";
    dialog.add(status_box);
    
    lbl_auto_status_m = new Label(); lbl_auto_status.text = "Auto mode:" + auto_mode;
    lbl_auto_status_m.font = font_lbls;
    status_box.add(lbl_auto_status_m);
    
    lbl_marking_m = new Label(); lbl_marking.text = "Laser status:" + laser_status;
    lbl_marking_m.font = font_lbls;
    status_box.add(lbl_marking_m);
    
    if(debug_mode){ 
    /*-----------------
      I/O Status tab
      -------------------*/
    dialog.newTab("I/O Status");
    
    //groupbox inputs
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
  
    //groupbox outputs
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
    
        /*
      Preview tab
      */
    dialog.newTab("Preview")
    renderarea = new RenderArea();
    dialog.add(renderarea);
    var auto = 1; var init = 1;
    generate_laser_doc(auto, init);
    renderarea.preview(h_Document);
    /*
      About tab
      */
    dialog.newTab("About");
    font_albls=  "Courier New,9,-1,5,50,0,0,0,0,0";
   
    gb_ver = new GroupBox("Version");
    dialog.add(gb_ver);
   
    lbl_title = new Label("Laser control v0.9rc4");
    lbl_title.font = font_albls;
    gb_ver.add(lbl_title);
    
    lbl_dscp = new Label("Laser engine script for automatic pump covers marking using VLASE laser.               ");
    lbl_dscp.font = font_albls;
    gb_ver.add(lbl_dscp);
    
    lbl_cu = new Label("Created in Lighter Suite 6.2.3.15944");
    lbl_cu.font = font_albls;
    gb_ver.add(lbl_cu);
    
    lbl_licence = new Label("Licence: GNU General Public Licence, GPL-3.0");
    lbl_licence.font = font_albls;
    gb_ver.add(lbl_licence);

    dialog.addSpace(180);
    gb_contact = new GroupBox("Contact");
    dialog.add(gb_contact);
    
    lbl_name = new Label("SINEL Ltd.");
    lbl_name.font = font_albls;
    lbl_name.alignment =1;
    gb_contact.add(lbl_name);
  
    lbl_dsc = new Label("Sinel, company for industrial automation, service and trade, limited.            ");
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
    dialog.add(gb_logo);
    lbl_sinel_logo = new Label();
    lbl_sinel_logo.loadImage(resPath + "sinel logo.png", aspectRatioMode = 1, w=150, h = 550);
    gb_logo.add(lbl_sinel_logo);
    
    dialog.show();
    
    System["sigTimer(int)"].connect(gui_update);
    dialog.exec();
}

function gui_update(ID)
{
    if (timers[0] == ID)
    {
        lbl1.text = "Z axis current position: " + Math.round(Axis.getPosition(2));
        lbl_auto_status_m.text= lbl_auto_status.text = "Auto mode: " + auto_mode;
	
        check_laser_state(System.getDeviceStatus());
        lbl_marking_m.text = lbl_marking.text = "Laser status:" + laser_status;
        lbl_last_error.text = "Last error:" + last_error;
        lbl_laser_moving.text = "Laser motor:" + get_motor_status(laser_moving);
        lbl_counter.text = "Pumps counter:" + brojac;
        
	//generate_laser_doc();
	 //renderarea.preview(h_Document);
	
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
    if(input == 1){stat = "Ready for marking";} else { stat = "Not ready for marking!"}
    return stat;
}

function get_motor_status(input)
{
    if(input == 1 ){stat= "Moving";} else {stat="Holding position";}
    return stat;
}


function logo_selection(selected)
{
    logos_list.forEach(function (item, index)
    {
        if (index == selected)
        {
            selectedLogo_a.text = txt_selected_logo + item;
        }
    });
    var auto = 1; var init = 0;
    generate_laser_doc(auto, init);
}

function logo_selection_m(selected)
{
    logos_list.forEach(function (item, index)
    {
        if (index == selected)
        {
            selectedLogo.text = txt_selected_logo + item;
        }
    });
    var auto = 0; var init = 0;
    generate_laser_doc(auto, init);
}

function logo_init(curr_item, label)
{
    if( part_list != 0)
    {
        part_list.forEach(function (item, index)
        {
            if (item == curr_item)
            {
                label.text = txt_selected_logo + logos_list[index];
            }
        });
    }
    //generate_laser_doc();
}

function shut_down()
{
    if( auto_mode == "OFF")
    {
        print("Shutdown started");
        disconnect_timers();
        enable_break();
        System.killAllTimers();
        dialog.OK();
    }
    else
    {
        error_auto_mode();
    }
}

function reset_pump_count()
{
    brojac = 0;
}


