import 'package:fake_firebase_database/src/utils/push_id.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PushId', () {
    test('`generate()` can generate a push ID', () async {
      final pushId = PushId.generate();

      expect(pushId.length, 20);
    });

    test('push IDs should be unique', () async {
      final pushIds = <String>[];

      for (var i = 0; i < 50; i++) {
        pushIds.add(PushId.generate());
      }

      final uniqueIds = pushIds.toSet();
      expect(pushIds.length, uniqueIds.length);
    });

    test('push IDs are generated in chronological order', () async {
      final pushIds = <String>[];

      for (var i = 0; i < 10; i++) {
        pushIds.add(PushId.generate());
      }

      final sortedIds = List<String>.from(pushIds)..sort();
      expect(pushIds, sortedIds);
    });
  });
}
