using Toybox.ActivityMonitor as ActivityMonitor;
using Toybox.Graphics as Graphics;
using Toybox.Math as Math;
using Toybox.System as System;
using Toybox.WatchUi as WatchUi;

// Gear Sport-inspired palette: bright progress over a dim track, on true black.
const COLOR_STEPS = 0x3EE6F0;
const COLOR_STEPS_TRACK = 0x0C2E32;
const COLOR_INTENSITY = 0x3A86FF;
const COLOR_INTENSITY_TRACK = 0x0E2347;
const COLOR_HANDS = 0xFFFFFF;
const COLOR_RING_LABEL = 0xFFFFFF;
const COLOR_RING_LABEL_ON_FILL = 0x000000;
const COLOR_LOW_POWER = 0x5A6280;

// Used when the watch has no goal set.
const DEFAULT_STEP_GOAL = 10000;
const DEFAULT_INTENSITY_GOAL = 150;

// Simulator preview: draw sample values instead of real data.
// Set to false before building for the watch.
const USE_TEST_DATA = true;

// Each ring starts at its hand. true: the arc trails behind the hand
// (counter-clockwise), as on the Gear Sport. false: the arc runs ahead of it.
const RING_TRAILS_HAND = false;

class HypnosView extends WatchUi.WatchFace {

    var _lowPower = false;

    // Layout values, calculated once in onLayout from the screen size.
    var _centerX = 0;
    var _centerY = 0;
    var _outerRadius = 0;
    var _innerRadius = 0;
    var _outerWidth = 0;
    var _innerWidth = 0;
    var _minuteLength = 0;
    var _hourLength = 0;
    var _minuteWidth = 0;
    var _hourWidth = 0;
    var _pivotRadius = 0;
    // Vector font for the values that curve along the rings.
    var _ringLabelFont = null;
    // Ring icons sit at 6 o'clock, just inside each ring.
    var _iconSize = 0;
    var _stepsIconY = 0;
    var _intensityIconY = 0;

    function initialize() {
        WatchFace.initialize();
    }

    function onLayout(dc) {
        var width = dc.getWidth();

        _centerX = width / 2;
        _centerY = dc.getHeight() / 2;

        _outerRadius = width * 0.43;
        _innerRadius = width * 0.27;
        _outerWidth = width * 0.08;
        _innerWidth = width * 0.08;

        _minuteWidth = width * 0.013;
        _hourWidth = width * 0.02;
        _pivotRadius = width * 0.02;

        // Each hand reaches the outer edge of its ring, so it forms the ring's
        // start edge. The rounded tip is pulled in to sit flush with that edge.
        _minuteLength = _outerRadius + _outerWidth / 2 - _minuteWidth / 2;
        _hourLength = _innerRadius + _innerWidth / 2 - _hourWidth / 2;

        // Steps icon in the gap between the rings; intensity icon just inside the inner ring.
        _iconSize = width * 0.03;
        var outerInnerEdge = _outerRadius - _outerWidth / 2;
        var innerOuterEdge = _innerRadius + _innerWidth / 2;
        _stepsIconY = _centerY + (outerInnerEdge + innerOuterEdge) / 2;
        _intensityIconY = _centerY + _innerRadius - _innerWidth / 2 - _iconSize * 1.6;

        if (Graphics has :getVectorFont) {
            _ringLabelFont = Graphics.getVectorFont({
                :face => ["RobotoCondensedBold", "RobotoRegular"],
                :size => (_outerWidth * 0.9).toNumber()
            });
        }
    }

