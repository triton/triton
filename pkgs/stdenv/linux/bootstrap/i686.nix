{
  busybox = import <nix/fetchurl.nix> {
    url = http://pub.wak.io/nixos/bootstrap/i686-linux/ygk76d6amwb610f10nqnq08h1gmmc3j0/busybox;
    sha256 = "16f62zvr1w1ffyn84n4yspb549awnx6jf778i3wh5893i0d4dsv9";
    executable = true;
  };

  bootstrapTools = import <nix/fetchurl.nix> {
    url = http://pub.wak.io/nixos/bootstrap/i686-linux/ygk76d6amwb610f10nqnq08h1gmmc3j0/bootstrap-tools.tar.xz;
    sha256 = "af7b3bde18fdf951588c05c1503ef504e0ae87be296161021ede4df0989b4acc";
  };

  langC = true;
  langCC = true;
  isGNU = true;
}
