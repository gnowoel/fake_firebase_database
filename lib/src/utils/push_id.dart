// Based on the official Firebase implementation:
// https://firebase.blog/posts/2015/02/the-2120-ways-to-ensure-unique_68

import 'dart:math';

const s1 = '-';
const s2 = '0123456789';
const s3 = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
const s4 = '_';
const s5 = 'abcdefghijklmnopqrstuvwxyz';

final Random _random = Random();

class PushId {
  static const String chars = s1 + s2 + s3 + s4 + s5;

  static int? _then;

  static final List<int> _salt = List.filled(12, 0);

  static String generate() {
    int now = DateTime.now().millisecondsSinceEpoch;
    final List<String> head = List.filled(8, '');

    for (var i = 7; i >= 0; i--) {
      head[i] = chars[now % 64];
      now = (now / 64).floor();
    }

    if (_then != now) {
      for (var i = 0; i < 12; i++) {
        _salt[i] = _random.nextInt(64);
      }
      _then = now;
    } else {
      for (var i = 11; i >= 0; i--) {
        if (_salt[i] != 63) {
          _salt[i] = _salt[i] + 1;
          break;
        }
        _salt[i] = 0;
      }
    }

    final tail = _salt.map((n) => chars[n]);
    return head.join() + tail.join();
  }
}
