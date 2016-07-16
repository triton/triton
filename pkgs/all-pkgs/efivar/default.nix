{ stdenv
, fetchurl

, popt
}:

let
  version = "0.24";
in
stdenv.mkDerivation rec {
  name = "efivar-${version}";

  src = fetchurl {
    url = "https://github.com/rhinstaller/efivar/releases/download/${version}/${name}.tar.bz2";
    sha256 = "be7e067cb6a6842d669eb36e66a15523b9463afa73d558abda6bf4e02cc69e4c";
  };

  buildInputs = [
    popt
  ];

  # FIXME: ld.so not properly linked in with ld --no-allow-shlib-undefined
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
