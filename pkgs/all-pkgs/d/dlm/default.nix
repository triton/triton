{ stdenv
, fetchurl
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
in
stdenv.mkDerivation rec {
  name = "${prefix}dlm-4.0.7";

  src = fetchurl {
    url = "https://releases.pagure.org/dlm/${name}.tar.gz";
    multihash = "QmUWpz7UYFaUyG542YAXPwX2s8nFsPXRi1HiiX4VTTig6b";
    sha256 = "639ddfc82369272a68d56816689736c00b8f1b6b2869a6b66b7dbf6dad86469a";
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

  postPatch = optionalString (type != "lib") ''
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
