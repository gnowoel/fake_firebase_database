library fake_firebase_database;

import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

import 'src/utils/utils.dart';

part 'src/fake_data_snapshot.dart';
part 'src/fake_database_event.dart';
part 'src/fake_database_reference.dart';
part 'src/fake_firebase_database.dart';
part 'src/fake_on_disconnect.dart';
part 'src/fake_query.dart';
part 'src/fake_transaction_result.dart';

class MockFirebaseApp implements FirebaseApp {
  final String _name;

  MockFirebaseApp([this._name = defaultFirebaseAppName]);

  @override
  String get name => _name;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
