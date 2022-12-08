import 'dart:math';
import 'package:angles/angles.dart';

bool isset(dynamic value) {
  if (value == null || value == '') return false;
  return true;
}

class RegTriAngle {
  Map<String, dynamic> getTriAngle({
    double? a,
    double? b,
    double? c,
    double? alpha,
    double? betha,
    double? gamma,
  }) {
    try {
      Function fun = this.whichCongruenceTheorem(
        a: a,
        b: b,
        c: c,
        alpha: alpha,
        betha: betha,
        gamma: gamma,
      );
      return fun(
        a: a,
        b: b,
        c: c,
        alpha: alpha,
        betha: betha,
        gamma: gamma,
      );
    } catch (e) {
      print(e);
      return {};
    }
  }

  Map<String, dynamic> sss({
    required double a,
    required double b,
    required double c,
    double? alpha,
    double? betha,
    double? gamma,
  }) {
    Map<String, dynamic> triAngle = {
      'a': a,
      'b': b,
      'c': c,
      'alpha': 0,
      'betha': 0,
      'gamma': 0,
    };
    // GET ALPHA

    double cosA = (a * a - b * b - c * c) / (-2 * b * c);

    double cosB = (b * b - c * c - a * a) / (-2 * c * a);

    double cosG = (c * c - a * a - b * b) / (-2 * a * b);

    var ca = Angle.acos(cosA);
    var cb = Angle.acos(cosB);
    var cg = Angle.acos(cosG);

    triAngle['alpha'] = ca.degrees;
    triAngle['betha'] = cb.degrees;
    triAngle['gamma'] = cg.degrees;

    if ((ca.degrees + cb.degrees + cg.degrees).round() == 180) {
    } else {
      print('ERROR! SSS is not correct!');
      print((ca.degrees + cb.degrees + cg.degrees).round());
    }

    return triAngle;
  }

  Map<String, dynamic> sws({
    double? a,
    double? b,
    double? c,
    double? alpha,
    double? betha,
    double? gamma,
  }) {
    // CHECK IF ALL VARIABLES ARE GIVEN
    List<bool> allVariablesGiven = [];

    if (a != null) {
      allVariablesGiven.add(true);
    }
    if (b != null) {
      allVariablesGiven.add(true);
    }
    if (c != null) {
      allVariablesGiven.add(true);
    }
    if (alpha != null) {
      allVariablesGiven.add(true);
    }
    if (betha != null) {
      allVariablesGiven.add(true);
    }
    if (gamma != null) {
      allVariablesGiven.add(true);
    }
    // CHECK IF ALL VARIABLES ARE RIGHT
    if (gamma != null && betha != null ||
        gamma != null && alpha != null ||
        betha != null && alpha != null) {
      print('FALSE INPUT');
      return {};
    }
    if (allVariablesGiven.length != 3) {
      print('FALSE INPUT');
      return {};
    }

    /**
     * a = Sqr(b * b + c * c - 2 * b * c * cos(α))
     * b = Sqr(a * a + c * c - 2 * a * c * cos(β))
     * c = Sqr(a * a + b * b - 2 * a * b * cos(γ))
    **/

    if (a == null && b != null && c != null && alpha != null) {
      Angle cosAlpha = Angle.degrees(alpha);
      a = sqrt((b * b) + (c * c) - (2 * b * c * cosAlpha.cos));
    }
    if (b == null && a != null && c != null && betha != null) {
      Angle cosBetha = Angle.degrees(betha);
      b = sqrt((a * a) + (c * c) - (2 * a * c * cosBetha.cos));
    }
    if (c == null && a != null && b != null && gamma != null) {
      Angle cosGamma = Angle.degrees(gamma);
      c = sqrt(a * a + b * b - 2 * a * b * cosGamma.cos);
    }

    if (a != null && b != null && c != null) {
      return this.sss(
        a: a,
        b: b,
        c: c,
      );
    } else {
      return {};
    }
  }

