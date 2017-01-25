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
	reg_fault = 0;
    } 
    else
    {
	reg_fault = 1;
	print("!!!!!*****REGULATOR FAULT, CHECK MOTOR REGULATOR****!!!!");
	//error_regulator_fault();
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
        if(brake_status == 0){enable_break()};
    }
    else
    {   
        if(brake_status == 1){disable_break()};
        total_stop = 0;
    }
}

function enable_break()
{
    IoPort.resetPort(0, O_PIN_5);
    brake_status = 1;
    if(debug_mode){print("Brake active")}
}

function disable_break()
{
     IoPort.setPort(0, O_PIN_5); 
     brake_status = 0;
     if(debug_mode){print("Brake disabled")}
}

var senz_state = 0; 
last_senz_state = 0;
pump_present = 0;
var brojac = 0;
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

var laser_poz_before = Axis.getPosition(2);
var laser_poz_cur =  Axis.getPosition(2);
var laser_moving = 0;

/*
  Checks if laser is moving
  */
function laser_movement(ID)
{
    if(timers[4] == ID)
    {
        laser_poz_cur = Axis.getPosition(2);
        if(laser_poz_cur != laser_poz_before)
        {
            laser_moving = 1;
            signal_ready = 0;
        }
        else
        {
            laser_moving = 0;
            signal_ready = 1;
        }
        laser_poz_before = laser_poz_cur;
    }
}

function set_signal_ready(ID)
{
    if((timers[0] == ID)  && (signal_ready == 1))
    {
            IoPort.setPort(0, O_PIN_2); 
    }
    if((timers[0] == ID) && (signal_ready == 0))
    {
            IoPort.resetPort(0, O_PIN_2); 
    }
    
    if((timers[0] == ID) && (auto_mode == "OFF") && (laser_in_working_pos == 1) && (IoPort.getPort(0) & I_PIN_11))
    {
           IoPort.resetPort(0, O_PIN_2); 
    }
 }

/*
function onLneChange(text) 
{print("onLneChange("+text+")");}

function onOutOfRange () 
{print("onOutOfRange()");}
*/

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
