{ stdenv
, fetchurl
, lib

, subunit_lib
}:

let
  inherit (lib)
    optionalString;

  version = "0.12.0";
in
stdenv.mkDerivation rec {
  name = "check-${version}";

  src = fetchurl {
    url = "https://github.com/libcheck/check/releases/download/${version}/"
      + "${name}.tar.gz";
    sha256 = "464201098bee00e90f5c4bdfa94a5d3ead8d641f9025b560a27755a83b824234";
  };

  buildInputs = [
    subunit_lib
  ];

  configureFlags = [
    "--enable-subunit"
  ];

  postPatch = optionalString doCheck ''
    for file in tests/*.sh tests/test_output_strings checkmk/test/check_checkmk; do
      patchShebangs "$file"
    done
  '';

  # TODO: Fix tests freezing
  doCheck = false;

  meta = with lib; {
    description = "Unit testing framework for C";
    homepage = https://libcheck.github.io/check/;
    license = licenses.lgpl2Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
