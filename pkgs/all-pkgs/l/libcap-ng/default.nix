{ stdenv
, fetchurl
, lib
}:

let
  version = "0.7.10";
in
stdenv.mkDerivation rec {
  name = "libcap-ng-${version}";

  src = fetchurl {
    url = "https://people.redhat.com/sgrubb/libcap-ng/${name}.tar.gz";
    multihash = "QmXtza1B7b6AA2qpnvUdmdJxWq2PCyZHeQ7pNaSn3jUAok";
    sha256 = "a84ca7b4e0444283ed269b7a29f5b6187f647c82e2b876636b49b9a744f0ffbf";
  };

  configureFlags = [
    "--without-python"
    "--without-python3"
  ];

  passthru = {
    inherit version;
  };

  meta = with lib; {
    description = "Library for working with POSIX capabilities";
    homepage = https://people.redhat.com/sgrubb/libcap-ng/;
    license = licenses.lgpl21;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
