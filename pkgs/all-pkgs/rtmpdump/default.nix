{ stdenv
, fetchgit

, openssl
, zlib
}:

with {
  inherit (stdenv.lib)
    optional;
};

stdenv.mkDerivation rec {
  name = "rtmpdump-${version}";
  version = "2015-12-23";

  src = fetchgit {
    url = git://git.ffmpeg.org/rtmpdump;
    # Currently the latest commit is used (a release has not
    # been made since 2011, i.e. '2.4')
    rev = "fa8646daeb19dfd12c181f7d19de708d623704c0";
    sha256 = "06c137sm6g6av4kazv7qrhz5k8bbyz31x8id7gdwgpppa640m6kc";
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
      i686-linux
      ++ x86_64-linux;
  };
}
