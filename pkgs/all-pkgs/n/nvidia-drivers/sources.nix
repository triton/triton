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
    versionMajor = "381";
    versionMinor = "22";
    sha256i686   = "7b7dd6ee1c871dc5367fc207bba65077c3820a683decbfe6126fc70c0d1b9d08";
    sha256x86_64 = "c2468130af124bfe748bdf2bc4c08952a81b35d2bdb87d1217717e6a576217e8";
  };
  beta = {
    versionMajor = "381";
    versionMinor = "09";
    sha256i686   = "c39805e6610f710d16acf57c9d09cb5504d33c557e634e632079d46f18da4268";
    sha256x86_64 = "ff433aa127a602a3cdf6d308faab841a64e02f32a750caf0dc3999f0a3b70120";
  };
  # Update to which ever channel has the latest release at the time.
  latest = short-lived;
}
