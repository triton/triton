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
    versionMinor = "39";
    sha256i686   = "7f33f6572c5c5c57df71531749c7339309a2097918375685ea8018826cf19456";
    sha256x86_64 = "95a3221292f357fbd77697b9bb78d1694def5761202f695ef2065c61efb2ddd8";
  };
  short-lived = {
    versionMajor = "378";
    versionMinor = "13";
    sha256i686   = "05e62a6098aac7373438ee381072253a861d56522f74948c2b714e20e69a46b1";
    sha256x86_64 = "a97a2ab047759a0b2c4abab5601e6f027230d355615ee745e24e738ee21cf5da";
  };
  beta = {
    versionMajor = "378";
    versionMinor = "09";
    sha256i686   = "feaaa52b96f82ed27fa7286b645c6f220984fb2831aac492b037a188f5e63b28";
    sha256x86_64 = "c3c9f33ae3cf2be80a9b46aede4fb02162758194d08fd714b5d01b04df8e4355";
  };
  # Update to which ever channel has the latest release at the time.
  latest = short-lived;
}