    function onUpdate(dc) {
        // True black background for the AMOLED screen.
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        if (dc has :setAntiAlias) {
            dc.setAntiAlias(true);
        }

        // Hand angles in degrees clockwise from 12 o'clock. The same angles
        // set where each ring starts.
        var clock = System.getClockTime();
        var minutes = clock.min + clock.sec / 60.0;
        var minuteAngle = (minutes / 60.0) * 360.0;
        var hourAngle = (((clock.hour % 12) + minutes / 60.0) / 12.0) * 360.0;

        if (_lowPower) {
            drawHand(dc, COLOR_LOW_POWER, minuteAngle, _minuteLength, _minuteWidth / 2);
            drawHand(dc, COLOR_LOW_POWER, hourAngle, _hourLength, _hourWidth / 2);
            dc.fillCircle(_centerX, _centerY, _pivotRadius / 2);
            return;
        }

        var steps = null;
        var stepGoal = DEFAULT_STEP_GOAL;
        var intensity = null;
        var intensityGoal = DEFAULT_INTENSITY_GOAL;

        var info = getActivityInfo();
        if (info != null) {
            steps = info.steps;
            if (info.stepGoal != null && info.stepGoal > 0) {
                stepGoal = info.stepGoal;
            }
            if (info.activeMinutesWeek != null) {
                intensity = info.activeMinutesWeek.total;
            }
            if (info.activeMinutesWeekGoal != null && info.activeMinutesWeekGoal > 0) {
                intensityGoal = info.activeMinutesWeekGoal;
            }
        }

        if (USE_TEST_DATA) {
            steps = 6400;
            stepGoal = 10000;
            intensity = 95;
            intensityGoal = 150;
        }

        // Rings first, so the hands are drawn on top. The minute hand drives the
        // outer ring, the hour hand drives the inner ring.
        drawProgressRing(dc, _outerRadius, _outerWidth, minuteAngle, getProgress(steps, stepGoal), COLOR_STEPS, COLOR_STEPS_TRACK);
        drawProgressRing(dc, _innerRadius, _innerWidth, hourAngle, getProgress(intensity, intensityGoal), COLOR_INTENSITY, COLOR_INTENSITY_TRACK);

        if (steps != null) {
            drawRingLabel(dc, _outerRadius, minuteAngle, getProgress(steps, stepGoal), steps.toString());
        }
        if (intensity != null) {
            drawRingLabel(dc, _innerRadius, hourAngle, getProgress(intensity, intensityGoal), intensity.toString());
        }

        // Ring icons at 6 o'clock, in each ring's colour.
        dc.setColor(COLOR_STEPS, Graphics.COLOR_TRANSPARENT);
        drawFootprintsIcon(dc, _centerX, _stepsIconY, _iconSize);
        dc.setColor(COLOR_INTENSITY, Graphics.COLOR_TRANSPARENT);
        drawBoltIcon(dc, _centerX, _intensityIconY, _iconSize);

        // Hands and centre pivot last. Each hand covers the square start edge of
        // its ring, so the arc looks like it grows out of it.
        drawHand(dc, COLOR_HANDS, hourAngle, _hourLength, _hourWidth);
        drawHand(dc, COLOR_HANDS, minuteAngle, _minuteLength, _minuteWidth);
        dc.fillCircle(_centerX, _centerY, _pivotRadius);
    }

    // Returns progress clamped between 0.0 and 1.0.
    function getProgress(value, goal) {
        if (value == null || goal == null || goal <= 0) {
            return 0.0;
        }

        var progress = value.toFloat() / goal;
        if (progress < 0.0) {
            return 0.0;
        }
        if (progress > 1.0) {
            return 1.0;
        }
        return progress;
    }

    // Full 360° dim track with the progress arc on top, starting at the hand.
    // Clock angles run clockwise from 12 o'clock; Garmin arcs run counter-clockwise
    // from 3 o'clock, so a clock angle converts as 90 - angle.
    function drawProgressRing(dc, radius, width, handAngle, progress, color, trackColor) {
        dc.setPenWidth(width);
        dc.setColor(trackColor, Graphics.COLOR_TRANSPARENT);
        dc.drawCircle(_centerX, _centerY, radius);

        if (progress > 0.0) {
            dc.setColor(color, Graphics.COLOR_TRANSPARENT);

            if (progress >= 1.0) {
                dc.drawCircle(_centerX, _centerY, radius);
            } else {
                // Both ends are drawArc's flat, square cuts; the start sits under the hand.
                var arcDegrees = progress * 360.0;
                var startAngle = normalizeAngle(90.0 - handAngle);

                if (RING_TRAILS_HAND) {
                    dc.drawArc(_centerX, _centerY, radius, Graphics.ARC_COUNTER_CLOCKWISE, startAngle, normalizeAngle(startAngle + arcDegrees));
                } else {
                    dc.drawArc(_centerX, _centerY, radius, Graphics.ARC_CLOCKWISE, startAngle, normalizeAngle(startAngle - arcDegrees));
                }
            }
        }

        dc.setPenWidth(1);
    }

