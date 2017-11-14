{ stdenv
, fetchurl

, libevent
, openssl
}:

let
  version = "201602131606";
in
stdenv.mkDerivation rec {
  name = "libasr-${version}";

  src = fetchurl {
    url = "https://www.opensmtpd.org/archives/${name}.tar.gz";
    multihash = "Qmb9GvQg8onLsjansapWkgtwGLewK4A1g24646856UdwHc";
    sha256 = "e5684a08d5eb61d68a94a24688f23bee8785c8a51a1bd34c88cae5aee5aa6da2";
  };

  buildInputs = [
    libevent
    openssl
  ];

  meta = with stdenv.lib; {
    homepage = https://github.com/OpenSMTPD/libasr;
    description = "Free, simple and portable asynchronous resolver library";
    license = licenses.isc;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
