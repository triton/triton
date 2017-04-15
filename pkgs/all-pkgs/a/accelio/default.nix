{ stdenv
, autoreconfHook
, fetchFromGitHub

, libevent
, numactl
, rdma-core

, kernel ? null
}:

let
  version = "1.7";
in
stdenv.mkDerivation rec {
  name = "accelio-${version}${stdenv.lib.optionalString (kernel != null) "-kernel"}";

  src = fetchFromGitHub {
    version = 2;
    owner = "accelio";
    repo = "accelio";
    rev = "v${version}";
    sha256 = "126243e08af4356335f554be2b7885e5ea2b31824b8414c08b6f2c83a46655a5";
  };

  nativeBuildInputs = [
    autoreconfHook
  ];

  buildInputs = [
    libevent
    numactl
    rdma-core
  ];

  postPatch = ''
    grep -q '\-g -ggdb -Wall -Werror' configure.ac
    sed -i 's,-g -ggdb -Wall -Werror,-O2,g' configure.ac

    # Don't build broken examples
    sed -i 's/AC_CONFIG_\(SUBDIRS\|FILES\)(\[\(examples\|tests\).*/AC_MSG_RESULT([Not building...])/' configure.ac
    sed -i 's,subdirs.*\(examples\|tests\).*,AC_MSG_RESULT([Not building...]),g' configure.ac

    # Allow the installation of xio kernel headers
    sed -i 's,/opt/xio,''${out},g' src/kernel/xio/Makefile.in

    # Don't install ldconfig entries
    sed -i '\,/etc/ld.so.conf.d/libxio.conf,d' src/usr/Makefile.am
    sed -i '\,/sbin/ldconfig,d' src/usr/Makefile.am
  '';

  configureFlags = [
    "--enable-rdma"
    "--disable-raio-build"
  ] ++ stdenv.lib.optionals (kernel != null) [
    "--enable-kernel-module"
    "--with-kernel=${kernel.dev}/lib/modules/${kernel.modDirVersion}/source"
    "--with-kernel-build=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
  ];

  INSTALL_MOD_PATH = "\${out}";

  meta = with stdenv.lib; {
    homepage = http://www.accelio.org/;
    description = "High-performance messaging and RPC library";
    license = licenses.bsd3;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
