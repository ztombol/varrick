/*
 * Rasterise the element with ID `capture'.
 */

var system = require('system');

if (system.args.length != 3) {
    console.log('Usage: rasterize.js <URL> <output>');
    phantom.exit(1);
}

var page = require('webpage').create(),
    address = system.args[1],
    output = system.args[2];

page.open(address, function (status) {
    if (status !== 'success') {
        console.log('Unable to load the address!');
        phantom.exit(1);
    } else {
        window.setTimeout(function () {
            var clipRect = page.evaluate(function() {
                return document.querySelector('#capture').getBoundingClientRect();
            });
            page.clipRect = {
                top:    clipRect.top,
                left:   clipRect.left,
                width:  clipRect.width,
                height: clipRect.height
            };
            page.render(output);
            phantom.exit();
        }, 200);
    }
});
