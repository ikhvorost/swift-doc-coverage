// DLog.js

Object.defineProperty(global, '__stack', {
    get: function() {
        var orig = Error.prepareStackTrace;
        Error.prepareStackTrace = function(_, stack) {
            return stack;
        };
        var err = new Error;
        Error.captureStackTrace(err, arguments.callee);
        var stack = err.stack;
        Error.prepareStackTrace = orig;
        return stack;
    }
});

const log = (type, args) => {
    const filePath = __stack[2].getFileName();
    const fileName = filePath.substring(filePath.lastIndexOf('/') + 1);
    const line = __stack[2].getLineNumber();

    const r = new RegExp('T(.*)Z');
    const time = (new Date()).toISOString().match(r)[1];
    console.log('•', time, '[DLOG]', type, `<${fileName}:${line}>`, args.join(' '));
}

const info = (...args) => {
    log('✅ [INFO]', args);
};

const debug = (...args) => {
    log('▶️ [DEBUG]', args);
};

const error = (...args) => {
    log('⚠️ [ERROR]', args);
};

module.exports = {
    info,
    debug,
    error,
};