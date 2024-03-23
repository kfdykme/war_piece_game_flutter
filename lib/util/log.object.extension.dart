

extension LogObject on Object {

  void logD([String content = '']) {
    print("[$runtimeType] $content");
  }
}