{ }:
rec {
  # http://www.nvidia.com/object/unix.html

  tesla = {
    versionMajor = "375";
    versionMinor = "20";
    sha256x86_64 = "d10e40a19dc57ac958567a2b247c2b113e5f1e4186ad48e9a58e70a46d07620b";
    maxLinuxVersion = "4.10";
  };
  long-lived = {
    versionMajor = "375";
    versionMinor = "66";
    sha256i686   = "29220e249a308f89c2a6fa48be6a0009d58f082d07d3fedfbf4ab0015559f14c";
    sha256x86_64 = "26f3133dd053835c35fb27b04fccd3a3bb4f18bbbacb5e4bf89c40d142cab397";
    maxLinuxVersion = "4.12";
  };
  short-lived = {
    versionMajor = "381";
    versionMinor = "22";
    sha256i686   = "7b7dd6ee1c871dc5367fc207bba65077c3820a683decbfe6126fc70c0d1b9d08";
    sha256x86_64 = "c2468130af124bfe748bdf2bc4c08952a81b35d2bdb87d1217717e6a576217e8";
    maxLinuxVersion = "4.12";
  };
  beta = {
    versionMajor = "384";
    versionMinor = "47";
    sha256i686   = "433917c5feca240abd936eecfbbd020b3773afead083802afee3b56d8a5bc256";
    sha256x86_64 = "5bcdcda592c5463bf9c19918253ae07c37169a2c75cbedcd868d1206c2f7f286";
    maxLinuxVersion = "4.12";
  };
  # Update to which ever channel has the latest release at the time.
  latest = beta;
}
