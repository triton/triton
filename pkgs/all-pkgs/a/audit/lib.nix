{ stdenv
, fetchurl
, lib

, libcap-ng
}:

let
  version = "2.8.4";
in
stdenv.mkDerivation rec {
  name = "libaudit-${version}";

  src = fetchurl {
    url = "https://people.redhat.com/sgrubb/audit/audit-${version}.tar.gz";
    multihash = "QmWJ9XwNXABcmEZc1jynvgG5eqaw1NLiw5MAAPvcYjTdxz";
    sha256 = "a410694d09fc5708d980a61a5abcb9633a591364f1ecc7e97ad5daef9c898c38";
  };

  buildInputs = [
    libcap-ng
  ];

  configureFlags = [
    "--without-python"
    "--without-python3"
    "--without-golang"
  ];

  # Only build and install the lib
  preBuild = ''
    cd lib
  '';

  passthru = {
    inherit version;
  };

  meta = with lib; {
    description = "Audit Library";
    homepage = "http://people.redhat.com/sgrubb/audit/";
    license = licenses.gpl2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
