// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import 'colors.dart';
import 'picker.dart';

const double _kItemHeight = 32.0;
const double _kMagnification = 1.1;
const Color _kDefaultBackgroundColor = CupertinoColors.white;

/// Different kinds of mode available for the [DatePicker].
enum CupertinoDatePickerMode {
  /// Mode that shows the date in hour, minute, and (optional) an AM/PM designation.
  ///
  /// Example: [4 | 14 | PM].
  time,
  /// Mode that shows the date in month, day of month, and year.
  ///
  /// Example: [July | 13 | 2012].
  date,
  /// Mode that shows the date as day of the week, month, day of month and
  /// the time in hour, minute, and (optional) an AM/PM designation.
  ///
  /// Example: [Fri Jul 13 | 4 | 14 | PM]
  dateAndTime,
}

/// A date picker widget in iOS style.
///
/// There are several modes of the date picker listed in [CupertinoDatePickerMode].
class CupertinoDatePicker extends StatefulWidget {
  /// Constructs the date picker from one of the mode listed in
  /// [CupertinoDatePickerMode].
  ///
  /// The [mode] defaults to [CupertinoDatePickerMode.dateAndTime].
  ///
  /// [onDateChanged] is the callback when user scrolls and must not be null.
  ///
  /// [use24hFormat] decides whether 24 hour format is used. Defaults to false.
  CupertinoDatePicker({
    this.mode = CupertinoDatePickerMode.dateAndTime,
    @required this.onDateChanged,
    this.initialDate,
    this.minimumDate,
    this.maximumDate,
    this.minuteInterval = 1,

  }) : assert(mode != null),
       assert(onDateChanged != null),
       assert(60 % minuteInterval == 0);

  /// The mode of the date picker.
  final CupertinoDatePickerMode mode;

  /// The initial date of the picker.
  final DateTime initialDate;

  /// Minimum date that the picker can be scrolled to. Null if there's no limit.
  final DateTime minimumDate;

  /// Maximum date that the picker can be scrolled to. Null if there's no limit.
  final DateTime maximumDate;

  /// The granularity of the minutes spinner, if it is shown in the current mode.
  ///  Must be a factor of 60.
  final int minuteInterval;

  /// Whether to use 24 hour format.
  final bool use24hFormat;

  /// Callback when the selected date changes.
  final ValueChanged<DateTime> onDateChanged;

  @override
  State<StatefulWidget> createState() {
    if (mode == CupertinoDatePickerMode.time)
      return _TimeState();
    else if (mode == CupertinoDatePickerMode.date)
      return _DateState();
    else
      return _DateAndTimeState();
  }
}

// State of the date picker where the mode is time.
class _TimeState extends State<CupertinoDatePicker> {
  int selectedHour;
  int selectedMinute;
  int selectedAmPm;

  FixedExtentScrollController hourController;
  FixedExtentScrollController minuteController;
  FixedExtentScrollController amPmController;

  @override
  void initState() {
    super.initState();

    selectedHour = widget.initialDate.hour % 12;
    selectedMinute = widget.initialDate.minute;
    selectedAmPm = widget.initialDate.hour ~/ 12;

    hourController = new FixedExtentScrollController(initialItem: selectedHour);
    minuteController = new FixedExtentScrollController(initialItem: selectedMinute ~/ widget.minuteInterval);
    amPmController = new FixedExtentScrollController(initialItem: selectedAmPm);
  }

