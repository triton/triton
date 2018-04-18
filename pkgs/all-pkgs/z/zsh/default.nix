{ stdenv
, fetchurl
, lib
, perl

, coreutils
, gdbm
, less
, libcap
, ncurses
, pcre
}:

let
  inherit (lib)
    boolEn
    boolString
    boolWt
    optionals;

  version = "5.5";

  documentation = fetchurl {
    url = "mirror://sourceforge/zsh/zsh-doc/${version}/"
      + "zsh-${version}-doc.tar.xz";
    hashOutput = false;
    sha256 = "b995c16a2ded516b6e07883932640fcca8b53b1b8a1934094a8a32ef087f52fc";
  };
in
stdenv.mkDerivation rec {
  name = "zsh-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/zsh/zsh/${version}/zsh-${version}.tar.xz";
    hashOutput = false;
    sha256 = "a8359b81d090425d497c6f3c724a7c21a81c614b03e7662ed347705d86958e53";
  };

  nativeBuildInputs = [
    perl
  ];

  buildInputs = [
    coreutils
    gdbm
    ncurses
    pcre
  ];

  postPatch = ''
    patchShebangs ./Misc/
    patchShebangs ./Util/
  '' + /* Test requres additional executables */ ''
    rm -fv ./Test/A01grammar.ztst
  '' + /* Test requires filesystem to have atime enabled */ ''
    rm -fv ./Test/C02cond.ztst
  '';

  preConfigure = ''
    configureFlagsArray+=(
      #"--enable-zshenv="
      "--enable-zprofile=$out/etc/zprofile"
      #"--enable-zlogin="
      #"--enable-zlogout="
    )
  '';

  configureFlags = [
    "--disable-zsh-debug"
    # Internal malloc is broken
    "--disable-zsh-mem"
    "--disable-zsh-mem-debug"
    "--disable-zsh-mem-warning"
    "--disable-zsh-secure-free"
    "--disable-zsh-heap-debug"
    "--disable-zsh-valgrind"
    "--disable-zsh-hash-debug"
    # Tests fail with stack allocation enabled >=5.2
    "--disable-stack-allocation"
    "--enable-dynamic"
    "--enable-locale"
    "--disable-ansi2knr"
    "--enable-function-subdirs"
    "--enable-maildir-support"
    "--enable-readnullcmd=${less}/bin/less"
    "--${boolEn (pcre != null)}-pcre"
    "--${boolEn (libcap != null)}-cap"
    "--${boolEn (gdbm != null)}-gdbm"
    "--enable-largefile"
    "--enable-multibyte"
    "--enable-unicode9"
    # TODO: musl libc support
    "--disable-libc-musl"
    "--enable-dynamic-nss"
    "--${boolWt (ncurses != null)}-term-lib${boolString (ncurses != null) "=ncursesw" ""}"
    "--with-tcsetpgrp"
  ];

  postInstall = /* Install documentation */ ''
    mkdir -pv $out/share
    tar xf ${documentation} -C $out/share
  '' + /* Install configs */ ''
    install -D -m644 -v '${./zprofile}' "$out/etc/zprofile"
  '';

  doCheck = true;

  passthru = {
    srcVerification = fetchurl rec {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      failEarly = true;
      pgpsigUrls = map (n: "${n}.asc") src.urls;
      pgpKeyFingerprint = "F7B2 754C 7DE2 8309 1466  1F0E A71D 9A9D 4BDB 27B3";
    };
    srcVerification-documentation = fetchurl rec {
      inherit (documentation)
        outputHash
        outputHashAlgo
        urls;
      failEarly = true;
      pgpsigUrls = map (n: "${n}.asc") documentation.urls;
      pgpKeyFingerprint = "F7B2 754C 7DE2 8309 1466  1F0E A71D 9A9D 4BDB 27B3";
    };
  };

  meta = with lib; {
    description = "The Z command shell";
    homepage = http://www.zsh.org/;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
