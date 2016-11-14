{ }:
rec {
  # http://www.nvidia.com/object/unix.html

  tesla = {
    versionMajor = "352";
    versionMinor = "99";
    sha256x86_64 = "055ee6acd3ca1f4a07fdb1a4a16abb9abc6bfcb17fe2158808060838a4e84b83";
  };
  long-lived = {
    versionMajor = "367";
    versionMinor = "57";
    sha256i686   = "b2ad4d0d4a2e98528e877ae0d98c38039c2400b09cfb5928cd21899f3a991291";
    sha256x86_64 = "b94a8ab6a1da464b44ba9bbb25e1e220441ae8340221de3bd159df00445dd6e4";
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
  latest = beta;
}
