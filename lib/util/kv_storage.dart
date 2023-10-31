import 'dart:convert';
import 'dart:io';

import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

//KV存储
abstract class KvStorage {
  void set<T>(String key, T? value);
  T? get<T>(String key);
  List<String> getKeys();
  void clear();
}

class KvStoragePreferenceImpl implements KvStorage {
  final SharedPreferences prefs;

  KvStoragePreferenceImpl(this.prefs);
  @override
  void clear() {
    prefs.clear();
  }

  @override
  T? get<T>(String key) {
    if (!prefs.containsKey(key)) {
      return null;
    }
    if (T == String) {
      return prefs.getString(key) as T?;
    } else if (T == int) {
      return prefs.getInt(key) as T?;
    } else if (T == double) {
      return prefs.getDouble(key) as T?;
    } else if (T == bool) {
      return prefs.getBool(key) as T?;
    } else if (T == List<String>) {
      return prefs.getStringList(key) as T?;
    } else if (T == Map<String, dynamic>) {
      return jsonDecode(prefs.getString(key)!) as T?;
    } else {
      throw UnsupportedError('Unsupported type: $T');
    }
  }

  @override
  List<String> getKeys() {
    return prefs.getKeys().toList();
  }

  @override
  void set<T>(String key, T? value) {
    if (value == null) {
      prefs.remove(key);
      return;
    }
    if (value is String) {
      prefs.setString(key, value);
    } else if (value is int) {
      prefs.setInt(key, value);
    } else if (value is double) {
      prefs.setDouble(key, value);
    } else if (value is bool) {
      prefs.setBool(key, value);
    } else if (value is List<String>) {
      prefs.setStringList(key, value);
    } else if (value is Map<String, dynamic>) {
      prefs.setString(key, jsonEncode(value));
    } else {
      throw UnsupportedError('Unsupported type: $T');
    }
  }
}

class KvStorageLogWrapper implements KvStorage {
  final KvStorage source;
  final Logger logger;
  KvStorageLogWrapper({
    required this.source,
    required this.logger,
  });
  @override
  void clear() {
    logger.d('[${source.runtimeType.toString()}] clear');
    source.clear();
  }

  @override
  T? get<T>(String key) {
    final value = source.get<T>(key);
    logger.d('[${source.runtimeType.toString()}] get $key: $value');
    return value;
  }

  @override
  List<String> getKeys() {
    final keys = source.getKeys();
    logger.d('[${source.runtimeType.toString()}] getKeys: $keys');
    return keys;
  }

  @override
  void set<T>(String key, T? value) {
    logger.d('[${source.runtimeType.toString()}] set $key: $value');
    source.set(key, value);
  }
}

class KvStorageMapImpl implements KvStorage {
  final Map<String, dynamic> data;

  KvStorageMapImpl({this.data = const {}});
  @override
  void set<T>(String key, T? value) {
    if (value == null) {
      data.remove(key);
      return;
    } else {
      data[key] = value;
    }
  }

  @override
  T? get<T>(String key) {
    return data[key] as T?;
  }

  @override
  void clear() {
    data.clear();
  }

  @override
  List<String> getKeys() {
    return data.keys.toList();
  }
}

class KvStorageWithListener extends KvStorage {
  final KvStorage source;
  final void Function(
    String key,
    dynamic value,
    void Function(String key, dynamic value) handle,
  )? onSet;

  final dynamic Function(
    String key,
    dynamic Function(String key) handle,
  )? onGet;

  final void Function(
    void Function() handle,
  )? onClear;

  final List<String> Function(
    List<String> Function() handle,
  )? onGetKeys;

  KvStorageWithListener({
    required this.source,
    this.onSet,
    this.onGet,
    this.onClear,
    this.onGetKeys,
  });

  @override
  void clear() {
    if (onClear != null) {
      onClear!(source.clear);
    } else {
      source.clear();
    }
  }

  @override
  T? get<T>(String key) {
    if (onGet != null) {
      return onGet!(key, source.get);
    } else {
      return source.get(key);
    }
  }

  @override
  void set<T>(String key, T? value) {
    if (onSet != null) {
      onSet!(key, value, source.set);
    } else {
      source.set(key, value);
    }
  }

  @override
  List<String> getKeys() {
    if (onGetKeys != null) {
      return onGetKeys!(source.getKeys);
    } else {
      return source.getKeys();
    }
  }
}

class KvStorageWithNamespace extends KvStorage {
  final KvStorage source;
  final String namespace;

  KvStorageWithNamespace({
    required this.source,
    required this.namespace,
  });

  @override
  void clear() {
    source.clear();
  }

  @override
  T? get<T>(String key) {
    return source.get<T>("$namespace/$key");
  }

  @override
  void set<T>(String key, T? value) {
    source.set("$namespace/$key", value);
  }

  @override
  List<String> getKeys() {
    return source
        .getKeys()
        .where((element) => element.startsWith("$namespace/"))
        .map((e) => e.substring(namespace.length + 1))
        .toList();
  }
}

class KvStorageJsonImpl extends KvStorage {
  final Map<String, dynamic> data = {};
  late final KvStorageMapImpl source = KvStorageMapImpl(data: data);
  final void Function(String json)? onJsonChanged;

  KvStorageJsonImpl({
    this.onJsonChanged,
  });
  @override
  void clear() {
    source.clear();
    onJsonChanged?.call(jsonEncode(data));
  }

  @override
  T? get<T>(String key) {
    return source.get<T>(key);
  }

  @override
  void set<T>(String key, T? value) {
    source.set(key, value);
    onJsonChanged?.call(jsonEncode(data));
  }

  @override
  List<String> getKeys() {
    return source.getKeys();
  }
}

class KvStorageJsonFileImpl extends KvStorageJsonImpl {
  KvStorageJsonFileImpl(File jsonFile)
      : super(onJsonChanged: (json) {
          jsonFile.writeAsStringSync(json);
        });
}
