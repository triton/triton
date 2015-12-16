{ stdenv, fetchFromGitHub, autoreconfHook, pkgconfig
, db48, miniupnpc, qt5, boost, openssl, libevent, zeromq
, qrencode, protobuf

, withGui
}:

with stdenv.lib;
stdenv.mkDerivation {
  name = "namecoin-core${optionalString (!withGui) "d"}-2015-12-11";

  src = fetchFromGitHub {
    owner = "namecoin";
    repo = "namecoin-core";
    rev = "f19ec23122dca63b8af15a046214eda362a80b7f";
    sha256 = "11vjxiw0xs24il1i5cvcm95p346kzdlbkclgdqvaaml5zcdj17q0";
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
    (if withGui then "--with-gui" else "--without-gui")
    (if withGui then "--with-qtdbus" else "--without-qtdbus")
    "--with-boost=${boost.dev}"
    "--with-boost-libdir=${boost.lib}/lib"
  ];

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    url = "https://github.com/namecoin/namecoin-core";
    description = "new namecoin client";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
