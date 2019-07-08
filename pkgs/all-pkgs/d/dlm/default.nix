{ stdenv
, fetchzip
, which

, dlm_lib
, corosync
, libqb
, libxml2
, pacemaker
, systemd_lib

, type
}:

let
  inherit (stdenv.lib)
    optionalString
    optionals;

  prefix = optionalString (type == "lib") "lib";
  version = "4.0.9";
in
stdenv.mkDerivation {
  name = "${prefix}dlm-${version}";

  src = fetchzip {
    version = 6;
    url = "https://pagure.io/dlm/archive/dlm-${version}/dlm-dlm-${version}.tar.gz";
    multihash = "Qma6shNbPkbtrfPZ7drYcugBmwURMay4zKqXTMe6aEhxtZ";
    sha256 = "50ddcc2c6822621db3c80a72c7281a11d4c6b6847121d7b5a0a07e69806a573b";
  };

  nativeBuildInputs = [
    which
  ];

  buildInputs = optionals (type != "lib") [
    dlm_lib
    corosync
    libqb
    libxml2
    pacemaker
    systemd_lib
  ];

  postPatch = ''
    sed -i '1i#include <sys/sysmacros.h>' libdlm/libdlm.c
  '' + optionalString (type != "lib") ''
    rm -r libdlm
  '';

  makeFlags = [
    "all"
  ];

  preBuild = optionalString (type == "lib") ''
    cd libdlm
  '' + ''
    makeFlagsArray+=(
      "PREFIX=$out"
      "UDEVDIR=$out/lib/udev/rules.d"
    )
  '';

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
