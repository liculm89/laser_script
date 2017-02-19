///////////////////////////////////////////////////
//TIME AND DATE FORMATING
///////////////////////////////////////////////////
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
    var uhr = this.getHours();
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

date_year = new Date();
date_year = date_year.getFullYear().toString().slice(2);

//////////////////////
//String to dict
///////////////////////
function to_dict(from_str, c1, c2, split)
{
    var arr = from_str;
    arr = arr.split(split);
    var arr_s = arr.slice(arr.indexOf(c1), arr.indexOf(c2) + 1);
    var dict = {};
    arr_s.forEach(function(item)
    {
        dict[item] = "init_value";
    })
    return dict;
}

//////////////////////////
//String to array
/////////////////////////
function to_arr(from_str, c1, c2)
{
    var arr;
    arr = from_str;
    arr = arr.split(" ");
    var arr_s;
    arr_s = arr.slice(arr.indexOf(c1), arr.indexOf(c2) + 1);
    return arr_s;
}

//////////////////////////////////////////////////
//Removes duplicates from array
//////////////////////////////////////////////////
function remove_duplicates(arr)
{
    var m = {}, newarr = []
    for (var i = 0; i < arr.length; i++){
        var v = arr[i];
        if(!m[v])
        {
            newarr.push(v);
            m[v]= true;
        }
    }
    return newarr;
}

////////////////////////////////
//S.N. Format check
////////////////////////////////
function check_sn_format_imp(sn)
{
    if((columns_dict["M"]  == "ebara") || (ebara_reg.test(columns_dict["M"])))
    {
        if(sn.length == 11)
        {
            return true;
        }
        else
        {
            return false;
        }
    }
    else
    {
        if ( (imp_reg.test(sn)) && (sn.length == 9))
        {
            return true;
        }
        else
        {
            return false;
        }
    }
}

////////////////////////////////////
//Ebara prefix creation
///////////////////////////////////
function get_ebara_prefix()
{
    var S; var P; var M; var LP; var AF;
    var date = new Date();
    var year =  date.getFullYear().toString();
    var month = (date.getMonth() + 1);
    S = "S";
    AF = "AF";

    switch(year)
    {
    case "2017":
        P = "W";
        break;
    case "2018":
        P = "X";
        break;
    case "2019":
        P = "Y";
        break;
    }
    switch(month)
    {
    default:
        M = month.toString();
        break;
    case 10:
        M = "X";
        break;
    case  11:
        M = "Y";
        break;
    case  12:
        M = "Z";
        break;
    }
    var ebara_prefix = S+P+M+AF;
    return(ebara_prefix);
}

//////////////////////////////////////////////////////////////////////////////////////
//Add zeros to nubmer if number to reach targetLength
/////////////////////////////////////////////////////////////////////////////////////
function leftPad(number, targetLength)
{
    var output = number.toString();
    while(output.length < targetLength)
    {
        output = '0' + output;
    }
    return output;
}

///////////////////////////////////
//get serial number int
//////////////////////////////////
function get_serial_int(sn_str)
{
    var serial_str = sn_str;
    var serial_int;
    if((columns_dict["M"]  == "ebara") || (ebara_reg.test(columns_dict["M"])))
    {
        serial_str = serial_str.slice(5);
        serial_int = parseInt(serial_str, 10);
    }
    else
    {
        serial_str = serial_str.slice(3);
        serial_int = parseInt(serial_str, 10);
    }
    return serial_int;
}

/*function generate_regex()
{
    switch(date_year)
    {
    case 17:



    }

}*/
