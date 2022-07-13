{ stdenv, fetchurl, lib }:
let
  version = "22-1.1";

  path = "etc/modprobe.d/aliases.conf";

drv = stdenv.mkDerivation {
  name = "kmod-debian-aliases-${version}";

  src = fetchurl {
    url = "mirror://debian/pool/main/k/kmod/kmod_${version}.debian.tar.xz";
    multihash = "QmbWo6UdawzzaYyo1c9QWZVLDCoMVqBGo2VrWugYYZeUmU";
    sha256 = "b02a6c171ddc5cb6ccb87d700132e937ac563533de2ba5a76558ee45acb84a35";
  };

  patchPhase = ''
    patch -i patches/aliases_conf
  '';

  installPhase = ''
    file="$out/${path}"
    mkdir -p "$(dirname "$file")"
    cp aliases.conf "$file"
  '';

  passthru = {
    file = "${drv}/${path}";
  };

  meta = {
    homepage = https://packages.debian.org/source/sid/kmod;
    description = "Linux configuration file for modprobe";
    maintainers = with lib.maintainers; [ mathnerd314 ];
  };
};
in drv
