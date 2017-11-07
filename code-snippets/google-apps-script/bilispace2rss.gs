if (!String.prototype.encodeHTML) {
    String.prototype.encodeHTML = function() {
        return this.replace(/&/g, '&amp;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;')
            .replace(/"/g, '&quot;')
            .replace(/'/g, '&apos;');
    };
} // credit to https://stackoverflow.com/a/847196/4349454


var feed_size = 10;
var contributor = 'delight09@github, maijver@twitter';

function doGet(request) {
    var mid = request.parameter.mid;
    var noplayer = request.parameter.noplayer;

    if (mid && !isNaN(mid)) {
        // 构造请求参数
        var referer = "http://space.bilibili.com/" + mid + "/";
        var reqHeaders = {
            "User-Agent": "Moeela/5.0 (X1337; Wonders x86_64) AppleWebKit/666 (KHTML, like Gecko) Chrome/666 Safari/666",
            "Referer": referer,
        };
        var reqVidListOptions = {
            "headers": reqHeaders
        };

        // 使用API获得mid的视频列表元数据
        var api_getVidList = "http://space.bilibili.com/ajax/member/getSubmitVideos?mid=" + mid + "&pagesize=" + feed_size + "&page=1"
        var resp_getVidList = UrlFetchApp.fetch(api_getVidList, reqVidListOptions);
        var data = JSON.parse(resp_getVidList.getContentText())['data']['vlist'];
        var feed_title = data[0]['author']; // getInfo API被拒，复用API获取昵称

        // 构造feed数据头
        var feed = '<?xml version="1.0" encoding="utf-8" ?>' +
            '<feed xmlns="http://www.w3.org/2005/Atom">' +
            '<contributor><name>' + contributor + '</name></contributor>' +
            '<category term="entertainment" label="bilibili"/>' +
            '<title>' + feed_title + '的bilibili空间</title>' +
            '<subtitle>bilispace2rss - powered by Google Apps Script</subtitle>' +
            '<link href="' + referer + '" rel="alternate"/>' +
            '<id>' + referer + '</id>' +
            '<icon>http://www.bilibili.com/favicon.ico</icon>' +
            '<rights>Copyleft under BSD licenses 2017</rights>' +
            '<updated>' + (new Date()).toISOString() + '</updated>';

        // 填入entry
        var video_url ='';
        var video_cover ='';
        var video_anchor ='';
        var xml_feed_content ='';
        var video_player ='';
        data.forEach(function(e, i) {
            video_url = 'http://www.bilibili.com/video/av' + e.aid;
            video_cover = '<img src="' + e.pic + '" />'
            video_anchor = '<a href="' + video_url + '">' + video_cover + '<a>';
            xml_feed_content = video_anchor + '<br />' + e.description + '<br />'
            video_player = '<embed height="415" width="544" quality="high" allowfullscreen="true" type="application/x-shockwave-flash" src="https://static-s.bilibili.com/miniloader.swf?aid=' + e.aid + '"></embed>'
            // video_player credit to https://gist.github.com/mycccc/3c3024f486e4230ecf5c5879f3b7470e/revisions

            if (isNaN(noplayer) || noplayer == 0) { // 默认feed包括播放器
                xml_feed_content += video_player
            }

            feed += '<entry>' +
                '<title>' + e.title.encodeHTML() + '</title>' +
                '<link href="' + video_url + '" />' +
                '<updated>' + (new Date(e.created * 1000)).toISOString() + '</updated>' +
                '<content type="html">' + xml_feed_content.encodeHTML() + '</content>' +
                '<summary>' + e.description.encodeHTML() + '</summary>' +
                '<author><name>' + e.author.encodeHTML() + '</name></author>' +
                '</entry>'
        });

        feed += '</feed>'

        return ContentService.createTextOutput(feed)
            .setMimeType(ContentService.MimeType.RSS);
    }
    return HtmlService.createHtmlOutput("<h2>Invalid Bilibili MemberId</h2>");
}
