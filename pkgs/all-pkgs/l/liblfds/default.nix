{ stdenv
, fetchurl
}:

let
  version = "7.1.0";
in
stdenv.mkDerivation rec {
  name = "liblfds-${version}";

  src = fetchurl {
    name = "${name}.tar.bz2";
    url = "http://liblfds.org/downloads/liblfds%20release%20${version}%20source.tar.bz2";
    multihash = "QmSeve2vQztke4ZMoPNtodVgJpMbEDoYKhCq9mfegfgpFe";
    md5Confirm = "bad98e370d9a6035919f421b929ae22e";
    sha256 = "d6b79a94adf4d83469efbe47730a5d0a803d92b875c249b6bf0ff0a1264ef7c3";
  };

  prePatch = ''
    cd *${version}*/liblfds*/build/gcc_gnumake
  '';

  postPatch = ''
    fileversion="$(echo '${version}' | tr -d '.')"
    sed -i "s,liblfds$fileversion,liblfds," Makefile
  '';

  buildFlags = [
    "ar_rel"
    "so_rel"
  ];

  installTargets = [
    "ar_install"
    "so_install"
  ];

  preInstall = ''
    installFlagsArray+=(
      "INSINCDIR=$out/include"
      "INSLIBDIR=$out/lib"
    )
  '';

  postInstall = ''
    ln -sv lib "$out/bin"
    ln -s "liblfds$fileversion.h" "$out/include/liblfds.h"
  '';

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
