{ stdenv
, fetchurl

, krb5_lib
}:

let
  version = "1.0.2";
in
stdenv.mkDerivation rec {
  name = "libtirpc-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/libtirpc/libtirpc/${version}/${name}.tar.bz2";
    sha256 = "723c5ce92706cbb601a8db09110df1b4b69391643158f20ff587e20e7c5f90f5";
  };

  propagatedBuildInputs = [
    krb5_lib
  ];

  meta = with stdenv.lib; {
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
