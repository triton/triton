{ stdenv
, fetchurl
, perl
, python

, apr
, apr-util
, cyrus-sasl
, expat
, serf
, sqlite
, swig
, zlib

, channel ? "1.9"
}:

let
  sources = {
    "1.8" = {
      version = "1.8.16";
      sha1Confirm = "9596643a2728c55a4e54ff38608fde09b27fa494";
      sha256 = "f18f6e8309270982135aae54d96958f9ca6b93f8a4e746dd634b1b5b84edb346";
    };
    "1.9" = {
      version = "1.9.4";
      sha1Confirm = "bc7d51fdda43bea01e1272dfe9d23d0a9d6cd11c";
      sha256 = "1267f9e2ab983f260623bee841e6c9cc458bf4bf776238ed5f100983f79e9299";
    };
  };

  source = sources."${channel}";
in
stdenv.mkDerivation rec {
  name = "subversion-${source.version}";

  src = fetchurl {
    url = "mirror://apache/subversion/${name}.tar.bz2";
    hashOutput = false;
    inherit (source) sha256;
  };

  nativeBuildInputs = [
    perl
    python
  ];

  buildInputs = [
    apr
    apr-util
    cyrus-sasl
    serf
    sqlite
    zlib
  ];

  configureFlags = [
    "--with-berkeley-db"
    "--with-swig=${swig}"
    "--disable-keychain"
    "--with-sasl=${cyrus-sasl}"
    "--with-serf=${serf}"
    "--with-zlib=${zlib}"
    "--with-sqlite=${sqlite}"
  ];

  preBuild = ''
    makeFlagsArray+=(APACHE_LIBEXECDIR=$out/modules)
  '';

  postInstall = ''
    make swig-py swig_pydir=$(toPythonPath $out)/libsvn swig_pydir_extra=$(toPythonPath $out)/svn
    make install-swig-py swig_pydir=$(toPythonPath $out)/libsvn swig_pydir_extra=$(toPythonPath $out)/svn

    make swig-pl-lib
    make install-swig-pl-lib
    pushd subversion/bindings/swig/perl/native
    perl Makefile.PL PREFIX=$out
    make install
    popd

    mkdir -p $out/share/bash-completion/completions
    cp tools/client-side/bash_completion $out/share/bash-completion/completions/subversion
  '';

  # Parallel Building works fine but Parallel Install fails
  parallelInstall = false;

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.asc") src.urls;
      pgpKeyFingerprint = "E7B2 A7F4 EC28 BE9F F8B3  8BA4 B64F FF12 09F9 FA74";
      inherit (src) urls outputHash outputHashAlgo;
      inherit (source) sha1Confirm;
    };
  };

  meta = with stdenv.lib; {
    description = "A version control system intended to be a compelling replacement for CVS in the open source community";
    homepage = http://subversion.apache.org/;
    maintainers = with maintainers; [
      wkennington
    ];
    plaforms = with platforms;
      x86_64-linux;
  };
}
