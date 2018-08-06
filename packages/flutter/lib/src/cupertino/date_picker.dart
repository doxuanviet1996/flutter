// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';

import 'colors.dart';
import 'picker.dart';

const _kItemExtent = 32.0;
const _kMagnification = 1.1;

/// All kind of modes available for the [DatePicker].
enum CupertinoDatePickerMode {
  /// Mode that shows the date in hour, minute, and (optional) an AM/PM designation.
  ///
  /// Example: [12 | 03 | PM].
  time,
  /// Mode that shows the date in month, day of month, and year.
  ///
  /// Example: [July | 13 | 2012].
  date,
  /// Mode that shows the date as day of the week, month, day of month and
  /// the time in hour, minute, and (optional) an AM/PM designation.
  ///
  /// Example: [Fri Jul 13 | 16 | 14 | PM]
  dateAndTime,
  /// Mode that shows hour and minute values.
  ///
  /// Example: [3 | 10].
  countDownTimer,
}

/// A date picker widget in iOS style.
class CupertinoDatePicker extends StatefulWidget {
  /// Basic constructor for the date picker.
  const CupertinoDatePicker({
    this.mode = CupertinoDatePickerMode.countDownTimer,
    this.onDateChanged,
    this.onTimerDurationChanged,
    this.initialDate,
    this.minimumDate,
    this.maximumDate,
    this.minuteInterval,
    this.initialTimerDuration,
  }) : assert(mode != null),
       assert(onDateChanged != null || mode == CupertinoDatePickerMode.countDownTimer),
       assert(onTimerDurationChanged != null || mode != CupertinoDatePickerMode.countDownTimer);

  /// Mode of the DatePicker.
  final CupertinoDatePickerMode mode;

  /// The initial date of the picker.
  final DateTime initialDate;

  /// Minimum date that the picker can be scrolled to. Null if there's no limit.
  final DateTime minimumDate;

  /// Maximum date that the picker can be scrolled to. Null if there's no limit.
  final DateTime maximumDate;

  /// The granularity of the minutes spinner, if it is shown in the current mode.
  final int minuteInterval;

  /// The initial duration of the countdown timer.
  final Duration initialTimerDuration;

  /// Callback when the date changes.
  final ValueChanged<DateTime> onDateChanged;

  /// Callback when the timer duration changes.
  final ValueChanged<Duration> onTimerDurationChanged;

  @override
  State<StatefulWidget> createState() => new _CupertinoDatePickerState();
}

class _CupertinoDatePickerState extends State<CupertinoDatePicker> {
  int _selectedHour;
  int _selectedMinute;
  Widget _buildTimeMode(BuildContext context) {
    return null;
  }

  Widget _buildDateMode(BuildContext context) {
    return null;
  }

  Widget _buildDateAndTimeMode(BuildContext context) {
    return null;
  }

  Widget _buildCountDownTimerMode(BuildContext context) {
    if (_selectedHour == null && _selectedMinute == null) {
      if(widget.initialTimerDuration != null) {
        _selectedHour = widget.initialTimerDuration.inHours % 24;
        _selectedMinute = widget.initialTimerDuration.inMinutes % 60;
      }
      else {
        _selectedHour = 0;
        _selectedMinute = 1;
      }
    }

    return new Stack(
      children: <Widget>[
        new Row(
          children: <Widget>[
            // The hour picker.
            new Expanded(
              child: new CupertinoPicker(
                scrollController: new FixedExtentScrollController(
                  initialItem: _selectedHour,
                ),
                offAxisFraction: -0.1,
                useMagnifier: true,
                magnification: _kMagnification,
                itemExtent: _kItemExtent,
                backgroundColor: CupertinoColors.white,
                onSelectedItemChanged: (int index) {
                  setState(() {
                    _selectedHour = index;
                    widget.onTimerDurationChanged(new Duration(hours: _selectedHour, minutes: _selectedMinute));
                  });
                },
                children: new List<Widget>.generate(24, (int index) {
                  return new Container(
                    alignment: Alignment.center,
//                    padding: const EdgeInsets.only(right: 64.0),
                    child: new Text(index.toString()),
                  );
                }),
                looping: true,
              ),
            ),
            // The minute picker.
            new Expanded(
              child: new CupertinoPicker(
                scrollController: new FixedExtentScrollController(
                  initialItem: _selectedMinute,
                ),
                offAxisFraction: 0.5,
                useMagnifier: true,
                magnification: _kMagnification,
                itemExtent: _kItemExtent,
                backgroundColor: CupertinoColors.white,
                onSelectedItemChanged: (int index) {
                  setState(() {
                    _selectedMinute = index;
                    widget.onTimerDurationChanged(new Duration(hours: _selectedHour, minutes: _selectedMinute));
                  });
                },
                children: new List<Widget>.generate(60, (int index) {
                  return new Container(
                    alignment: Alignment.centerLeft,
//                    padding: const EdgeInsets.only(left: 32.0),
                    child: new Text(index.toString()),
                  );
                }),
                looping: true,
              ),
            ),
          ],
        ),
        new Row(
          children: <Widget>[
            new Expanded(
              child: new Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 32.0),
                child: const Text(
                  'hours',
                  style: TextStyle(fontSize: 20.0),
                ),
              ),
            ),
            new Expanded(
              child: new Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(left: 36.0),
                child: const Text(
                  'mins',
                  style: TextStyle(fontSize: 20.0),
                ),
              ),
            ),
          ],
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.mode == CupertinoDatePickerMode.time)
      return _buildTimeMode(context);
    else if (widget.mode == CupertinoDatePickerMode.date)
      return _buildDateMode(context);
    else if (widget.mode == CupertinoDatePickerMode.dateAndTime)
      return _buildDateAndTimeMode(context);
    else if (widget.mode == CupertinoDatePickerMode.countDownTimer)
      return _buildCountDownTimerMode(context);
  }
}