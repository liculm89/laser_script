
//Timers declaration
var time_ms = 10;
var timer1 = System.setTimer(time_ms);    //gui_update();

var time5_ms = 300;
var timer5 = System.setTimer(time5_ms);   //wait_for_pump();

var time6_ms = 7000;
var timer6 = System.setTimer(time6_ms);   //barrier_up_after_marking();

var time7_ms = 20;
var timer7 = System.setTimer(time7_ms);   //stop_search(); stop_search_auto();

var time9_ms = 600;
var timer9 = System.setTimer(time9_ms);   //wait_for_barrier();

var time10_ms = 500;
var timer10 = System.setTimer(time10_ms);     //reset_laser_marking();

var time11_ms = 60;
var timer11 = System.setTimer(time11_ms); //pump_not_present();

var time12_ms = 100;
var timer12 = System.setTimer(time12_ms);     //pump_counter();

var timer_list = [];

function start_timer(timer, func)
{
    //print("connecting timer:" + timer);
    System["sigTimer(int)"].connect(func);

    var count = 0;
    timer_list.forEach(function (item)
    {
        if(func == item)
        {
            print("timer already on list")
            count++;
        }
    });

    if(count == 0)
    {
        timer_list.push(func);
    }
}

function disconnect_func(func)
{
    if (timer_list != 0)
    {
        System["sigTimer(int)"].disconnect(func);
        timer_list.forEach(function (item, index)
        {
            if (func == item)
            {
                timer_list.splice(index, 1);
            }
        });
        //print("disconnect func timer list ----------------------:"+timer_list);
    }
}

function disconnect_timers()
{
    if (timer_list != 0)
    {
        timer_list.forEach(function (item, index)
        {
            //print("funkcija **********************:"+ item);
            System["sigTimer(int)"].disconnect(item);
            timer_list.splice(index, 1);
        });
        
    }
}
