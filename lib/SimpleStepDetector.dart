import 'dart:math';

import 'package:pedometer_google/SensorFusionMath.dart';
import 'package:pedometer_google/StepListener.dart';

class SimpleStepDetector {
  static final VEL_RING_SIZE = 10;
  static final ACCEL_RING_SIZE = 50;
  static final STEP_THRESHOLD = 4;
  static final STEP_DELAY_NS = 256000000;

  int accelRingCounter = 0;
  List<double> accelRingX =
      List<double>.filled(ACCEL_RING_SIZE, 0, growable: true);
  List<double> accelRingY =
      List<double>.filled(ACCEL_RING_SIZE, 0, growable: true);
  List<double> accelRingZ =
      List<double>.filled(ACCEL_RING_SIZE, 0, growable: true);
  int velRingCounter = 0;
  List<double> velRing = List<double>.filled(VEL_RING_SIZE, 0, growable: true);
  int lastStepTimeNs = 0;
  double oldVelocityEstimate = 0;

  StepListener listener;

  void registerListener(StepListener listener) {
    this.listener = listener;
  }

  /**
   * Accepts updates from the accelerometer.
   */
  void updateAccel(int timeNs, double x, double y, double z, bool isIOS) {
    List<double> currentAccel = List<double>.filled(3, 0, growable: true);
    currentAccel[0] = x;
    currentAccel[1] = y;
    currentAccel[2] = z;

    // First step is to update our guess of where the global z vector is.
    accelRingCounter++;
    accelRingX[accelRingCounter % ACCEL_RING_SIZE] = currentAccel[0];
    accelRingY[accelRingCounter % ACCEL_RING_SIZE] = currentAccel[1];
    accelRingZ[accelRingCounter % ACCEL_RING_SIZE] = currentAccel[2];

    List<double> worldZ = List<double>.filled(3, 0, growable: true);
    worldZ[0] = SensorFusionMath.sum(accelRingX) /
        min(accelRingCounter, ACCEL_RING_SIZE);
    worldZ[1] = SensorFusionMath.sum(accelRingY) /
        min(accelRingCounter, ACCEL_RING_SIZE);
    worldZ[2] = SensorFusionMath.sum(accelRingZ) /
        min(accelRingCounter, ACCEL_RING_SIZE);

    double normalization_factor = SensorFusionMath.norm(worldZ);

    worldZ[0] = worldZ[0] / normalization_factor;
    worldZ[1] = worldZ[1] / normalization_factor;
    worldZ[2] = worldZ[2] / normalization_factor;

    // Next step is to figure out the component of the current acceleration
    // in the direction of world_z and subtract gravity's contribution
    double currentZ =
        SensorFusionMath.dot(worldZ, currentAccel) - normalization_factor;
    velRingCounter++;
    velRing[velRingCounter % VEL_RING_SIZE] = currentZ;

    double velocityEstimate = SensorFusionMath.sum(velRing);

    print(
        'velocityEstimate: $velocityEstimate --- STEP_THRESHOLD: $STEP_THRESHOLD');

    // if (velocityEstimate > STEP_THRESHOLD &&
    //     oldVelocityEstimate <= STEP_THRESHOLD) {
    //   print('DETECTOU!!');
    //   listener.step(timeNs);
    //   lastStepTimeNs = timeNs;
    // }
    if (isIOS) {
      if (velocityEstimate > STEP_THRESHOLD &&
          oldVelocityEstimate <= STEP_THRESHOLD) {
        print('DETECTOU!!');
        listener.step(timeNs);
        lastStepTimeNs = timeNs;
      }
      oldVelocityEstimate = velocityEstimate;
    } else {
      double sensibility = 0.065;
      double velocity = velocityEstimate.abs();
      double oldVel = oldVelocityEstimate.abs();
      if (velocity > 0.1)
      // if (velocityEstimate.abs() > 0.1 && oldVelocityEstimate.abs() <= 0.1) //&&
      // (timeNs - lastStepTimeNs > 25600000))
      {
        listener.step(timeNs);
        lastStepTimeNs = timeNs;
      }
      oldVelocityEstimate = velocityEstimate;
    }
  }
}
