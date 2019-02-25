{ stdenv
, fetchurl
, lib
, pkgs

, python
, isPy3
}:

let
  inherit (lib)
    optionalString;

  inherit (pkgs.libcap-ng)
    src
    version;
in
stdenv.mkDerivation rec {
  name = "${python.libPrefix}-libcap-ng-${version}";

  inherit src;

  nativeBuildInputs = [
    pkgs.swig
  ];

  buildInputs = [
    pkgs.libcap-ng
    python
  ];

  postPatch = ''
    function get_header() {
      echo -e "#include <$1>" | gcc -M -xc - | tr ' ' '\n' | grep "$1" | head -n 1
    }

    # Fix some hardcoding of header paths
    grep -q '/usr/include' bindings/python{,3}/Makefile.in
    sed -i "s,/usr/include/linux/capability.h,$(get_header linux/capability.h),g" bindings/python{,3}/Makefile.in
  '';

  NIX_LDFLAGS = "-rpath ${pkgs.libcap-ng}/lib";

  configureFlags = [
    "--with-python${optionalString isPy3 "3"}"
  ];

  installFlags = [
    "-C" "bindings"
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
