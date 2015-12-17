{
  busybox = import <nix/fetchurl.nix> {
    url = http://pub.wak.io/nixos/bootstrap/x86_64-linux/92ziz73lv75772pflvyp6rbnddcw1h10/busybox;
    sha256 = "1q8ycgypj40g8ciwcjgf22v1ca2pssvyd65qyxvmff300hfwpyqn";
    executable = true;
  };

  bootstrapTools = import <nix/fetchurl.nix> {
    url = http://pub.wak.io/nixos/bootstrap/x86_64-linux/92ziz73lv75772pflvyp6rbnddcw1h10/bootstrap-tools.tar.xz;
    sha256 = "360de75a3922a6606fb324e74c1090a51f63b581278ba93b85d180076cbed330";
  };
}
