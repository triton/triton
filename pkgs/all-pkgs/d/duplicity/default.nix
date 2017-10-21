{ stdenv
, buildPythonPackage
, fetchurl
, lib

, gnupg
, fasteners
, lftp
, librsync
, pyrax
}:

let
  versionMajor = "0.7";
  version = "${versionMajor}.14";
in
buildPythonPackage rec {
  name = "duplicity-${version}";

  src = fetchurl {
    url = "https://code.launchpad.net/duplicity/${versionMajor}-series/"
      + "${version}/+download/${name}.tar.gz";
    multihash = "QmRVshopPEkadktNLZq66x1HsbsEmYdZjcAvQG4Grqv6L7";
    sha256 = "7a3eb74a2a36b004b10add2970b37cfbac0bd693d79513e6311c8e4b8c3dd73e";
  };

  buildInputs = [
    librsync
  ];

  propagatedBuildInputs = [
    fasteners
    gnupg
    lftp
    pyrax
  ];

  meta = with lib; {
    description = "Encrypted bandwidth-efficient backup using the rsync algorithm";
    homepage = "http://www.nongnu.org/duplicity";
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
