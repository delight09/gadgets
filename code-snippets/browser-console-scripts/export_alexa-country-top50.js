// Fetch csv data for alexa country top web page
// Example page https://www.alexa.com/topsites/countries/CN

if (!String.prototype.removeLineFeed) {
    String.prototype.removeLineFeed = function() {
        return this.replace(/(\r\n|\n|\r)/gm,"");
    };
}


a=[];
row=document.querySelectorAll('.site-listing');

row.forEach(function (e) {
    _div_rank = e.querySelector('.number');
    _div_name = e.querySelector('.DescriptionCell').querySelector('a');
    _s = _div_rank.innerText.removeLineFeed() + ', ' + _div_name.innerText.removeLineFeed() + ', ';

    _arr_div_right = e.querySelectorAll('.right');
    _arr_div_right.forEach(function (_e) {
        _s += _e.innerText.removeLineFeed() + ', ';
    });

    a.push(_s);
})


var hiddenElement = document.createElement('a');
var textToSave = "";
a.forEach(function (i) { textToSave += i + '\n'; })

hiddenElement.href = 'data:attachment/text,' + encodeURI(textToSave);
hiddenElement.target = '_blank';
hiddenElement.download = 'Alexa_country_top50.csv';
hiddenElement.click();
// HTML5 JS variable saving
// Credit to https://stackoverflow.com/a/24898081

