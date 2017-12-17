// Usage:
// phantomjs --ssl-protocol=any /path/to/steamrecent_domcapture.js 'http://steamcommunity.com/id/dummyred' /tmp/steam_showbox.jpg
// If element is not found, it will fetch the complete page
// Works with phontomjs 2.0 (does not work with 1.9)
// Credit to https://gist.github.com/sairam/d6989248f405de3e617d8ded1767ccdf

"use strict";
var page = require('webpage').create(),
    system = require('system'),
    address, output, size;

page.customHeaders = {
	  "Accept-Language": "zh"
};

//capture and captureSelector functions adapted from CasperJS - https://github.com/n1k0/casperjs
var capture = function(targetFile, clipRect) {
    var previousClipRect;
    if (clipRect) {
        // if (!isType(clipRect, "object")) {
        //     throw new Error("clipRect must be an Object instance.");
        // }
        previousClipRect = page.clipRect;
        page.clipRect = clipRect;
        console.log('Capturing page to ' + targetFile + ' with clipRect' + JSON.stringify(clipRect), "debug");
    } else {
        console.log('Capturing page to ' + targetFile, "debug");
    }
    try {
        page.render(targetFile);
    } catch (e) {
        console.log('Failed to capture screenshot as ' + targetFile + ': ' + e, "error");
        phantom.exit(1);
    }
    if (previousClipRect) {
        page.clipRect = previousClipRect;
    }
    return this;
}

var captureSelector = function(targetFile, selector) {
  var vresponse = page.evaluate(function(selector) {
      try {
          var clipRect = document.querySelector(selector).getBoundingClientRect();
          console.log("clip rect" + clipRect.top, "debug");
          console.table(clipRect);
          return {
              top: clipRect.top,
              left: clipRect.left,
              width: clipRect.width,
              height: clipRect.height
          };
      } catch (e) {
        console.log(e, 'debug');
          console.log("Unable to fetch bounds for element " + selector, "debug");
      }
  }, selector);
  console.table(vresponse.top, 'debug');
  console.table(vresponse.left, 'debug');

    return capture(targetFile, vresponse);
}

if (system.args.length < 3 || system.args.length > 5) {
    console.log('Usage: rasterize.js URL filename [paperwidth*paperheight|paperformat] [zoom]');
    console.log('  paper (pdf output) examples: "5in*7.5in", "10cm*20cm", "A4", "Letter"');
    console.log('  image (png/jpg output) examples: "1920px" entire page, window width 1920px');
    console.log('                                   "800px*600px" window, clipped to 800x600');
    phantom.exit(1);
} else {
    address = system.args[1];
    output = system.args[2];
    page.viewportSize = { width: 350, height: 1600 };
    if (system.args.length > 3 && system.args[2].substr(-4) === ".pdf") {
        size = system.args[3].split('*');
        page.paperSize = size.length === 2 ? { width: size[0], height: size[1], margin: '0px' }
                                           : { format: system.args[3], orientation: 'portrait', margin: '1cm' };
    } else if (system.args.length > 3 && system.args[3].substr(-2) === "px") {
        size = system.args[3].split('*');
        if (size.length === 2) {
            pageWidth = parseInt(size[0], 10);
            pageHeight = parseInt(size[1], 10);
            page.viewportSize = { width: pageWidth, height: pageHeight };
            page.clipRect = { top: 0, left: 0, width: pageWidth, height: pageHeight };
        } else {
            console.log("size:", system.args[3]);
            pageWidth = parseInt(system.args[3], 10);
            pageHeight = parseInt(pageWidth * 3/4, 10); // it's as good an assumption as any
            console.log ("pageHeight:",pageHeight);
            page.viewportSize = { width: pageWidth, height: pageHeight };
        }
    }
    if (system.args.length > 4) {
        page.zoomFactor = system.args[4];
    }
    page.open(address, function (status) {
        if (status !== 'success') {
            console.log('Unable to load the address!');
            phantom.exit(1);
        } else {
            window.setTimeout(function () {
		    try {
                         captureSelector(output,'.recent_game_content');
		    }
		    catch(err) {
            console.log('Page content invalid');
              phantom.exit();
		    }
              phantom.exit();
            }, 200);
        }
    });
}
