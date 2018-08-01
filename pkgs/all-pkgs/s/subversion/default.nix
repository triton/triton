{ stdenv
, fetchurl
, perl
, python

, apr
, apr-util
, cyrus-sasl
, expat
, file
, serf
, sqlite
, swig
, zlib

, channel
}:

let
  sources = {
    "1.9" = {
      version = "1.9.9";
      sha1Confirm = "b8d410d5146e914bc2a72cd8957f6d3b68c4ac52";
      sha256 = "8dfdbe573b582d8eb2c328cca2aacff3795b54bb39eb7fd831e3ce05991f81d2";
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
    expat
    file
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

  # Fix broken package config files
  preFixup = ''
    pcs=($(find "$out"/share/pkgconfig -type f))
    for pc in "''${pcs[@]}"; do
      sed -i 's,[ ]\(-l\|lib\)svn[^ ]*,\0-1,g' "$pc"
      mv "$pc" "''${pc%.pc}-1.pc"
    done
  '';

  # Parallel Building works fine but Parallel Install fails
  installParallel = false;

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.asc") src.urls;
      pgpKeyFingerprints = [
        "E7B2 A7F4 EC28 BE9F F8B3  8BA4 B64F FF12 09F9 FA74"
        "056F 8016 D9B8 7B1B DE41  7467 99EC 741B 5792 1ACC"
        "BA3C 15B1 337C F0FB 222B  D41A 1BCA 6586 A347 943F"
        "8BC4 DAE0 C5A4 D65F 4044  0107 4F7D BAA9 9A59 B973"
        "A844 790F B574 3606 EE95  9207 76D7 88E1 ED1A 599C"
        "3D1D C66D 6D2E 0B90 3952  8138 C4A6 C625 CCC8 E1DF"
        "7B8C A7F6 451A D89C 8ADC  077B 376A 3CFD 110B 1C95"
        "6011 63CF 9D49 9FD7 18CF  582D 1FB0 64B8 4EEC C493"
        "E966 46BE 08C0 AF0A A0F9  0788 A5FE EE3A C793 7444"
      ];
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
