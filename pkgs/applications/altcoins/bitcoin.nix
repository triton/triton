{ stdenv, fetchFromGitHub, autoreconfHook, pkgconfig
, db48, miniupnpc, qt5, boost, openssl, libevent, zeromq
, qrencode, protobuf

, withGui
}:

with stdenv.lib;
stdenv.mkDerivation rec {
  name = "bitcoin${optionalString (!withGui) "d"}-${version}";
  version = "0.11.2";

  src = fetchFromGitHub {
    owner = "bitcoin";
    repo = "bitcoin";
    rev = "v${version}";
    sha256 = "05cdqq2z8l7dsp60ddgbny5mcj9sgwdvdn1ipcv8j3d2gimddg6q";
  };

  nativeBuildInputs = [ autoreconfHook pkgconfig ];
  buildInputs = [ db48 miniupnpc boost openssl libevent zeromq ]
    ++ optionals withGui [ qt5.qtbase qrencode qt5.qttools protobuf ];

  postPatch = ''
    sed -i 's,use_lcov=yes,use_lcov=$enableval,g' configure.ac
    sed -i '/\(LRELEASE\|LUPDATE\)/ s,$qt_bin_path,${qt5.qttools}/bin,g' build-aux/m4/bitcoin_qt.m4
  '';

  configureFlags = [
    "--enable-wallet"
    "--with-miniupnpc"
    "--with-upnp-default"
    "--disable-tests"
    "--disable-bench"
    "--without-comparison-tool"
    "--without-comparison-tool-reorg-tests"
    "--without-extended-rpc-tests"
    (if withGui then "--with-qrencode" else "--without-qrencode")
    "--enable-hardening"
    "--disable-reduce-exports"
    "--disable-ccache"
    "--disable-lcov"
    "--disable-glibc-back-compat"
    "--enable-zmq"
    "--disable-debug"
    "--enable-utils"
    "--enable-libs"
    "--enable-daemon"
    (if withGui then "--with-gui" else "--without-gui")
    (if withGui then "--with-qtdbus" else "--without-qtdbus")
    "--with-boost=${boost.dev}"
    "--with-boost-libdir=${boost.lib}/lib"
  ];

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    url = "https://github.com/bitcoin/bitcoin";
    description = "bitcoin client";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
