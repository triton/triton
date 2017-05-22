{ stdenv
, fetchurl

, pciutils
}:

stdenv.mkDerivation rec {
  name = "gnu-efi-${version}";
  version = "3.0.4";

  src = fetchurl {
    url = "mirror://sourceforge/gnu-efi/${name}.tar.bz2";
    sha256 = "51a00428c3ccb96db24089ed8394843c4f83cf8f42c6a4dfddb4b7c23f2bf8af";
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