  Map<String, dynamic> sww({
    double? a,
    double? b,
    double? c,
    double? alpha,
    double? betha,
    double? gamma,
  }) {
    // CHECK IF ALL VARIABLES ARE GIVEN
    List<bool> allVariablesGiven = [];

    if (a != null) {
      allVariablesGiven.add(true);
    }
    if (b != null) {
      allVariablesGiven.add(true);
    }
    if (c != null) {
      allVariablesGiven.add(true);
    }
    if (alpha != null) {
      allVariablesGiven.add(true);
    }
    if (betha != null) {
      allVariablesGiven.add(true);
    }
    if (gamma != null) {
      allVariablesGiven.add(true);
    }
    // CHECK IF ALL VARIABLES ARE RIGHT
    if (c != null && b != null ||
        c != null && a != null ||
        b != null && a != null) {
      print('FALSE INPUT');
      return {};
    }
    if (allVariablesGiven.length != 3) {
      print('FALSE INPUT');
      return {};
    }

    Map<String, dynamic> angles = this.getLastAngle(
      alpha: alpha,
      betha: betha,
      gamma: gamma,
    );
    alpha = angles['alpha'];
    betha = angles['betha'];
    gamma = angles['gamma'];

    if (alpha != null && betha != null && gamma != null) {
      return this.getTriAngleByWWWS(
        alpha: alpha,
        betha: betha,
        gamma: gamma,
        a: a,
        b: b,
        c: c,
      );
    }
    return {};
  }

  Map<String, dynamic> wsw({
    double? a,
    double? b,
    double? c,
    double? alpha,
    double? betha,
    double? gamma,
  }) {
    Map<String, dynamic> angles = this.getLastAngle(
      alpha: alpha,
      betha: betha,
      gamma: gamma,
    );
    alpha = angles['alpha'];
    betha = angles['betha'];
    gamma = angles['gamma'];

    if (alpha != null && betha != null && gamma != null) {
      return this.getTriAngleByWWWS(
        alpha: alpha,
        betha: betha,
        gamma: gamma,
        a: a,
        b: b,
        c: c,
      );
    }
    return {};
  }

  Map<String, dynamic> wws({
    double? a,
    double? b,
    double? c,
    double? alpha,
    double? betha,
    double? gamma,
  }) {
    return this.wsw(
      a: a,
      b: b,
      c: c,
      alpha: alpha,
      betha: betha,
      gamma: gamma,
    );
  }

  Map<String, dynamic> ssw({
    double? a,
    double? b,
    double? c,
    double? alpha,
    double? betha,
    double? gamma,
  }) {
    bool exit = false;
    if (a != null && b != null && alpha != null && !exit) {
      Angle aBetha = Angle.asin((b * Angle.degrees(alpha).sin) / a);
      betha = aBetha.degrees;
      exit = true;
    }
    if (a != null && b != null && betha != null && !exit) {
      Angle aAlpha = Angle.asin(a * Angle.degrees(betha).sin / b);
      alpha = aAlpha.degrees;
      exit = true;
    }
    if (a != null && c != null && alpha != null && !exit) {
      Angle aGamma = Angle.asin(c * Angle.degrees(alpha).sin / a);
      gamma = aGamma.degrees;
      exit = true;
    }
    if (a != null && c != null && gamma != null && !exit) {
      Angle aAlpha = Angle.asin(a * Angle.degrees(gamma).sin / c);
      alpha = aAlpha.degrees;
      exit = true;
    }
    if (b != null && c != null && betha != null && !exit) {
      Angle aGamma = Angle.asin(c * Angle.degrees(betha).sin / b);
      gamma = aGamma.degrees;
      exit = true;
    }
    if (b != null && c != null && gamma != null && !exit) {
      Angle aBetha = Angle.asin(b * Angle.degrees(gamma).sin / c);
      betha = aBetha.degrees;
      exit = true;
    }

    Map<String, dynamic> angles = this.getLastAngle(
      alpha: alpha,
      betha: betha,
      gamma: gamma,
    );
    alpha = angles['alpha'];
    betha = angles['betha'];
    gamma = angles['gamma'];

    if (alpha != null && betha != null && gamma != null) {
      if (a != null) {
        return this.getTriAngleByWWWS(
          a: a,
          alpha: alpha,
          betha: betha,
          gamma: gamma,
        );
      }
      if (b != null) {
        return this.getTriAngleByWWWS(
          b: b,
          alpha: alpha,
          betha: betha,
          gamma: gamma,
        );
      }
      if (c != null) {
        return this.getTriAngleByWWWS(
          c: c,
          alpha: alpha,
          betha: betha,
          gamma: gamma,
        );
      }
    }
    return {};
  }

  Map<String, dynamic> wss({
    double? a,
    double? b,
    double? c,
    double? alpha,
    double? betha,
    double? gamma,
  }) {
    return this.ssw(
      a: a,
      b: b,
      c: c,
      alpha: alpha,
      betha: betha,
      gamma: gamma,
    );
  }

