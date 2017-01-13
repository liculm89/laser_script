/*-----------------------------------
  Kreiranje GUI aplikacije
  -----------------------------------*/
function gen_dialog(part_list)
{  
   var dialog = new Dialog ("Laser control",Dialog.D_OK,false, 0x00040000);
   dialog.okButtonText = "Done"; dialog.cancelButtonText = "Abort";
   dialog.setFixedSize(500,720);
   /*--------------------------
     GUI - automatski mod
     ------------------------*/
    font1 = "MS Shell Dlg 2,15,-1,5,50,0,0,0,0,0";
    font2 = "Courier New,15,-1,5,80,0,0,0,0,0";
    font_lbls=  "Courier New,12,-1,5,60,0,0,0,0,0";
    font_manual_btns =  "Courier New,12,-1,5,80,0,0,0,0,0";
  
    dialog.newTab("Automatic mode");
    auto_box = new GroupBox(); auto_box.title = "Automatic laser marking";
    dialog.add(auto_box);
    
    cmb_a = new ComboBox("Select type:", part_list);
    //cmb_a.label.font = font2;
    cmb_a.font = font2;
    auto_box.add(cmb_a);    

    selectedLogo_a =  new Label(txt_selected_logo + "/"); 
    auto_box.add(selectedLogo_a);
    
    var btn_auto_mode = PushButton ("START AUTO MODE");
    //btn_auto_mode["sigPressed()"].connect(readFile_auto);
    btn_auto_mode["sigPressed()"].connect(start_auto_mode);
    btn_auto_mode.font = font2;  btn_auto_mode.setFixedSize(200,60);
    auto_box.add(btn_auto_mode);
    
    var btn_auto_stop = PushButton ("STOP AUTO MODE" ); 
    btn_auto_stop["sigPressed()"].connect(stop_auto);
    btn_auto_stop.font = font2;  btn_auto_stop.setFixedSize(200,60);
    auto_box.add(btn_auto_stop);
  
    dialog.addSpace(350);
    status_box = new GroupBox(); status_box.title= "Status";
    dialog.add(status_box);
    
    lbl_auto_status = new Label(); lbl_auto_status.text = "Auto mode: " + auto_mode;
    lbl_auto_status.font = font_lbls;
    status_box.add(lbl_auto_status);
    
    
    lbl_marking = new Label(); lbl_marking.text = "Laser status :" + laser_status;
    lbl_marking.font =  font_lbls;
    status_box.add(lbl_marking);
   
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
   
    sb1 = new SpinBox("Move distance:", 25);  sb1["sigValueChanged(int)"].connect(sb1_ch);
    sb1.font = font_lbls;
   gb.add(sb1);
  
   gb_las_r = new GroupBox(); gb_las_r.title ="Laser reference";
   btn_laser_ref = PushButton ("Move laser to reference position");
   btn_laser_ref["sigPressed()"].connect(laser_reference);
   btn_laser_ref.font = font_manual_btns; btn_laser_ref.setFixedSize(400,40);
   gb_las_r.add(btn_laser_ref);
   
   btn_laser_pos = PushButton ("Move laser to working  position");
   btn_laser_pos["sigPressed()"].connect(search_working_pos);
   btn_laser_pos.font = font_manual_btns; btn_laser_pos.setFixedSize(400,40);
   gb_las_r.add(btn_laser_pos);
   
   dialog.add(gb_las_r);
   
  //grupa "laser pos"
  gb_lp = new GroupBox(); gb_lp.title = "Laser position";
 
  var btn_mu = PushButton ("Move up");
  btn_mu["sigPressed()"].connect(move_up);
  btn_mu.font = font_manual_btns; btn_mu.setFixedSize(120,40);
  gb_lp.add(btn_mu);
  
  gb_lp.newColumn();
  var btn_md = PushButton ("Move down");
  btn_md["sigPressed()"].connect(move_down);
  btn_md.font = font_manual_btns; btn_md.setFixedSize(120,40);
  gb_lp.add(btn_md);
  
  gb_lp.newColumn();
  var btn3 = PushButton ("STOP!");
  btn3["sigPressed()"].connect(stop_axis);
  btn3.font = font_manual_btns; btn3.setFixedSize(120,40);
  gb_lp.add(btn3);  
  dialog.add(gb_lp);
  
   dialog.okButtonText = "Done"
   dialog.cancelButtonText = "Abort";
   
   //groupa " laser barrier"
   gb_lb = new GroupBox(); gb_lb.title ="Laser barrier";
   
   var btn_barriera_up = PushButton("Barrier up");
   btn_barriera_up["sigPressed()"].connect(barrier_up);
   btn_barriera_up.font = font_manual_btns; btn_barriera_up.setFixedSize(140,40);
   gb_lb.add(btn_barriera_up);
  
   gb_lb.newColumn();
   
   var btn_bar_down = PushButton("Barrier down");
   btn_bar_down["sigPressed()"].connect(barrier_down);
   btn_bar_down.font = font_manual_btns; btn_bar_down.setFixedSize(140,40);
   gb_lb.add(btn_bar_down);

   dialog.add(gb_lb);
  
   //manual laser marking group    
    gb_mark = new GroupBox("Manual Laser Marking");
   
    cmb = new ComboBox("Select type", part_list);
    cmb.font = font_manual_btns;
    gb_mark.add(cmb);
   
    /*
    num = new NumberEdit("Prosim vnesite količino: ", 1);
    num.decimals = 0;  num.minimum = 1;
      
    num["sigNumberChanged(double)"].connect(onLneChange);
    num["sigOutOfRange()"].connect(onOutOfRange);
    gb_mark.add( num );	
	*/
    
    selectedLogo = new Label(txt_selected_logo + "/"); 
    gb_mark.add(selectedLogo);
       
    gb_mark.newColumn();
    var btn = PushButton ("ZAPIŠI!");
    btn["sigPressed()"].connect(readFile_manual);
    btn.setFixedSize(150,50);
    btn.font =  font_manual_btns;
    gb_mark.add(btn);
    
    
    var btn_stop_m = PushButton ("STOP MARKING!");
    btn_stop_m["sigPressed()"].connect(stop_m_manual);
    btn_stop_m.setFixedSize(150,50);
    btn_stop_m.font = font_manual_btns;
    gb_mark.add(btn_stop_m);
     
    dialog.add(gb_mark);
    
    status_box = new GroupBox(); status_box.title= "Status";
    dialog.add(status_box);
    
    lbl_auto_status_m = new Label(); lbl_auto_status.text = "Auto mode: " + auto_mode;
    lbl_auto_status_m.font = font_lbls;
    status_box.add(lbl_auto_status_m);
    
    lbl_marking_m = new Label(); lbl_marking.text = "Laser status :" + laser_status;
    lbl_marking_m.font = font_lbls;
    status_box.add(lbl_marking_m);
    
    
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
    
    lb_bar_gore = new Label(); lb_bar_gore.text = "Barijera gore: " + get_stat(bar_gore);
    lb_bar_gore.font = font_lbls;
    gb_outputs.add(lb_bar_gore);
    
    lb_bar_dolje = new Label(); lb_bar_dolje.text = "Barijera dolje: " + get_stat(bar_dolje);
    lb_bar_dolje.font = font_lbls;
    gb_outputs.add(lb_bar_dolje);
    
    dialog.show();   
   
    start_timer(time_ms, gui_update);
     dialog.exec();
}

function gui_update(ID)
{
   
    if (timer1 == ID)
      {	
	//print("tick");
	lbl1.text = "Z axis current position: " + Math.round(Axis.getPosition(2));
                lbl_auto_status_m.text= lbl_auto_status.text = "Auto mode: " + auto_mode;
	lbl_marking_m.text = lbl_marking.text = "Laser status :" + laser_status;	
	
	
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

function sb1_ch(value)
{
    //print(value);
    sb1_v = value;
}

function get_stat(input)
{
    if(input == 1 ){stat= "Active";} else {stat="Inactive";}
    return stat;
}


