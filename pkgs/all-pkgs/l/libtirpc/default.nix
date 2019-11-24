{ stdenv
, fetchurl
, lib

, krb5_lib
}:

let
  version = "1.1.4";
in
stdenv.mkDerivation rec {
  name = "libtirpc-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/libtirpc/libtirpc/${version}/${name}.tar.bz2";
    sha256 = "2ca529f02292e10c158562295a1ffd95d2ce8af97820e3534fe1b0e3aec7561d";
  };

  propagatedBuildInputs = [
    krb5_lib
  ];

  NIX_CFLAGS_COMPILE = [
    "-std=c99"  # Breaks libraries linking against this one using >c99.
  ];

  postInstall = ''
    mkdir -p "$lib"/lib
    mv "$dev"/lib*/*.so* "$lib"/lib
    ln -sv "$lib"/lib/* "$dev"/lib
  '';

  postFixup = ''
    rm -rv "$dev"/share
  '';

  outputs = [
    "dev"
    "lib"
    "man"
  ];

  meta = with lib; {
    homepage = "http://sourceforge.net/projects/libtirpc/";
    description = "The transport-independent Sun RPC implementation (TI-RPC)";
    license = licenses.bsd3;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