  Map<String, dynamic> getLastAngle({
    required alpha,
    required betha,
    required gamma,
  }) {
    if (alpha == null && betha != null && gamma != null) {
      alpha = 180 - betha - gamma;
    }
    if (betha == null && alpha != null && gamma != null) {
      betha = 180 - alpha - gamma;
    }
    if (gamma == null && alpha != null && betha != null) {
      gamma = 180 - betha - alpha;
    }
    return {
      'alpha': alpha,
      'betha': betha,
      'gamma': gamma,
    };
  }

  Map<String, dynamic> getTriAngleByWWWS({
    double? a,
    double? b,
    double? c,
    required double alpha,
    required double betha,
    required double gamma,
  }) {
    Angle sinAlpha = Angle.degrees(alpha);
    Angle sinBetha = Angle.degrees(betha);
    Angle sinGamma = Angle.degrees(gamma);

    if (a != null) {
      b = a * sinBetha.sin / sinAlpha.sin;
      c = a * sinGamma.sin / sinAlpha.sin;
    }
    if (b != null) {
      a = b * sinAlpha.sin / sinBetha.sin;
      c = b * sinGamma.sin / sinBetha.sin;
    }
    if (c != null) {
      a = c * sinAlpha.sin / sinGamma.sin;
      b = c * sinBetha.sin / sinGamma.sin;
    }
    return {
      'a': a,
      'b': b,
      'c': c,
      'alpha': alpha,
      'betha': betha,
      'gamma': gamma,
    };
  }

  Function whichCongruenceTheorem({
    double? a,
    double? b,
    double? c,
    double? alpha,
    double? betha,
    double? gamma,
  }) {
    Function congruenceFunction = ({
      double? a,
      double? b,
      double? c,
      double? alpha,
      double? betha,
      double? gamma,
    }) {};

    List<dynamic> parms = [a, b, c, alpha, betha, gamma];

    List<bool> setParms = [];

    for (int i = 0; i < parms.length; i++) {
      if (isset(parms[i])) {
        setParms.add(true);
      }
    }
    if (setParms.length != 3) {
      return () {};
    }

    // CHECK SSS
    if (isset(a) && isset(b) && isset(c)) {
      congruenceFunction = this.sss;
    }
    // CHECK
    if (isset(alpha) && !isset(betha) && !isset(gamma) ||
        isset(betha) && !isset(betha) && !isset(alpha) ||
        isset(gamma) && !isset(betha) && !isset(alpha)) {
      // 1 ANGLE IS SET
      if (isset(a) && isset(b) ||
          isset(a) && isset(c) ||
          isset(b) && isset(c)) {
        // 1 ANGLE AND 2 SITES ARE SET
        congruenceFunction = this.sws;
      }
    }

    if (isset(a) && !isset(b) && !isset(c) ||
        isset(b) && !isset(c) && !isset(a) ||
        isset(c) && !isset(b) && !isset(a)) {
      // 1 SITE IS SET
      if (isset(alpha) && isset(betha) ||
          isset(alpha) && isset(gamma) ||
          isset(betha) && isset(gamma)) {
        // 1 SITE AND 2 ANGLES ARE SET
        congruenceFunction = this.wsw;
      }
    }
    return congruenceFunction;
  }

  Map<String, double> calcTriangleHeights({
    required double a,
    required double b,
    required double c,
    required double alpha,
    required double betha,
    required double gamma,
  }) =>
      {
        'ha': b * Angle.degrees(gamma).sin,
        'hb': c * Angle.degrees(alpha).sin,
        'hc': a * Angle.degrees(betha).sin,
      };

  double calcArea({
    required double a,
    required double b,
    required double c,
    required double alpha,
    required double betha,
    required double gamma,
  }) {
    double hc = calcTriangleHeights(
      a: a,
      b: b,
      c: c,
      alpha: alpha,
      betha: betha,
      gamma: gamma,
    )['hc']!;

    return (c * hc) / 2;
  }

  double radOuterCircle({
    required double a,
    required double b,
    required double c,
    required double alpha,
    required double betha,
    required double gamma,
  }) {
    return a / (2 * Angle.degrees(alpha).sin);
  }

  double radInnerCircle({
    required double a,
    required double b,
    required double c,
    required double alpha,
    required double betha,
    required double gamma,
  }) {
    return c *
        Angle.degrees(alpha / 2).sin *
        Angle.degrees(betha / 2).sin /
        Angle.degrees((alpha + betha) / 2).sin;
  }
}
