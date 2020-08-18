import 'dart:core';
import 'dart:async';
import 'dart:math';

/// Wrapper for stream pushing into list (not generic)
class DataListStream {
  Stream<List<int>> _stream;
  List<List<int>> _data = [];
  List<DateTime> _time = [];
  int _width = 1;
  int _c = 0;
  int _len = 0;
  bool _run = false;
  bool _set = false;

  DataListStream({int width, Stream<List<int>> stream}) {
    if (width != null)
      _width = width;
    if (stream != null)
      set_stream(stream);
  }

  void set_stream(Stream<List<int>> stream) {
    _stream = stream;
    _set = true;
  }
  
  void unset_stream() {
    _stream = Stream<List<int>>.empty();
    _set = false;
  }

  void set_width(int width) {
    _width = width;
    while (_data.length > _width)
      _data.removeAt(0);
    while (_time.length > _width)
      _data.removeAt(0);
  }

  void run() async {
    if (!_set)
      return;
    _run = true;

    await for (var a in _stream) {
      if (!_run)
        break;
      _c++;
      _data.add(a);
      _time.add(DateTime.now());

      while (_data.length > _width)
        _data.removeAt(0);
      while (_time.length > _width)
        _time.removeAt(0);
    }
  }

  void stop() {
    _run = false;
  }

  List<double> getData(int column) {
    List<double> column_data = [];

    for (var a in _data)
      if (a.length > 0)
        column_data.add(a[column].toDouble());
    
    return column_data;
  }

  List<DateTime> getTimes() => _time;
  Stream<List<int>> getStream() => _stream;
  int getC() => _c;
  int getWidth() => _width;
  int getDataLength() => _data.length;
  bool isSet() => _set;
  bool isRunning() => _run;
}