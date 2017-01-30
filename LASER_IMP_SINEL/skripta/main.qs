
Date.prototype.mmyy = function(){
    var mm = this.getMonth() + 1;
    var yy =  this.getFullYear();
    yy = yy.toString();
    yy = yy.slice(2);

    return [(mm>9 ? '' : '0') + mm,
            "/",
            yy,
            ].join('');
};

Date.prototype.ddmmyytime = function(){
      var mm = this.getMonth() +1;
      var yy = this.getFullYear();
      yy = yy.toString(); 

      var dd = this.getDate() ;    
      var uhr = this.getHours()+1;  
      var min = this.getMinutes() ;      
      var sec = this.getSeconds() ;
      var time = this.getTime();
      return[(dd>9 ? '' : '0') + dd,
	     "/",
	     (mm>9 ? '' : '0') + mm,
	     "/",
	     yy,
	     "-",
	     (uhr>9 ? '' : '0') + uhr,
	     ":",
	     (min>9 ? '' : '0') + min,
	     ":",
	     (sec>9 ? '' : '0') + sec,
	     ].join('');
};

/*
  Read inputs and sets flags
  */
function set_flags()
{
    if(IoPort.getPort(0) & I_PIN_7){ sen_linija = 1;} else{sen_linija=0;}
    if(IoPort.getPort(0) & I_PIN_8){ sen_laser_dolje = 1;} else{sen_laser_dolje = 0;}
    if(IoPort.getPort(0) & I_PIN_9){ sen_laser_gore = 1;} else{sen_laser_gore = 0;}
    if(IoPort.getPort(0) & I_PIN_10){ sen_optika = 1;} else{sen_optika = 0;}
    if(IoPort.getPort(0) & I_PIN_11){ sen_bar_dolje = 1;} else{sen_bar_dolje = 0;}
    if(IoPort.getPort(0) & I_PIN_21){ sen_bar_gore = 1;} else{sen_bar_gore = 0;}
    if(IoPort.getPort(0) & I_PIN_20)
    {
        reg_fault =1;
    }
    else
    {
        reg_fault =0;
        if(debug_mode){print("!!!!!*****REGULATOR FAULT, CHECK MOTOR REGULATOR****!!!!");}
    }

    if(IoPort.getPort(0) & I_PIN_19)
    {
        reset_tipka = 1;
        reset_button_func();
    }
    else
    {
        reset_tipka = 0;
    }
    
    if(IoPort.getPort(0) & I_PIN_12)
    {
        total_stop = 1;
        total_stop_func();
        reset_sequence();
        if(brake_status == 0)
        {
            enable_break()
        };
    }
    else
    {
        if(brake_status == 1)
        {
            disable_break()
        };
        total_stop = 0;
    }
}

/*
  Counts pumps and sets pump_present flag
  */
function pump_counter(ID)
{
    if(timers[3] == ID)
    {
        if(IoPort.getPort(0) & I_PIN_7){senz_state = 1;} else{senz_state = 0;}

        if(senz_state != last_senz_state)
        {

            if(senz_state == 1)
            {
                brojac++;
                if(debug_mode){print("pump counter: " + brojac);}
                pump_present = 1;
            }
            else
            {
                if(debug_mode){ print("pump left");}
                pump_present = 0;
            }
        }
        last_senz_state = senz_state;
    }
}


function init_func()
{
    var nm;
    System.makeCounterVariable("num_writes", 0, 0, nm, 1, 1, 0, 3, 10, true );
    
    //Connects function set_flags() to trigger on input signal change
    IoPort.checkPort(0);
    IoPort.sigInputChange.connect(set_flags);
    
    //Initial flags setup
    set_flags();
    
    //Generates parts_list[] from excel database
    parts_list_gen();
    new_parts_list();

    reset_sequence();
    
    //Pump counter and laser movement functions connection
    System["sigTimer(int)"].connect(pump_counter);
    System["sigTimer(int)"].connect(laser_movement);

    if ((typeof part_list != "undefined") && (reg_fault == 0))
    {
        return 0;
    }
    if(typeof part_list == "undefined")
    {
        return 1;
    }
    if(reg_fault == 1)
    {
        return 2;
    }
}

function main()
{
    System.sigQueryStart.connect(onQueryStart);
    System.sigLaserStop.connect(onLaserStop);
    System.sigLaserStart.connect(onLaserStart);
    System.sigLaserEnd.connect(onLaserEnd);
    System["sigLaserEvent(int)"].connect(get_laser_events);
    System["sigLaserError(int)"].connect(onLaserError);
    System.sigClose.connect(onClose);

    //Starts initialization function, if success GUI is generated
    init_func();
    init_passed = init_func();
    if(init_passed == 0)
    {
        disable_break();
        signal_ready = 1;
        System["sigTimer(int)"].connect(set_signal_ready);
        print("Init passed");
        if(Axis.isReversed(2)){Axis.reset(2);}else{print("Z axis not reversed");}
        gen_dialog(part_list);
    }
    if(init_passed == 1)
    {
        print("Initialization failed, check if files are present in specified directories...")
        stop_axis();
        error_init_fail();
    }
    if(init_passed == 2)
    {
        error_regulator_fault();
    }
}
