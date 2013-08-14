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
  int digits = (log(maxValue) / LN10).floor();
  if(digits <= 1) {
    digits = 2;
  }
  
  int modulus = pow(10, digits-1).toInt();
  if (maxValue % modulus != 0){
    maxValue += modulus - maxValue % modulus;
  }

  return maxValue;
}

class KeyValuePair<K, V> {
  K key;
  V value;

  KeyValuePair(this.key, this.value);
}
