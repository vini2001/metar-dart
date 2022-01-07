part of models;

abstract class Group {
  late final String? _code;

  Group(String? code) {
    if (code != null) {
      code = code.replaceAll('_', ' ');
    }

    _code = code;
  }

  /// Get the code of the group.
  String? get code => _code;
}

/// Basic structure of a groups list from groups found in a aeronautical
///  report from land stations.
class GroupList<T extends Group> {
  final int _maxItems;
  final _list = <T>[];

  GroupList(this._maxItems);

  @override
  String toString() {
    return _list.join(' | ');
  }

  T operator [](int index) {
    if (index >= _maxItems) {
      throw RangeError("can't get more than $_maxItems items in $runtimeType");
    }
    return _list[index];
  }

  /// Adds groups to the list.
  void add(T group) {
    if (_list.length >= _maxItems) {
      throw RangeError("can't set more than $_maxItems groups in $runtimeType");
    }
    _list.add(group);
  }

  /// Get an iterator from the groups found in report.
  Iterator<T> get iter => _list.iterator;

  /// Get the length of the items.
  int get length => _list.length;

  /// Get the codes of every group found in the report as a List<String>.
  List<String?> get codes => _list.map((group) => group.code).toList();

  /// Get the groups found in report as a List<Group>.
  List<T> get items => _list;
}