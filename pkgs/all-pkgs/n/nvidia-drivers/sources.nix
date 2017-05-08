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
    versionMinor = "66";
    sha256i686   = "29220e249a308f89c2a6fa48be6a0009d58f082d07d3fedfbf4ab0015559f14c";
    sha256x86_64 = "26f3133dd053835c35fb27b04fccd3a3bb4f18bbbacb5e4bf89c40d142cab397";
  };
  short-lived = {
    versionMajor = "378";
    versionMinor = "13";
    sha256i686   = "05e62a6098aac7373438ee381072253a861d56522f74948c2b714e20e69a46b1";
    sha256x86_64 = "a97a2ab047759a0b2c4abab5601e6f027230d355615ee745e24e738ee21cf5da";
  };
  beta = {
    versionMajor = "381";
    versionMinor = "09";
    sha256i686   = "c39805e6610f710d16acf57c9d09cb5504d33c557e634e632079d46f18da4268";
    sha256x86_64 = "ff433aa127a602a3cdf6d308faab841a64e02f32a750caf0dc3999f0a3b70120";
  };
  # Update to which ever channel has the latest release at the time.
  latest = beta;
}
