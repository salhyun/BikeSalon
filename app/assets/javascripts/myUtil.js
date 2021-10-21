function getDateString(date) {
    let dd = date.getDate();
    let mm = date.getMonth()+1;//january is 0
    let yyyy = date.getFullYear();

    if(dd<10) {
        dd = '0'+dd;
    }
    if(mm<10) {
        mm = '0'+mm;
    }
    let result = yyyy + '-' + mm + '-' + dd;
    return result;
}
function getDateSerializedString(date, showtime=false) {
    let dd = date.getDate();
    let mm = date.getMonth()+1;//january is 0
    let yyyy = date.getFullYear().toString();

    if(dd<10) {
        dd = '0'+dd;
    } else {dd = dd.toString()}
    if(mm<10) {
        mm = '0'+mm;
    } else {mm = mm.toString()}

    let result = yyyy + mm + dd;
    if(showtime) {
        let hours = date.getHours();
        let minutes = date.getMinutes();
        let seconds = date.getSeconds();
        if(hours<10) {
            hours = '0'+hours;
        } else {hours = hours.toString()}
        if(minutes<10) {
            minutes = '0'+minutes;
        } else {minutes = minutes.toString()}
        if(seconds<10) {
            seconds = '0'+seconds;
        } else {seconds = seconds.toString()}
        result += hours + minutes + seconds;
    }
    return result;
}

function assert(condition, message) {
    if (!condition) {
        throw new Error(message || 'Assertion failed');
    }
}

function getNumberFromString(s) {
    let regex = /\d+/g;//getting number from string
    return parseInt(s.match(regex));
}

function getParameterByName(name) {
    name = name.replace(/[\[]/, "\\[").replace(/[\]]/, "\\]");
    let regex = new RegExp("[\\?&]" + name + "=([^&#]*)"),
        results = regex.exec(location.search);
    return results === null ? "" : decodeURIComponent(results[1].replace(/\+/g, " "));
}
function rgb2hex(orig){
    let rgb = orig.replace(/\s/g,'').match(/^rgba?\((\d+),(\d+),(\d+)/i);
    return (rgb && rgb.length === 4) ? "#" +
        ("0" + parseInt(rgb[1],10).toString(16)).slice(-2) +
        ("0" + parseInt(rgb[2],10).toString(16)).slice(-2) +
        ("0" + parseInt(rgb[3],10).toString(16)).slice(-2) : orig;
}
function checkCursorOnElement(x, y, obj) {
    let left = obj.get(0).offsetLeft;
    let top = obj.get(0).offsetTop;
    let right = left + obj.outerWidth();
    let bottom = top + obj.outerHeight();
    console.log('rect(' + left + ', ' + top + ', ' + right + ', ' + bottom + ')');
    if(left <= x && x <= right) {
        if(top <= y && y <= bottom)
            return true;
    }
    return false;
}
function randomRange(n1, n2) {
    return Math.floor( (Math.random() * (n2 - n1 + 1)) + n1 );
}
function getByteInLength(s,b,i,c){
    for(b=i=0;c=s.charCodeAt(i++);b+=c>>11?3:c>>7?2:1);
    return b;
}
function numberWithCommas(x) {
    return x.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
}
function intervalCall(interval){
    // interval 시간 안에 다시 호출된 함수 콜은 무시한다
    let elapsed = true
    return (fn) => {
        if(!elapsed){
            return    // 마지막 호출 후 제한된 경과시간이 지나지 않은 경우 리턴
        }
        elapsed = false
        fn()
        setTimeout(() => {elapsed = true}, interval)
    }
}
