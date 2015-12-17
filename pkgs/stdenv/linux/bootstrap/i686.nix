{
  busybox = import <nix/fetchurl.nix> {
    url = http://pub.wak.io/nixos/bootstrap/i686-linux/p2mrfb36zd3a6jzsa2pqkw6kq8908xql/busybox;
    sha256 = "0542ly23wl4lvymhxpc992qaaq9065gsajybv2b6mh2cklzn1g71";
    executable = true;
  };

  bootstrapTools = import <nix/fetchurl.nix> {
    url = http://pub.wak.io/nixos/bootstrap/i686-linux/p2mrfb36zd3a6jzsa2pqkw6kq8908xql/bootstrap-tools.tar.xz;
    sha256 = "ddb1f3aa00bf65963e1dd27218b430603ad96985416078eac93de3005d479be5";
  };
}
