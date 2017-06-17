{ stdenv
, fetchurl

, pciutils
}:

let
  version = "3.0.5";
in
stdenv.mkDerivation rec {
  name = "gnu-efi-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/gnu-efi/${name}.tar.bz2";
    sha256 = "bd8fcd5914f18fc0e4ba948ab03b00013e528504f529c60739b748f6ef130b22";
  };

  buildInputs = [
    pciutils
  ];

  prePatch = ''
    sed -i 's, -Werror,,g' Make.defaults
  '';

  preBuild = ''
    makeFlagsArray+=("PREFIX=$out")
  '';

  makeFlags = [
    "CC=gcc"
    "AS=as"
    "LD=ld"
    "AR=ar"
    "RANLIB=ranlib"
    "OBJCOPY=objcopy"
  ];

  # We can't enable some of these security hardenings due to being boot code
  optFlags = false;
  pie = false;
  fpic = false;
  noStrictOverflow = false;
  fortifySource = false;
  stackProtector = false;
  optimize = false;

  meta = with stdenv.lib; {
    description = "GNU EFI development toolchain";
    homepage = http://sourceforge.net/projects/gnu-efi/;
    license = licenses.bsd3;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
