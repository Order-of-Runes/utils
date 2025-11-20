// Copyright (c) 2025 Order of Runes Authors. All rights reserved.

import 'package:intl/intl.dart';
import 'package:utils/src/date/date_pattern.dart';
import 'package:utils/src/empty_util.dart';

class DateTimeUtil {
  DateTimeUtil(DateTime? dateTime) : _dateTime = dateTime?.toLocal();

  DateTimeUtil.utc(DateTime? dateTime) : _dateTime = dateTime;

  DateTimeUtil.raw(String rawDateTime) : _dateTime = DateTime.tryParse(rawDateTime)?.toLocal();

  final DateTime? _dateTime;

  DateTime? get dateTime => _dateTime;

  DateTimeUtil add(Duration duration) {
    return DateTimeUtil(_dateTime?.add(duration));
  }

  /// Format the date based on the [pattern]
  String format(DatePattern pattern) {
    if (_dateTime.isNull) return '';
    return DateFormat(pattern.pattern).format(_dateTime!);
  }

  /// Converts 24 hour time 12 hour
  String hour24To12([String onExceptionTime = '']) {
    if (_dateTime.isNull) return onExceptionTime;
    return DateFormat('hh:mm a').format(_dateTime!);
  }

  Duration? difference({DateTime? anotherDate, String? anotherRawDate, bool reverse = false}) {
    if (_dateTime.isNull) return null;

    final _anotherDate = _getAnotherDate(anotherDate, anotherRawDate);
    if (_anotherDate.isNull) return null;

    if (reverse) return _anotherDate!.difference(_dateTime!);
    return _dateTime!.difference(_anotherDate!);
  }

  bool isAfter({DateTime? anotherDate, String? anotherRawDate, bool inclusive = false}) {
    if (_dateTime.isNull) return false;

    final _anotherDate = _getAnotherDate(anotherDate, anotherRawDate);
    if (_anotherDate.isNull) return false;

    if (inclusive) {
      return _dateTime!.isAfter(_anotherDate!) || _dateTime.isAtSameMomentAs(_anotherDate);
    }
    return _dateTime!.isAfter(_anotherDate!);
  }

  bool isBefore({DateTime? anotherDate, String? anotherRawDate, bool inclusive = false}) {
    if (_dateTime.isNull) return false;

    final _anotherDate = _getAnotherDate(anotherDate, anotherRawDate);
    if (_anotherDate.isNull) return false;

    if (inclusive) {
      return _dateTime!.isBefore(_anotherDate!) || _dateTime.isAtSameMomentAs(_anotherDate);
    }
    return _dateTime!.isBefore(_anotherDate!);
  }

  bool isBetween({DateTime? startDate, String? startRawDate, DateTime? endDate, String? endRawDate, bool inclusive = false}) {
    if (_dateTime.isNull) return false;

    final _startDate = _getAnotherDate(startDate, startRawDate);
    final _endDate = _getAnotherDate(endDate, endRawDate);

    if (_startDate.isNull || _endDate.isNull) return false;

    if (inclusive) {
      return (_dateTime!.isBefore(_endDate!) || _dateTime.isAtSameMomentAs(_endDate)) &&
          (_dateTime.isAfter(_startDate!) || _dateTime.isAtSameMomentAs(_startDate));
    }
    return _dateTime!.isBefore(_endDate!) && _dateTime.isAfter(_startDate!);
  }

  DateTime? _getAnotherDate(DateTime? anotherDate, String? anotherRawDate) {
    assert(anotherDate.isNotNull || anotherRawDate.isNotNull, 'Either of the options should be passed');

    if (_dateTime.isNull && anotherDate.isNull && anotherRawDate.isNullOrEmpty) return null;

    return anotherDate.isNull ? DateTime.tryParse(anotherRawDate!) : anotherDate;
  }
}
