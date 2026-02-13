enum ReleaseMode { live, debug }

class ReleaseConfig {
  static ReleaseMode currentMode = ReleaseMode.debug;

  static String get baseUrl {
    switch (currentMode) {
      case ReleaseMode.live:
        return 'http://3.87.42.110:4002/';
      case ReleaseMode.debug:
        return 'http://192.168.1.25:4003/';
      default:
        return "http://50.19.13.68:8080/";
    }
  }
}
