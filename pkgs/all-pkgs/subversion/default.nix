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
}:

let
  common = { version, sha1Confirm, sha256 }: stdenv.mkDerivation rec {
    inherit version;
    name = "subversion-${version}";

    src = fetchurl {
      url = "mirror://apache/subversion/${name}.tar.bz2";
      inherit sha1Confirm sha256;
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

    meta = with stdenv.lib; {
      description = "A version control system intended to be a compelling replacement for CVS in the open source community";
      homepage = http://subversion.apache.org/;
      maintainers = with maintainers; [
        wkennington
      ];
      plaforms = with platforms;
        i686-linux
        ++ x86_64-linux;
    };

  };

in {

  subversion18 = common {
    version = "1.8.15";
    sha1Confirm = "680acf88f0db978fbbeac89ed63776d805b918ef";
    sha256 = "0b68rjy1sjd66nqcswrm1bhda3vk2ngkgs6drcanmzbcd3vs366g";
  };

  subversion19 = common {
    version = "1.9.3";
    sha1Confirm = "27e8df191c92095f48314a415194ec37c682cbcf";
    sha256 = "1q3ax2v10qybwnzmz2qcgsapvaxinwv5m4r23kp8hg804nqnpgwb";
  };

}
