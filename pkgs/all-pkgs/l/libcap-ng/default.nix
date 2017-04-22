{ stdenv
, fetchurl
, swig

, python2
, python3
}:

let
  version = "0.7.8";
in
stdenv.mkDerivation rec {
  name = "libcap-ng-${version}";

  src = fetchurl {
    url = "https://people.redhat.com/sgrubb/libcap-ng/${name}.tar.gz";
    multihash = "QmWyF9KDXAS3pnEsCo8yLwTvUeH8wFDLfMTgmu19iCFhis";
    sha256 = "c21af997445cd4107a55d386f955c5ea6f6e96ead693e9151277c0ab5f97d05f";
  };

  nativeBuildInputs = [
    swig
  ];

  buildInputs = [
    python2
    python3
  ];

  postPatch = ''
    function get_header() {
      echo -e "#include <$1>" | gcc -M -xc - | tr ' ' '\n' | grep "$1" | head -n 1
    }

    # Fix some hardcoding of header paths
    sed -i "s,/usr/include/linux/capability.h,$(get_header linux/capability.h),g" bindings/python{,3}/Makefile.in
  '';

  configureFlags = [
    "--with-python"
    "--with-python3"
  ];

  meta = with stdenv.lib; {
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
