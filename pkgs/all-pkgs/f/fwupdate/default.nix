{ stdenv
, fetchurl
, gettext

, gnu-efi
}:

let
  version = "9";
in
stdenv.mkDerivation rec {
  name = "fwupdate-${version}";

  src = fetchurl {
    url = "https://github.com/rhboot/fwupdate/releases/download/${version}/${name}.tar.bz2";
    sha256 = "e926a7b33a58f5dbf029a5a687375e88b18a41f0742ba871aff7d1d82d075c87";
  };

  nativeBuildInputs = [
    gettext
  ];

  buildInputs = [
    gnu-efi
  ];

  makeFlags = [
    "COMMIT_ID=${version}"
    "EFIDIR=/boot/efi"
    "GNUEFIDIR=${gnu-efi}/lib"
  ];

  preBuild = ''
    export NIX_CFLAGS_COMPILE="$NIX_CFLAGS_COMPILE -I${gnu-efi}/include/efi"
    export NIX_CFLAGS_COMPILE="$NIX_CFLAGS_COMPILE -I$(find "${gnu-efi}"/include -name efibind.h -exec dirname {} \;)"
    makeFlagsArray+=(
      "prefix=$out/"
      "LIBDIR=$out/lib"
    )
  '';

  # We can't enable some of these security hardenings due to being boot code
  optFlags = false;
  pie = false;
  fpic = false;
  noStrictOverflow = false;
  fortifySource = false;
  stackProtector = false;
  optimize = false;

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
