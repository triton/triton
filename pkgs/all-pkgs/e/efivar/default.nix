{ stdenv
, fetchzip

, popt
}:

let
  version = "28";
in
stdenv.mkDerivation rec {
  name = "efivar-${version}";

  src = fetchzip {
    version = 2;
    url = "https://github.com/rhinstaller/efivar/archive/${version}.tar.gz";
    sha256 = "33d393abd7d08b41e47981f37848a78f726aff83f89a2f470db98f95e1ff2aa3";
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