  @override
  Widget build(BuildContext context) {
    return new Row(
      children: <Widget>[
        new Expanded(
          flex: 2,
          child: new CupertinoPicker(
            scrollController: hourController,
            offAxisFraction: -0.4,
            useMagnifier: true,
            magnification: _kMagnification,
            itemExtent: _kItemHeight,
            backgroundColor: CupertinoColors.white,
            onSelectedItemChanged: (int index) {
              if(selectedHour == 0 && index == 11
                  || selectedHour == 11 && index == 0) {
                selectedHour = index;
                amPmController.animateToItem(
                  1 - amPmController.selectedItem,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.decelerate);
              }
              else {
                selectedHour = index;
                widget.onDateChanged(new DateTime(
                    2018, 1, 1, selectedHour + selectedAmPm * 12,
                    selectedMinute));
              }
            },
            children: new List<Widget>.generate(12, (int index) {
              int hourToDisplay = index % 12;
              if (hourToDisplay == 0) hourToDisplay = 12;
              return new Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 32.0),
                child: new ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 32.0),
                  child: new Text(
                    hourToDisplay.toString(),
                    textAlign: TextAlign.right,
                  ),
                ),
              );
            }),
            looping: true,
          ),
        ),

        new Expanded(
          flex: 1,
          child: new CupertinoPicker(
            scrollController: minuteController,
            offAxisFraction: 0.0,
            useMagnifier: true,
            magnification: _kMagnification,
            itemExtent: _kItemHeight,
            backgroundColor: CupertinoColors.white,
            onSelectedItemChanged: (int index) {
              selectedMinute = index * widget.minuteInterval;
              widget.onDateChanged(new DateTime(2018, 1, 1, selectedHour + selectedAmPm * 12, selectedMinute));
            },
            children: new List<Widget>.generate(60 ~/ widget.minuteInterval, (int index) {
              final int toMinute = index * widget.minuteInterval;
              return new Container(
                alignment: Alignment.center,
                child: new ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 32.0),
                  child: new Text(
                    toMinute.toString().padLeft(2, '0'),
                    textAlign: TextAlign.right,
                  ),
                ),
              );
            }),
            looping: true,
          ),
        ),

        new Expanded(
          flex: 2,
          child: new CupertinoPicker(
            scrollController: amPmController,
            offAxisFraction: 0.4,
            useMagnifier: true,
            magnification: _kMagnification,
            itemExtent: _kItemHeight,
            backgroundColor: CupertinoColors.white,
            onSelectedItemChanged: (int index) {
              setState(() {
                selectedAmPm = index;
                widget.onDateChanged(new DateTime(2018, 1, 1, selectedHour + selectedAmPm * 12, selectedMinute));
              });
            },
            children: new List<Widget>.generate(2, (int index) {
              return new Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(left: 32.0),
                child: new ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 32.0),
                  child: new Text(
                    index == 0 ? 'AM' : 'PM',
                    textAlign: TextAlign.right,
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

// State of the date picker where the mode is time.
class _DateState extends State<CupertinoDatePicker> {
  int selectedMonth;
  int selectedDay;
  int selectedYear;

  final DateTime now = DateTime.now();

  FixedExtentScrollController monthController;
  FixedExtentScrollController dayController;
  FixedExtentScrollController yearController;

  @override
  void initState() {
    super.initState();

    selectedMonth = widget.initialDate.month;
    selectedDay = widget.initialDate.day;
    selectedYear = widget.initialDate.year;

    monthController = new FixedExtentScrollController(initialItem: selectedMonth - 1);
    dayController = new FixedExtentScrollController(initialItem: selectedDay - 1);
    yearController = new FixedExtentScrollController(initialItem: selectedYear);
  }

  @override
  Widget build(BuildContext context) {
    return new NotificationListener<ScrollEndNotification>(
      onNotification: (ScrollEndNotification notification) {
        final DateTime trueDate = DateTime(selectedYear, selectedMonth, selectedDay);
        if(selectedDay != trueDate.day) {
          dayController.animateToItem(
            dayController.selectedItem - 1,
            duration: Duration(milliseconds: 250),
            curve: Curves.linear);
        }
      },
      child: new Row(
        children: <Widget>[
          new Expanded(
            flex: 245,
            child: new CupertinoPicker(
              scrollController: monthController,
              offAxisFraction: -0.2,
              useMagnifier: true,
              magnification: _kMagnification,
              itemExtent: _kItemHeight,
              backgroundColor: CupertinoColors.white,
              onSelectedItemChanged: (int index) {
                setState(() {
                  selectedMonth = index + 1;
                  if (DateTime(selectedYear, selectedMonth, selectedDay).day == selectedDay)
                    widget.onDateChanged(new DateTime(selectedYear, selectedMonth, selectedDay));
                });
              },
              children: new List<Widget>.generate(12, (int index) {
                return new Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 50.0),
                  child: new Text(
                    ['January', 'February', 'March', 'April', 'May', 'June',
                    'July', 'August', 'September', 'October',
                    'November', 'December'][index],
                    ),
                );
              }),
              looping: true,
            ),
          ),

          new Expanded(
            flex: 36,
            child: new CupertinoPicker(
              scrollController: dayController,
              offAxisFraction: 0.0,
              useMagnifier: true,
              magnification: _kMagnification,
              itemExtent: _kItemHeight,
              backgroundColor: CupertinoColors.white,
              onSelectedItemChanged: (int index) {
                setState(() {
                  selectedDay = index + 1;
                  if (DateTime(selectedYear, selectedMonth, selectedDay).day == selectedDay)
                    widget.onDateChanged(new DateTime(selectedYear, selectedMonth, selectedDay));
                });
              },
              children: new List<Widget>.generate(31, (int index) {
                return new Container(
                  alignment: Alignment.center,
                  child: new ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 32.0),
                    child: new Text(
                      (index + 1).toString(),
                      textAlign: TextAlign.right,
                    ),
                  ),
                );
              }),
              looping: true,
            ),
          ),

          new Expanded(
            flex: 189,
            child: new CupertinoPicker.builder(
                scrollController: yearController,
                offAxisFraction: 0.4,
                useMagnifier: true,
                magnification: _kMagnification,
                itemExtent: _kItemHeight,
                backgroundColor: CupertinoColors.white,
                onSelectedItemChanged: (int index) {
                  setState(() {
                    selectedYear = index;
                    if (DateTime(selectedYear, selectedMonth, selectedDay).day == selectedDay)
                      widget.onDateChanged(new DateTime(selectedYear, selectedMonth, selectedDay));
                  });
                },
                itemBuilder: (BuildContext context, int index) {
                  if(index < 0) return null;
                  return new Container(
                    alignment: Alignment.center,
                    child: new ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 32.0),
                      child: new Text(
                        index.toString(),
                      ),
                    ),
                  );
                }),
          ),
        ],
      ),
    );
  }
}

