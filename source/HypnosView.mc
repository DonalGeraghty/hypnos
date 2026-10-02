using Toybox.ActivityMonitor as ActivityMonitor;
using Toybox.Complications as Complications;
using Toybox.Graphics as Graphics;
using Toybox.Lang as Lang;
using Toybox.System as System;
using Toybox.Time as Time;
using Toybox.Time.Gregorian as Gregorian;
using Toybox.WatchUi as WatchUi;

class HypnosView extends WatchUi.WatchFace {

    var _lowPower = false;
    var _bodyBatteryId;
    var _heartRateId;

    function initialize() {
        WatchFace.initialize();

        _bodyBatteryId = new Complications.Id(
            Complications.COMPLICATION_TYPE_BODY_BATTERY
        );
        _heartRateId = new Complications.Id(
            Complications.COMPLICATION_TYPE_HEART_RATE
        );
    }

    function onUpdate(dc) {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();

        if (_lowPower) {
            drawLowPower(dc);
            return;
        }

        drawFullFace(dc);
    }

    function drawFullFace(dc) {
        var width = dc.getWidth();
        var height = dc.getHeight();
        var centerX = width / 2;

        var clock = getClockText();
        var date = getDateText();
        var bodyBattery = getComplicationValue(_bodyBatteryId);
        var heartRate = getComplicationValue(_heartRateId);
        var steps = getStepsText();
        var battery = getBatteryText();

        // Primary recovery metric.
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
        dc.drawText(
            centerX,
            (height * 17) / 100,
            Graphics.FONT_MEDIUM,
            "BB " + bodyBattery,
            Graphics.TEXT_JUSTIFY_CENTER
        );

        // Time is intentionally the visual focus.
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.drawText(
            centerX,
            (height * 34) / 100,
            Graphics.FONT_NUMBER_HOT,
            clock,
            Graphics.TEXT_JUSTIFY_CENTER
        );

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
        dc.drawText(
            centerX,
            (height * 55) / 100,
            Graphics.FONT_SMALL,
            date,
            Graphics.TEXT_JUSTIFY_CENTER
        );

        // Secondary metrics are kept comfortably inside the round display.
        var bottomY = (height * 72) / 100;
        dc.drawText(
            (width * 25) / 100,
            bottomY,
            Graphics.FONT_SMALL,
            "HR " + heartRate,
            Graphics.TEXT_JUSTIFY_CENTER
        );
        dc.drawText(
            (width * 50) / 100,
            bottomY,
            Graphics.FONT_SMALL,
            steps,
            Graphics.TEXT_JUSTIFY_CENTER
        );
        dc.drawText(
            (width * 75) / 100,
            bottomY,
            Graphics.FONT_SMALL,
            battery,
            Graphics.TEXT_JUSTIFY_CENTER
        );
    }

    function drawLowPower(dc) {
        var centerX = dc.getWidth() / 2;
        var centerY = dc.getHeight() / 2;

        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);
        dc.drawText(
            centerX,
            centerY,
            Graphics.FONT_NUMBER_MILD,
            getClockText(),
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }

    function getClockText() {
        var clock = System.getClockTime();
        var hour = clock.hour;

        if (!System.getDeviceSettings().is24Hour) {
            hour = hour % 12;
            if (hour == 0) {
                hour = 12;
            }
        }

        return Lang.format("$1$:$2$", [
            hour.format("%02d"),
            clock.min.format("%02d")
        ]);
    }

    function getDateText() {
        var today = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);

        return Lang.format("$1$ $2$ $3$", [
            today.day_of_week,
            today.day.format("%02d"),
            today.month
        ]);
    }

    function getComplicationValue(id) {
        try {
            var complication = Complications.getComplication(id);
            if (complication != null && complication.value != null) {
                return complication.value.toString();
            }
        } catch (ex) {
            System.println("Hypnos: complication unavailable");
        }

        return "--";
    }

    function getStepsText() {
        try {
            var info = ActivityMonitor.getInfo();
            if (info != null && info.steps != null) {
                return info.steps.toString();
            }
        } catch (ex) {
            System.println("Hypnos: steps unavailable");
        }

        return "--";
    }

    function getBatteryText() {
        try {
            var stats = System.getSystemStats();
            if (stats != null) {
                return (stats.battery + 0.5).toNumber().toString() + "%";
            }
        } catch (ex) {
            System.println("Hypnos: battery unavailable");
        }

        return "--";
    }

    function onEnterSleep() {
        _lowPower = true;
        WatchUi.requestUpdate();
    }

    function onExitSleep() {
        _lowPower = false;
        WatchUi.requestUpdate();
    }
}
