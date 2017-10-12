//////////////////////////////////////////////
//Timers declaration
//////////////////////////////////////////////
var times = [10, 61, 121, 151, 301, 501, 601, 9001, 1001, 401, 551,241, 852, 43, 98, 504, 47];
/////////////////    0    1     2      3      4     5       6       7       8         9        10    11   12      13    14  15  16////////////////
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

    System["sigTimer(int)"].connect(func);
    var count = 0;
    timer_list.forEach(function (item) {
        if (func == item) {
            count++;
        }
    });
    if (count == 0) {
        timer_list.push(func);
    }
}

function disconnect_func(func) {
    if (timer_list != 0) {
        timer_list.forEach(function (item, index) {
            if (func == item) {
                System["sigTimer(int)"].disconnect(func);
		        System.killTimer(index);
                timer_list.splice(index, 1);
            }
        });
    }
	System.collectGarbage();
}

////////////////////////////////////////////////////////
//Disconnect all timers in timer_list
///////////////////////////////////////////////////////
function disconnect_timers() {

    if (timer_list != 0) {
        timer_list.forEach(function (item, index) {
            System["sigTimer(int)"].disconnect(item);
            timer_list.splice(index, 1);
        });
    }
	System.collectGarbage();
}

function gen_timer(timer_id, func)
{
    delete timers[timer_id];
    timers[timer_id] = System.setTimer(times[timer_id]);
    start_timer(timers[timer_id], func);
    System.collectGarbage();
}