// State of the date picker where the mode is time.
class _DateAndTimeState extends State<CupertinoDatePicker> {
  int dateDifference;
  int selectedHour;
  int selectedMinute;
  int selectedAmPm;

  FixedExtentScrollController dateController;
  FixedExtentScrollController hourController;
  FixedExtentScrollController minuteController;
  FixedExtentScrollController amPmController;

  @override
  void initState() {
    super.initState();

    dateDifference = 0;
    selectedHour = widget.initialDate.hour % 12;
    selectedMinute = widget.initialDate.minute ~/ widget.minuteInterval * widget.minuteInterval;
    selectedAmPm = widget.initialDate.hour ~/ 12;

    dateController = new FixedExtentScrollController(initialItem: dateDifference);
    hourController = new FixedExtentScrollController(initialItem: selectedHour);
    minuteController = new FixedExtentScrollController(initialItem: selectedMinute ~/ widget.minuteInterval);
    amPmController = new FixedExtentScrollController(initialItem: selectedAmPm);
  }

  DateTime getDate(int dayDiff) {
    return new DateTime(
      widget.initialDate.year,
      widget.initialDate.month,
      widget.initialDate.day,
      selectedHour +  selectedAmPm * 12,
      selectedMinute,
    ).add(Duration(days: dayDiff));
  }

