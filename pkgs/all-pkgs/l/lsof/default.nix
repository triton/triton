{ stdenv
, fetchurl
, perl
, which
}:

let
  version = "4.90";
in
stdenv.mkDerivation rec {
  name = "lsof-${version}";

  src = fetchurl {
    url = "ftp://ftp.fu-berlin.de/pub/unix/tools/lsof/lsof_${version}.tar.bz2";
    multihash = "QmPMvGsXga5yFhCishH67xQxF3z6JgJK3FBhY2Tjykw6ed";
    hashOutput = false;
    sha256 = "6f14840c791926715cd80ba3b049220256470f9f16a457a2e4b516baab1a16f6";
  };

  nativeBuildInputs = [
    perl
    which
  ];

  postUnpack = ''
    unpackFile "$srcRoot"/*_src.tar
    srcRoot=$(echo *_src)
  '';

  configureScript = "./Configure";

  addPrefix = false;

  configureFlags = [
    "-n"
    "linux"
  ];

  LSOF_INCLUDE = "${stdenv.libc}/include";

  preBuild = ''
    sed -i '/define.*HASSECURITY/a#define  HASSECURITY 1' dialects/linux/machine.h
  '';

  postInstall = ''
    install -D -m755 -v 'lsof' "$out/bin/lsof"
    install -D -m644 -v 'lsof.8' "$out/man/man8/lsof.8"
  '';

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.sig") src.urls;
      pgpKeyFingerprint = "9AFD62A840BD3D55";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    description = "A tool to list open files";
    homepage = https://people.freebsd.org/~abe/;
    license = licenses.free; # lsof license
    maintainers = with maintainers; [
      codyopel
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
