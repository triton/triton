{
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
}
