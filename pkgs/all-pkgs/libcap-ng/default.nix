{ stdenv
, fetchurl
, swig

, python2
, python3
}:

stdenv.mkDerivation rec {
  name = "libcap-ng-${version}";
  version = "0.7.7";

  src = fetchurl {
    url = "${meta.homepage}/${name}.tar.gz";
    sha256 = "0syhyrixk7fqvwis3k7iddn75g0qxysc1q5fifvzccxk7774jmb1";
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
    homepage = http://people.redhat.com/sgrubb/libcap-ng/;
    license = licenses.lgpl21;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
