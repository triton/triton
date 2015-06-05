{ fetchurl, stdenv, libuuid, popt, icu, ncurses }:

let
  inherit (stdenv) isDarwin isFreeBSD isLinux system;
  inherit (stdenv.lib) optionalString;
in

# Make sure platform is supported
assert (!isDarwin && !isFreeBSD && !isLinux) -> throw "gptfdisk does not support the `${system}' platform";

# TODO: add Cygwin support

stdenv.mkDerivation rec {
  name = "gptfdisk-1.0.0";

  src = fetchurl {
    url = "mirror://sourceforge/gptfdisk/${name}.tar.gz";
    sha256 = "0v0xl0mzwabdf9yisgsvkhpyi48kbik35c6df42gr6d78dkrarjv";
  };

  # Use the correct makefile on FreeBSD & Darwin
  patchPhase = optionalString (isDarwin || isFreeBSD) ''
    rm -f Makefile
  '' + optionalString isDarwin ''
    mv Makefile.mac Makefile
  '' + optionalString isFreeBSD ''
    mv Makefile.freebsd Makefile
  '';

  buildInputs = [ icu libuuid ncurses popt ];

  installPhase = ''
    mkdir -p $out/bin
    install -v -m755 cgdisk $out/bin
    install -v -m755 fixparts $out/bin
    install -v -m755 gdisk $out/bin
    install -v -m755 sgdisk $out/bin

    mkdir -p $out/share/man/man8
    install -v -m644 cgdisk.8 $out/share/man/man8
    install -v -m644 fixparts.8 $out/share/man/man8
    install -v -m644 gdisk.8 $out/share/man/man8
    install -v -m644 sgdisk.8 $out/share/man/man8
  '';

  meta = with stdenv.lib; {
    description = "A set of text-mode partitioning tools for Globally Unique Identifier (GUID) Partition Table (GPT) disks";
    homepage = http://www.rodsbooks.com/gdisk/;
    license = licenses.gpl2;
    maintainers = [ maintainers.shlevy ];
    platforms = platforms.unix;
  };
}
