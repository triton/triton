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
    versionMajor = "384";
    versionMinor = "69";
    sha256i686   = "3b70587582220ab1102bcb8386f206f89e6b146856af41f16eaa5910e54ef8fd";
    sha256x86_64 = "1011b9a9db903d243ff722fc7982da7b91dc91f4b82c60227d89b812aa67257f";
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
  latest = long-lived;
}
