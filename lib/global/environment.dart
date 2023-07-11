import 'dart:io';

class Environment {
  static String apiUrl = 'https://flutterchat-socket-server.herokuapp.com/api';
  // Platform.isAndroid
  //     ? 'http://10.0.2.2:3000/api'
  //     : 'http://localhost:3000/api';

  static String socketUrl = 'https://flutterchat-socket-server.herokuapp.com';
  // Platform.isAndroid ? 'http://10.0.2.2:3000' : 'http://localhost:3000';

  static String socketUrlAuthority = 'flutterchat-socket-server.herokuapp.com';
}
