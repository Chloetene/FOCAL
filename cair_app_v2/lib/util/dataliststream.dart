import 'dart:async';
import 'dart:math';

/// Wrapper for stream pushing into list (not generic)
class DataListStream {
  Stream<List<int>> _stream;
  List<List<int>> _data = [];
  int _width = 1;
  int _c = 0;
  bool _run = false;
  bool _set = false;

  DataListStream({int width, Stream<List<int>> stream}) {
    if (width != null)
      _width = width;
    if (stream != null)
      set_stream(stream);
  }

  void set_stream(Stream<List<int>> stream) {
    _set = true;
    _stream = stream;
  }
  
  void unset_stream() {
    _stream = Stream<List<int>>.empty();
    _set = false;
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

      if (_data.length > _width)
        _data.removeAt(0);
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

  Stream<List<int>> getStream() => _stream;
  int getC() => _c;
  int getWidth() => _width;
  bool isSet() => _set;
  bool isRunning() => _run;
}