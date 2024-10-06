// Based on the official Firebase implementation:
// https://firebase.blog/posts/2015/02/the-2120-ways-to-ensure-unique_68

import 'dart:math';

const _s1 = '-';
const _s2 = '0123456789';
const _s3 = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
const _s4 = '_';
const _s5 = 'abcdefghijklmnopqrstuvwxyz';

final Random _random = Random();

class PushId {
  static const String _chars = _s1 + _s2 + _s3 + _s4 + _s5;

  static int? _then;

  static final List<int> _salt = List.filled(12, 0);

  static String generate() {
    int now = DateTime.now().millisecondsSinceEpoch;
    final List<String> head = List.filled(8, '');

    for (var i = 7; i >= 0; i--) {
      head[i] = _chars[now % 64];
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

    final tail = _salt.map((n) => _chars[n]);
    return head.join() + tail.join();
  }
}
