{ stdenv
, fetchurl
, perl

, coreutils
, gdbm
, libcap
, libiconv
, ncurses
, pcre
}:

with {
  inherit (stdenv.lib)
    enFlag
    optionals
    wtFlag;
};

let
  version = "5.2";
  documentation = fetchurl {
    url = "mirror://sourceforge/zsh/zsh-${version}-doc.tar.gz";
    sha256 = "1r9r91gmrrflzl0yq10bib9gxbqyhycb09hcx28m2g3vv9skmccj";
  };
in

stdenv.mkDerivation {
  name = "zsh-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/zsh/zsh-${version}.tar.gz";
    sha256 = "0dsr450v8nydvpk8ry276fvbznlrjgddgp7zvhcw4cv69i9lr4ps";
  };

  nativeBuildInputs = [
    perl
  ];

  buildInputs = [
    coreutils
    gdbm
    ncurses
    pcre
  ] ++ optionals (!stdenv.cc.isGNU) [
    libiconv
  ];

  postPatch = ''
    patchShebangs ./Misc/
    patchShebangs ./Util/
  '' +
  /* Test requires filesystem with noatime */ ''
    rm -f ./Test/C02cond.ztst
  '';

  configureFlags = [
    "--disable-zsh-debug"
    # Internal malloc is broken
    "--disable-zsh-mem"
    "--disable-zsh-mem-debug"
    "--disable-zsh-mem-warning"
    "--disable-zsh-secure-free"
    "--disable-zsh-valgrind"
    "--disable-zsh-hash-debug"
    # Test fail with stack allocation enabled >=5.2
    "--disable-stack-allocation"
    #"--enable-zshenv="
    "--enable-zprofile=$(out)/etc/zprofile"
    #"--enable-zlogin="
    #"--enable-zlogout="
    "--enable-dynamic"
    "--enable-locale"
    "--disable-ansi2knr"
    "--enable-function-subdirs"
    "--enable-maildir-support"
    "--enable-readnullcmd=pager"
    (enFlag "pcre" (pcre != null) null)
    (enFlag "cap" (libcap != null) null)
    (enFlag "gdbm" (gdbm != null) null)
    "--enable-largefile"
    "--enable-multibyte"
    # TODO: musl libc support
    "--disable-libc-musl"
    "--enable-dynamic-nss"
    (wtFlag "term-lib" (ncurses != null) "ncursesw")
    "--with-tcsetpgrp"
  ];

  postInstall = ''
    mkdir -p $out/share
    tar xf ${documentation} -C $out/share
  '' +
  /* TODO: convert this to install a static file */ ''
    mkdir -p $out/etc
    cat > $out/etc/zprofile <<EOF
    if test -e /etc/NIXOS; then
      if test -r /etc/zprofile; then
        . /etc/zprofile
      else
        emulate bash
        alias shopt=false
        . /etc/profile
        unalias shopt
        emulate zsh
      fi
      if test -r /etc/zprofile.local; then
        . /etc/zprofile.local
      fi
    else
      # on non-nixos we just source the global /etc/zprofile as if we did
      # not use the configure flag
      if test -r /etc/zprofile; then
        . /etc/zprofile
      fi
    fi
    EOF

    $out/bin/zsh -c "zcompile $out/etc/zprofile"
    mv $out/etc/zprofile $out/etc/zprofile_zwc_is_used
  '';

  doCheck = true;

  meta = with stdenv.lib; {
    description = "The Z command shell";
    homepage = "http://www.zsh.org/";
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
