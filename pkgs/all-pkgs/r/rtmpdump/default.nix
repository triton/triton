{ stdenv
, fetchgit

, openssl
, zlib
}:

let
  inherit (stdenv.lib)
    optional;

  version = "2015-12-23";
in
stdenv.mkDerivation rec {
  name = "rtmpdump-${version}";

  src = fetchgit {
    version = 3;
    url = git://git.ffmpeg.org/rtmpdump;
    # Currently the latest commit is used (a release has not
    # been made since 2011, i.e. '2.4')
    rev = "fa8646daeb19dfd12c181f7d19de708d623704c0";
    sha256 = "f094114bfb2ba8f52a3cce14222a27fc1ed903f01a15d92d0867fac7f68b90ae";
  };

  buildInputs = [
    openssl
    zlib
  ];

  makeFlags = [
    "prefix=$(out)"
    "CRYPTO=OPENSSL"
  ] ++ optional stdenv.cc.isClang "CC=clang";

  parallelInstall = false;

  meta = with stdenv.lib; {
    description = "Toolkit for RTMP streams";
    homepage = http://rtmpdump.mplayerhq.hu/;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
