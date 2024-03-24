

extension LogObject on Object {

  void logD([String content = '']) {
    print("[$runtimeType] $content");
  }

  void logE([String content = '']) {
    print("[Error][$runtimeType] $content");
  }
}