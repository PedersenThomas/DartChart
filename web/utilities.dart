library Utilities;

import 'dart:math';

Random ran = new Random();
String randomColor() {
  String randomColor = '';
  int randomNumber = ran.nextInt(256);
  randomColor += randomNumber.toRadixString(16).length == 2 ? randomNumber.toRadixString(16) : '0${randomNumber.toRadixString(16)}';
  randomNumber = ran.nextInt(256);
  randomColor += randomNumber.toRadixString(16).length == 2 ? randomNumber.toRadixString(16) : '0${randomNumber.toRadixString(16)}';
  randomNumber = ran.nextInt(256);
  randomColor += randomNumber.toRadixString(16).length == 2 ? randomNumber.toRadixString(16) : '0${randomNumber.toRadixString(16)}';

  return '#$randomColor';
}

class KeyValuePair<K, V> {
  K key;
  V value;

  KeyValuePair(this.key, this.value);
}
