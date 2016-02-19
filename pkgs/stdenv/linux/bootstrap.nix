{ lib
, hostSystem
}:

if [ hostSystem ] == lib.platforms.x86_64-linux then {
  busybox = import <nix/fetchurl.nix> {
    url = http://pub.wak.io/nixos/bootstrap/x86_64-linux/jprqmvg63zz7bpki4qavw9a88vnz15g9/busybox;
    sha256 = "0n3iyl9anh032v1g3h8834pf0vvd2fyqvj9cfilbbdfv7sa9a2j5";
    executable = true;
  };

  bootstrapTools = import <nix/fetchurl.nix> {
    url = http://pub.wak.io/nixos/bootstrap/x86_64-linux/jprqmvg63zz7bpki4qavw9a88vnz15g9/bootstrap-tools.tar.xz;
    sha256 = "f96220408e8e87bcadf1f947b9c476b4149ddd2a32b16d8c2578321102ca4ce8";
  };

  langC = true;
  langCC = true;
  isGNU = true;
} else if [ hostSystem ] == lib.platforms.i686-linux then {
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
} else null
