//////////////////////////////////////////////
//Timers declaration
//////////////////////////////////////////////
var times = [10, 20, 60, 100, 300, 500, 600, 7000, 1000];

var timers = Array.apply(null, new Array(times.length)).map(Number.prototype.valueOf,0);
var timer_list = [];
//////////////////////////////////////////////
//Setting up global timers
//////////////////////////////////////////////
times.forEach(function (item, index)
{
    timers[index] = System.setTimer(item);
    if(debug_mode){print("timers["+index+"] : " + timers[index]);}
});
//////////////////////////////////////////////
//Connects given function
//////////////////////////////////////////////
function start_timer(timer, func)
{
    if(debug_mode){print("connecting timer:" + timer);}
    System["sigTimer(int)"].connect(func);

    var count = 0;
    timer_list.forEach(function (item)
    {
        if(func == item)
        {
            if(debug_mode){print("timer already on list");}
            count++;
        }
    });

    if(count == 0)
    {
        if(debug_mode){ print("adding timer to list");}	
        timer_list.push(func);
    }
}

//////////////////////////////////////////////
//Disconnects given function
/////////////////////////////////////////////
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
    }
}

////////////////////////////////////////////////////////
//Disconnect all timers in timer_list
///////////////////////////////////////////////////////
function disconnect_timers()
{
    if (timer_list != 0)
    {
        timer_list.forEach(function (item, index)
        {
            System["sigTimer(int)"].disconnect(item);
            timer_list.splice(index, 1);
        });
        
    }
}
