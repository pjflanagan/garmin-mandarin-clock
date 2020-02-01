using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Lang;
using Toybox.Application;

class MandarinClockView extends WatchUi.WatchFace {
    hidden var fontWidth;
    hidden var font;
    hidden var fontData;

    function initialize() {
        WatchFace.initialize();
    }

    function onLayout(dc) {
        setLayout(Rez.Layouts.WatchFace(dc));
        // initialise Chinese font
        var shape = System.getDeviceSettings().screenShape;
        font = WatchUi.loadResource(Rez.Fonts.font_ch);
        fontData = WatchUi.loadResource(Rez.JsonData.fontData);
        fontWidth = dc.getFontHeight(font);
        System.println("Width:" + dc.getWidth() + " Height:" + dc.getHeight() + " Shape:" + shape + " Font Size:" + fontWidth);
    }

    function onShow() {
    }

    const chToIndexMap = {
        "零" => 0, "一" => 1, "二" => 2, "三" => 3, "四" => 4,
        "五" => 5, "六" => 6, "七" => 7, "八" => 8, "九" => 9,
        "十" => 10, "兩" => 11, "點" => 12, "整" => 13, "分" => 14,
        "秒" => 15, "日" => 16, "月" => 17, "天" => 18, "星" => 19,
        "期" => 20, "上" => 21, "下" => 22, "早" => 23, "中" => 24,
        "晚" => 25, "午" => 26, "傍" => 27, "凌" => 28, "晨" => 29,
        "清" => 30, "半" => 31,
    };
    const numberToChMap = {
        0 => "零", 1 => "一", 2 => "二", 3 => "三", 4 => "四",
        5 => "五", 6 => "六", 7 => "七", 8 => "八", 9 => "九",
        10 => "十", 11 => "十一", 12 => "十二",
        -2 => "兩",
    };

    function drawChineseTextHorizontal(dc, text, color, x, y, justification) {
        if (text.length() == 0) {
            return;
        }
        // modify x according to justification
        var pixels = text.length() * fontWidth;
        switch(justification) {
        case Graphics.TEXT_JUSTIFY_CENTER:
            x = dc.getWidth() / 2 - pixels/2;
            break;
        case Graphics.TEXT_JUSTIFY_RIGHT:
            x = dc.getWidth() - pixels - x;
            break;
        }
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        for (var i = 0; i < text.length(); i++) {
            var ch = text.substring(i, i+1);
            if (chToIndexMap.hasKey(ch)) {
                drawTiles(dc, fontData[chToIndexMap.get(ch)], font, x + i*fontWidth, y);
            }
        }
    }

    // Update the view
    function onUpdate(dc) {
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);

        var offsetX = Application.getApp().getProperty("OffsetX");
        var offsetY = Application.getApp().getProperty("OffsetY");
        var paddingWidth = Application.getApp().getProperty("Padding");
        var alignment = Application.getApp().getProperty("AlignText");

        // Get the current time and format it correctly
        var clockTime = System.getClockTime();
        var hours = clockTime.hour;
        var minutes = clockTime.min;

        // ==== determine time of day
        var timeOfDay = "";
        if (hours >= 0 && hours < 5) {
            timeOfDay = "凌晨";
        } else if (hours >= 5 && hours < 7) { //given sunrise is at 7
            timeOfDay = "清晨";
        } else if (hours >= 7 && hours < 11) {
            timeOfDay = "早上";
        } else if (hours >= 11 && hours < 13) {
            timeOfDay = "中午";
        } else if (hours >= 13 && hours < 18) {
            timeOfDay = "下午";
        } else if (hours >= 18 && hours < 20) { //given sunset is at 20
            timeOfDay = "傍晚";
        } else if (hours >= 20 && hours < 24) {
            timeOfDay = "晚上";
        }

        // ==== determine hour
        var hourText = "";
        if (hours > 12) {
            hours = hours - 12;
        }
        if (hours == 2) {
            hourText = numberToChMap[-hours] + "點";
        } else {
            hourText = numberToChMap[hours] + "點";
        }

        // ==== determine minute
        var minuteText = "";
        if (minutes == 0) {
            minuteText = "整";
        } else if (minutes == 30) {
            minuteText = "半";
        } else if (minutes < 10) {
            minuteText = numberToChMap[minutes] + "分";
        } else if (minutes < 20) {
            if (minutes % 10 == 0) {
                minuteText = "十分";
            } else {
                minuteText = "十" + numberToChMap[minutes%10] + "分";
            }
        } else {
            if (minutes % 10 == 0) {
                minuteText = numberToChMap[minutes/10] + "十分";
            } else {
                minuteText = numberToChMap[minutes/10] + "十" + numberToChMap[minutes%10] + "分";
            }
        }
        // ==== drawing Chinese text
        if (Application.getApp().getProperty("ShowTimeOfDay")) {
            drawChineseTextHorizontal(dc, timeOfDay, Application.getApp().getProperty("TimeOfDayColor"), offsetX, offsetY, alignment);
        }

        drawChineseTextHorizontal(dc, hourText, Application.getApp().getProperty("HourColor"), offsetX, offsetY + fontWidth + paddingWidth, alignment);
        drawChineseTextHorizontal(dc, minuteText, Application.getApp().getProperty("MinuteColor"), offsetX, offsetY + fontWidth * 2 + paddingWidth, alignment);
        //drawChineseTextHorizontal(dc, "三點零八分", 0xff0000, 10, 200);
    }

    function onHide() {
    }

    function onExitSleep() {
    }

    function onEnterSleep() {
    }

    // copied from https://github.com/sunpazed/garmin-tilemapper
    function drawTiles(dc, data, font, xoff, yoff) {
        for(var i = 0; i < data.size(); i++) {
            var packed_value = data[i];
	        var char = (packed_value&0x00000FFF);
	        var xpos = (packed_value&0x003FF000)>>12;
	        var ypos = (packed_value&0xFFC00000)>>22;
	        dc.drawText(xoff + xpos, yoff + ypos, font, (char.toNumber()).toChar(), Graphics.TEXT_JUSTIFY_LEFT);
        }
    }
}
