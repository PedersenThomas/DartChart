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

/**
 * Gives a more hunam friendly top value for an axis.
 */
double fittedAxisTopValue(double maxValue) {
  if (maxValue == null || maxValue == 0.0) {
    return 0.0;
  }
  const double prettyFactor = 0.5;
  int exponent = ( (log(maxValue) / LN10) - prettyFactor).floor();

  return (maxValue / (pow(10, exponent))).ceil() * pow(10, exponent).toDouble();
}

class KeyValuePair<K, V> {
  K key;
  V value;

  KeyValuePair(this.key, this.value);
}
