if (!String.prototype.encodeHTML) {
    String.prototype.encodeHTML = function() {
        return this.replace(/&/g, '&amp;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;')
            .replace(/"/g, '&quot;')
            .replace(/'/g, '&apos;');
    };
} // credit to https://stackoverflow.com/a/7918944/4349454

var contributor = 'delight09@github';

function doGet(request) {
    var reqHeaders = {
        "User-Agent": "Moeela/5.0 (X1337; Wonders x86_64) AppleWebKit/666 (KHTML, like Gecko) Chrome/666 Safari/666",
    };
    var reqOptions = {
        "headers": reqHeaders
    };

    // 使用API
    var api_getHotTopic = "https://www.v2ex.com/api/topics/hot.json"
    var resp_getHotTopic = UrlFetchApp.fetch(api_getHotTopic, reqOptions);
    var data = JSON.parse(resp_getHotTopic.getContentText());

    // 构造feed数据头
    var feed = '<?xml version="1.0" encoding="utf-8" ?>' +
        '<feed xmlns="http://www.w3.org/2005/Atom">' +
        '<contributor><name>' + contributor + '</name></contributor>' +
        '<category term="forum" label="v2ex"/>' +
        '<title>V2EX - 最热主题</title>' +
        '<subtitle>v2exhot2rss - powered by Google Apps Script</subtitle>' +
        '<link href="https://www.v2ex.com" rel="alternate"/>' +
        '<id>https://www.v2ex.com</id>' +
        '<icon>https://www.v2ex.com/favicon.ico</icon>' +
        '<rights>Copyleft under BSD licenses 2017</rights>' +
        '<updated>' + (new Date()).toISOString() + '</updated>';

    // 填入entry
    var author = '';
    var authorLink = '';
    var postTitle = '';
    var postURL = '';
    var xml_postContent = '';
    var timestamp = '';
    var node = '';
    var nodeLink = '';
    var xml_feed_content = '';

    data.forEach(function(e, i) {
        author = e.member.username;
        authorLink = 'https://www.v2ex.com/member/' + author;
        avatarLink = e.member.avatar_normal;
        postTitle = e.title;
        postURL = e.url;
        str_postContent = e.content;
        xml_postContent = e.content_rendered;
        timestamp = e.created;
        node = e.node.title;
        nodeLink = e.node.url;

        xml_feed_content = '<table cellpadding="0" cellspacing="0" border="0" width="100%"><tbody><tr>' +
            '<td width="48" valign="top" align="center"><a href="' + authorLink + '"><img src="' + avatarLink +
            '" border="0" align="default"></a></td><td width="10"></td>' +
            '<td width="auto" valign="middle"><span><a href="' + postURL + '">' + postTitle + '</a></span>' +
            '<span><div></div><a href="' + nodeLink + '">' + node + '</a> &nbsp;•&nbsp; <strong><a href="' +
            authorLink + '">' + author + '</a></strong> &nbsp;•&nbsp; 创建于&nbsp;' + (new Date(timestamp * 1000)).toISOString() +
            '</span></td></tr></tbody></table><hr />' + xml_postContent;

        feed += '<entry>' +
            '<title>' + postTitle.encodeHTML() + '</title>' +
            '<link href="' + postURL + '" />' +
            '<updated>' + (new Date(timestamp * 1000)).toISOString() + '</updated>' +
            '<content type="html">' + xml_feed_content.encodeHTML() + '</content>' +
            '<summary>' + str_postContent.encodeHTML() + '</summary>' +
            '<author><name>' + author.encodeHTML() + '</name>' +
            '<uri>' + authorLink + '</uri></author>' +
            '<id>' + postURL + '</id>' +
            '</entry>'
    });

    feed += '</feed>'

    return ContentService.createTextOutput(feed)
        .setMimeType(ContentService.MimeType.RSS);
}