    function normalizeAngle(angle) {
        while (angle < 0) {
            angle += 360.0;
        }
        while (angle >= 360) {
            angle -= 360.0;
        }
        return angle;
    }

    // Curves a label along the ring, starting just past the end of the fill so it
    // sits in the unfilled track. If the track has no room left, the label moves
    // just inside the fill and turns dark instead. Text in the bottom half runs
    // the other way round the circle so it's never upside down.
    function drawRingLabel(dc, radius, handAngle, progress, text) {
        if (_ringLabelFont == null) {
            return;
        }

        var gap = 3.0;
        var textDegrees = Math.toDegrees(dc.getTextWidthInPixels(text, _ringLabelFont).toFloat() / radius);
        var arcDegrees = progress * 360.0;
        var startAngle = 90.0 - handAngle;

        // Garmin degrees: -1 means the fill runs clockwise, +1 counter-clockwise.
        var fillDirection = RING_TRAILS_HAND ? 1 : -1;
        var fillEnd = startAngle + fillDirection * arcDegrees;

        var labelDirection = fillDirection;
        var color = COLOR_RING_LABEL;
        if (360.0 - arcDegrees < textDegrees + gap * 2) {
            labelDirection = -fillDirection;
            color = COLOR_RING_LABEL_ON_FILL;
        }

        var anchor = fillEnd + labelDirection * gap;
        var middle = Math.toRadians(anchor + labelDirection * textDegrees / 2);
        var topHalf = Math.sin(middle) >= 0;

        // Top half reads clockwise, bottom half counter-clockwise. The label must
        // grow away from the anchor, which decides which end it's justified at.
        var textDirection = topHalf ? Graphics.RADIAL_TEXT_DIRECTION_CLOCKWISE : Graphics.RADIAL_TEXT_DIRECTION_COUNTER_CLOCKWISE;
        var growsClockwise = labelDirection < 0;
        var justification = (topHalf == growsClockwise) ? Graphics.TEXT_JUSTIFY_LEFT : Graphics.TEXT_JUSTIFY_RIGHT;

        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.drawRadialText(
            _centerX,
            _centerY,
            _ringLabelFont,
            text,
            justification | Graphics.TEXT_JUSTIFY_VCENTER,
            normalizeAngle(anchor),
            radius,
            textDirection
        );
    }

    // Two footprints, the right one a step ahead. Size is half the icon's height.
    function drawFootprintsIcon(dc, x, y, size) {
        var leftX = x - size * 0.5;
        var rightX = x + size * 0.5;

        dc.fillEllipse(leftX, y - size * 0.05, size * 0.36, size * 0.62);
        dc.fillCircle(leftX, y + size * 0.82, size * 0.26);
        dc.fillEllipse(rightX, y - size * 0.45, size * 0.36, size * 0.62);
        dc.fillCircle(rightX, y + size * 0.42, size * 0.26);
    }

    // Lightning bolt. Size is half the icon's height.
    function drawBoltIcon(dc, x, y, size) {
        dc.fillPolygon([
            [x + size * 0.35, y - size],
            [x - size * 0.65, y + size * 0.2],
            [x - size * 0.1, y + size * 0.2],
            [x - size * 0.35, y + size],
            [x + size * 0.65, y - size * 0.2],
            [x + size * 0.1, y - size * 0.2]
        ]);
    }

    // Angle is in degrees clockwise from 12 o'clock.
    function drawHand(dc, color, angle, length, width) {
        // Zero radians points to 3 o'clock; subtracting π/2 moves it to 12 o'clock.
        var radians = Math.toRadians(angle) - Math.PI / 2;
        var endX = _centerX + Math.cos(radians) * length;
        var endY = _centerY + Math.sin(radians) * length;

        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(width);
        dc.drawLine(_centerX, _centerY, endX, endY);
        dc.setPenWidth(1);

        // Rounded tip.
        dc.fillCircle(endX, endY, width / 2);
    }

    function getActivityInfo() {
        try {
            return ActivityMonitor.getInfo();
        } catch (ex) {
            System.println("Hypnos: activity info unavailable");
        }

        return null;
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
