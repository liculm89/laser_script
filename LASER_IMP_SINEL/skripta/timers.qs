//////////////////////////////////////////////
//Timers declaration
//////////////////////////////////////////////
var times = 
[
    10,     //0
    61,     //1
    121,    //2    
    151,    //3
    301,    //4
    501,    //5
    601,    //6
    9001,   //7
    1001,   //8
    401,    //9
    551,    //10
    241,    //11
    852,    //12
    43,     //13    
    98,     //14
    504,    //15
    47      //16
];

var timers = Array.apply(null, new Array(times.length)).map(Number.prototype.valueOf, 0);
var timer_list = [];

///////////////////////////////////////////////////////////
//Setting up global timers
///////////////////////////////////////////////////////////
times.forEach(function (item, index) {
    timers[index] = System.setTimer(item);
});

///////////////////////////////////////////////////////////
//Connects given function
///////////////////////////////////////////////////////////
function start_timer(timer, func) {
    //System["sigTimer(int)"].connect(func);
    var count = 0;
    timer_list.forEach(function (item) {
        if (func == item) {
            count++;
        }
    });
    if (count == 0) {
        System["sigTimer(int)"].connect(func);
        write_log("Connected timer: " + timer + ",to func: " + func.name)
        timer_list.push(func);
    }
}

function disconnect_func(func, t_ID) {
    if (timer_list != 0) {
        timer_list.forEach(function (item, index) {
            if (func == item) {
                System["sigTimer(int)"].disconnect(func);
		
                System.killTimer(t_ID);
                write_log("Killed timer: " + t_ID + ",that was connected to func: " + func.name)
                timer_list.splice(index, 1);
            }
        });
    }
    System.collectGarbage();
}

/*
function disconnect_func(func) {
    if (timer_list != 0) {
        timer_list.forEach(function (item, index) {
            if (func == item) {
                System["sigTimer(int)"].disconnect(func);
                System.killTimer(index);
                write_log("Killed timer: " + timers[index] + ",that was connected to func: " + func.name)
                timer_list.splice(index, 1);
            }
        });
    }
    System.collectGarbage();
}*/

////////////////////////////////////////////////////////
//Disconnect all timers in timer_list
///////////////////////////////////////////////////////
function disconnect_timers() {

    if (timer_list != 0) {
        timer_list.forEach(function (item, index) {
            System["sigTimer(int)"].disconnect(item);
            //System.killTimer(index);
            //System.killTimer(timers[index]);
           // write_log("Killed timer: " + index + ",that was connected to func: " + func.name + " (dc_timers)")
            timer_list.splice(index, 1);
        });
    }
    //System.killAllTimers();
    System.collectGarbage();
}

function gen_timer(timer_id, func) {
    //delete timers[timer_id];
    timers[timer_id] = System.setTimer(times[timer_id]);
    start_timer(timers[timer_id], func);
    System.collectGarbage();
}