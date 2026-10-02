using Toybox.Application as Application;

class HypnosApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    function onStart(state) {
    }

    function onStop(state) {
    }

    function getInitialView() {
        return [ new HypnosView() ];
    }
}