  @override
  Widget build(BuildContext context) {
    return new Row(
      children: <Widget>[
        new Expanded(
          flex: 40,
          child: new CupertinoPicker.builder(
            scrollController: dateController,
            offAxisFraction: -0.5,
            useMagnifier: true,
            magnification: _kMagnification,
            itemExtent: _kItemHeight,
            backgroundColor: CupertinoColors.white,
            onSelectedItemChanged: (int index) {
              dateDifference = index;
              DateTime res = getDate(index);
              widget.onDateChanged(getDate(index));
            },
            itemBuilder: (BuildContext context, int index) {
              return new Container(
                alignment: Alignment.centerRight,
                child: new Text(
                  DateFormat('EEE MMM d').format(getDate(index)),
                  textAlign: TextAlign.right,
                ),
              );
            },
          ),
        ),

        new Expanded(
          flex: 26,
          child: new CupertinoPicker(
            scrollController: hourController,
            offAxisFraction: 0.1,
            useMagnifier: true,
            magnification: _kMagnification,
            itemExtent: _kItemHeight,
            backgroundColor: CupertinoColors.white,
            onSelectedItemChanged: (int index) {
              if(selectedHour == 0 && index == 11
                  || selectedHour == 11 && index == 0) {
                selectedHour = index;
                amPmController.animateToItem(
                    1 - amPmController.selectedItem,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOut);
              }
              else {
                selectedHour = index;
                widget.onDateChanged(getDate(dateDifference));
              }
            },
            children: new List<Widget>.generate(12, (int index) {
              int hourToDisplay = index % 12;
              if (hourToDisplay == 0) hourToDisplay = 12;
              return new Container(
                alignment: Alignment.center,
                child: new ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 32.0),
                  child: new Text(
                    hourToDisplay.toString(),
                    textAlign: TextAlign.right,
                  ),
                ),
              );
            }),
            looping: true,
          ),
        ),

        new Expanded(
          flex: 9,
          child: new CupertinoPicker(
            scrollController: minuteController,
            offAxisFraction: 0.5,
            useMagnifier: true,
            magnification: _kMagnification,
            itemExtent: _kItemHeight,
            backgroundColor: CupertinoColors.white,
            onSelectedItemChanged: (int index) {
              selectedMinute = index * widget.minuteInterval;
              widget.onDateChanged(getDate(dateDifference));
            },
            children: new List<Widget>.generate(60 ~/ widget.minuteInterval, (int index) {
              final int toMinute = index * widget.minuteInterval;
              return new Container(
                alignment: Alignment.center,
                child: new ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 32.0),
                  child: new Text(
                    toMinute.toString().padLeft(2, '0'),
                    textAlign: TextAlign.right,
                  ),
                ),
              );
            }),
            looping: true,
          ),
        ),

        new Expanded(
          flex: 25,
          child: new CupertinoPicker(
            scrollController: amPmController,
            offAxisFraction: 0.5,
            useMagnifier: true,
            magnification: _kMagnification,
            itemExtent: _kItemHeight,
            backgroundColor: CupertinoColors.white,
            onSelectedItemChanged: (int index) {
              setState(() {
                selectedAmPm = index;
                widget.onDateChanged(getDate(dateDifference));
              });
            },
            children: new List<Widget>.generate(2, (int index) {
              return new Container(
                alignment: Alignment.center,
                child: new ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 32.0),
                  child: new Text(
                    index == 0 ? 'AM' : 'PM',
                    textAlign: TextAlign.right,
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

/// A countdown timer picker in iOS style.
///
/// This picker shows duration as hour and minute spinners. The minimum duration
/// is 1 minute and maximum duration is 23 hours 59 minutes (same as iOS
/// countdown timer).
///
/// Example: [16 | 14]
class CupertinoCountdownTimerPicker extends StatefulWidget {
  /// Basic constructor of the countdown timer.
  ///
  /// [onTimerDurationChanged] is the callback when the selected duration changes
  /// and must not be null.
  ///
  /// [initialTimerDuration] defaults to 1 minute and is limited from 1 minute
  /// to 23 hours 59 minutes. Only hour and minute values are extracted
  /// from [initialTimerDuration], so specifying other fields like day, second,
  /// etc. will not affect anything.
  ///
  /// [minuteInterval] is the granularity of the minute spinner. Must be a factor
  /// of 60.
  CupertinoCountdownTimerPicker({
    @required this.onTimerDurationChanged,
    this.initialTimerDuration = const Duration(minutes: 1),
    this.minuteInterval = 5,
  }) : assert(onTimerDurationChanged != null),
       assert(initialTimerDuration >= const Duration(minutes: 1)),
       assert(initialTimerDuration < const Duration(days: 1));

  /// The granularity of the minute spinner. Must be a factor of 60.
  final int minuteInterval;

  /// The initial duration of the countdown timer.
  final Duration initialTimerDuration;

  /// Callback when the timer duration changes.
  final ValueChanged<Duration> onTimerDurationChanged;

  @override
  State<StatefulWidget> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CupertinoCountdownTimerPicker> {
  int _selectedHour;
  int _selectedMinute;

  FixedExtentScrollController hourController;
  FixedExtentScrollController minuteController;

  @override
  void initState() {
    super.initState();

    _selectedHour = widget.initialTimerDuration.inHours;
    _selectedMinute = widget.initialTimerDuration.inMinutes % 60;

    hourController = new FixedExtentScrollController(initialItem: _selectedHour);
    minuteController = new FixedExtentScrollController(
      initialItem: _selectedMinute ~/ widget.minuteInterval);
  }

  @override
  Widget build(BuildContext context) {
    final double textScaleFactor = MediaQuery.textScaleFactorOf(context);
    // A notification listener is needed so that whenever scrolling lands on an
    // invalid entry, the picker automatically scrolls to a valid one.
    return new NotificationListener<ScrollEndNotification>(
      onNotification: (ScrollEndNotification notification) {
        // Invalid case where both hour and minute are 0.
        if(_selectedMinute == 0 && _selectedHour == 0) {
          minuteController.animateToItem(
            minuteController.selectedItem + 1,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOut);
        }
      },
      child: new Stack(
        children: <Widget>[
          new Row(
            children: <Widget>[
              // The hour picker.
              new Expanded(
                child: new CupertinoPicker(
                  scrollController: hourController,
                  offAxisFraction: -0.15,
                  useMagnifier: true,
                  magnification: _kMagnification * textScaleFactor,
                  itemExtent: _kItemHeight * textScaleFactor,
                  backgroundColor: _kDefaultBackgroundColor,
                  onSelectedItemChanged: (int index) {
                    setState(() {
                      _selectedHour = index;
                      widget.onTimerDurationChanged(
                        new Duration(hours: _selectedHour, minutes: _selectedMinute));
                    });
                  },
                  children: new List<Widget>.generate(24, (int index) {
                    return new Container(
                      alignment: Alignment.center,
                      child: new Text(index.toString().padLeft(2, '  ')),
                    );
                  }),
                ),
              ),
              // The minute picker.
              new Expanded(
                child: new CupertinoPicker(
                  scrollController: minuteController,
                  offAxisFraction: 0.5,
                  useMagnifier: true,
                  magnification: _kMagnification * textScaleFactor,
                  itemExtent: _kItemHeight * textScaleFactor,
                  backgroundColor: _kDefaultBackgroundColor,
                  onSelectedItemChanged: (int index) {
                    setState(() {
                      _selectedMinute = index * widget.minuteInterval;
                      widget.onTimerDurationChanged(
                        new Duration(hours: _selectedHour, minutes: _selectedMinute));
                    });
                  },
                  children: new List<Widget>.generate(60 ~/ widget.minuteInterval, (int index) {
                    final int toMinute = index * widget.minuteInterval;
                    return new Container(
                      alignment: Alignment.centerLeft,
                      child: new Text(toMinute.toString().padLeft(2, '  ')),
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
                  alignment: const Alignment(0.5, 0.0),
                  padding: new EdgeInsets.only(left: 42.0 * textScaleFactor),
                  child: new Text(
                    'hours',
                    style: TextStyle(fontWeight: FontWeight.w600),
                    textScaleFactor: 0.9 * textScaleFactor,
                  ),
                ),
              ),
              new Expanded(
                child: new Container(
                  alignment: Alignment.centerLeft,
                  padding: new EdgeInsets.only(left: 42.0 * textScaleFactor),
                  child: new Text(
                    'min',
                    style: TextStyle(fontWeight: FontWeight.w600),
                    textScaleFactor: 0.9 * textScaleFactor,
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}