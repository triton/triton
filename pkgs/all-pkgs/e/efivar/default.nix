{ stdenv
, fetchurl

, popt
}:

let
  version = "37";
in
stdenv.mkDerivation rec {
  name = "efivar-${version}";

  src = fetchurl {
    url = "https://github.com/rhinstaller/efivar/releases/download/${version}/"
      + "${name}.tar.bz2";
    sha256 = "3c67feb93f901b98fbb897d5ca82931a6698b5bcd6ac34f0815f670d77747b9f";
  };

  buildInputs = [
    popt
  ];

  # FIXME: ld.so is not properly linked in with ld --no-allow-shlib-undefined
  #   https://sourceware.org/bugzilla/show_bug.cgi?id=19249
  postPatch = ''
    sed -i 's/--no-allow-shlib-undefined//' gcc.specs
  '';

  makeFlags = [
    # Avoid building static binary/libs
    "BINTARGETS=efivar"
    "STATICLIBTARGETS="
  ];

  preInstall = ''
    installFlagsArray+=(
      "bindir=$out/bin"
      "includedir=$out/include"
      "libdir=$out/lib"
      "mandir=$out/share/man"
    )
  '';

  meta = with stdenv.lib; {
    description = "Tools and library to manipulate EFI variables";
    homepage = https://github.com/rhinstaller/efivar;
    license = licenses.lgpl21;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
