import 'dart:math';

class SensorFusionMath {
  static double sum(List<double> array) {
    double retval = 0;
    for (int i = 0; i < array.length; i++) {
      retval += array[i];
    }
    return retval;
  }

  static List<double> cross(List<double> arrayA, List<double> arrayB) {
    List<double> retArray = List<double>.filled(3, 0, growable: true);
    retArray[0] = arrayA[1] * arrayB[2] - arrayA[2] * arrayB[1];
    retArray[1] = arrayA[2] * arrayB[0] - arrayA[0] * arrayB[2];
    retArray[2] = arrayA[0] * arrayB[1] - arrayA[1] * arrayB[0];
    return retArray;
  }

  static double norm(List<double> array) {
    double retval = 0;
    for (int i = 0; i < array.length; i++) {
      retval += array[i] * array[i];
    }
    return sqrt(retval);
  }

  // Note: only works with 3D vectors.
  static double dot(List<double> a, List<double> b) {
    double retval = a[0] * b[0] + a[1] * b[1] + a[2] * b[2];
    return retval;
  }

  static List<double> normalize(List<double> a) {
    List<double> retval = [];
    double norm = SensorFusionMath.norm(a);
    for (int i = 0; i < a.length; i++) {
      retval[i] = a[i] / norm;
    }
    return retval;
  }
}
