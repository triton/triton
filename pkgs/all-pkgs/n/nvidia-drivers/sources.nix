{ }:
rec {
  # http://www.nvidia.com/object/unix.html

  tesla = {
    versionMajor = "352";
    versionMinor = "99";
    sha256x86_64 = "055ee6acd3ca1f4a07fdb1a4a16abb9abc6bfcb17fe2158808060838a4e84b83";
  };
  long-lived = {
    versionMajor = "375";
    versionMinor = "20";
    sha256i686   = "cc79d3ac2b688009ed2e47a1cf27557aea5dd745b3b6e9b83945c359ddab4335";
    sha256x86_64 = "ef2e71b6eef6ce2ee2556c1449d129380f0312b5a6a51bd8483fd60f8df0b9bf";
  };
  short-lived = {
    versionMajor = "370";
    versionMinor = "28";
    sha256i686   = "6323254ccf2a75d7ced1374a76ca56778689d0d8a9819e4ee5378ea3347b9835";
    sha256x86_64 = "f498bcf4ddf05725792bd4a1ca9720a88ade81de27bd27f2f3c313723f11444c";
  };
  beta = {
    versionMajor = "375";
    versionMinor = "10";
    sha256i686   = "77c06d9c6831d6d1b53276d0741eddac4aab2f2f02b7c1fe14b86aa982aacd69";
    sha256x86_64 = "7049a8dc8948f5d67f6eb3fac627ac0933270e992b1892401b0134c4bd33ccf6";
  };
  # Update to which ever channel has the latest release at the time.
  latest = long-lived;
}
