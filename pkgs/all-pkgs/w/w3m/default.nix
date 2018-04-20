{ stdenv
, fetchTritonPatch
, fetchpatch
, fetchzip
, gettext
, lib

, boehm-gc
, gpm
, imlib2
, libx11
, man
, ncurses
, openssl
, perl
, xorgproto
, zlib
}:

let
  inherit (lib)
    optionals
    optionalString;

  date = "2018-03-23";
  rev = "4ef1a5f3dfb310562bd9d3c7cc3f9a1b74b7c44d";
in
stdenv.mkDerivation rec {
  name = "w3m-0.5.3-${date}";

  src = fetchzip {
    version = 6;
    inherit name;
    url = "https://anonscm.debian.org/cgit/collab-maint/w3m.git/snapshot/"
        + "${rev}.tar.xz";
    multihash = "QmRi689Z81q9YLpTxDjL7fSbhMNqbfAc6gmEeCmfjw9zE6";
    sha256 = "37acc2b198ba7e74811597796c35821d51d4d14c5cde71e4180dd337cbced635";
  };

  nativeBuildInputs = [
    gettext
  ];

  buildInputs = [
    boehm-gc
    gpm
    libx11
    ncurses
    openssl
    imlib2
    xorgproto
    zlib
  ];

  # we must set these so that the generated files (e.g. w3mhelp.cgi) contain
  # the correct paths.
  PERL = "${perl}/bin/perl";
  MAN = "${man}/bin/man";

  # for w3mimgdisplay
  # see: https://bbs.archlinux.org/viewtopic.php?id=196093
  LIBS = "-lX11";

  patches = [
    (fetchTritonPatch {
      rev = "78526c83438b5935a0d7516e3cbe0e3482495ffe";
      file = "w3m/RAND_egd.libressl.patch";
      sha256 = "bf1e2c20770a40e3ab91bf45d08b9a3b6037a70e9e49e6c8cac54fbcb888607a";
    })
    (fetchpatch {
      name = "https.patch";
      url = "https://aur.archlinux.org/cgit/aur.git/plain/https.patch?h=w3m-mouse&id=5b5f0fbb59f674575e87dd368fed834641c35f03";
      sha256 = "08skvaha1hjyapsh8zw5dgfy433mw2hk7qy9yy9avn8rjqj7kjxk";
    })
  ];

  preConfigure = ''
    substituteInPlace ./configure --replace "/lib /usr/lib /usr/local/lib /usr/ucblib /usr/ccslib /usr/ccs/lib /lib64 /usr/lib64" /no-such-path
    substituteInPlace ./configure --replace /usr /no-such-path
  '';

  configureFlags = [
    "--with-ssl=${openssl}"
    "--with-gc=${boehm-gc}"
    "--enable-image=x11,fb"
  ];

  postInstall = ''
    ln -s $out/libexec/w3m/w3mimgdisplay $out/bin
  '';

  passthru = {
    srcVerification = fetchzip {
    version = 1;
      inherit name;
      inherit (src) urls outputHash outputHashAlgo;
      insecureHashOutput = true;
    };
  };

  meta = with lib; {
    homepage = http://w3m.sourceforge.net/;
    description = "A text-mode web browser";
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
