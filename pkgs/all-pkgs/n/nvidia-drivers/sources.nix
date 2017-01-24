{ }:
rec {
  # http://www.nvidia.com/object/unix.html

  tesla = {
    versionMajor = "375";
    versionMinor = "20";
    sha256x86_64 = "d10e40a19dc57ac958567a2b247c2b113e5f1e4186ad48e9a58e70a46d07620b";
  };
  long-lived = {
    versionMajor = "375";
    versionMinor = "26";
    sha256i686   = "7c79cfaae5512f34ff14cf0fe76632c7c720600d4bbae71d90ff73f1674e617b";
    sha256x86_64 = "9cc4abadd47165a17a4f9475e90e91d1b63de63fcc28c4e2e30e10dee845b4b2";
  };
  short-lived = {
    versionMajor = "370";
    versionMinor = "28";
    sha256i686   = "6323254ccf2a75d7ced1374a76ca56778689d0d8a9819e4ee5378ea3347b9835";
    sha256x86_64 = "f498bcf4ddf05725792bd4a1ca9720a88ade81de27bd27f2f3c313723f11444c";
  };
  beta = {
    versionMajor = "378";
    versionMinor = "09";
    sha256i686   = "feaaa52b96f82ed27fa7286b645c6f220984fb2831aac492b037a188f5e63b28";
    sha256x86_64 = "c3c9f33ae3cf2be80a9b46aede4fb02162758194d08fd714b5d01b04df8e4355";
  };
  # Update to which ever channel has the latest release at the time.
  latest = beta;
}
