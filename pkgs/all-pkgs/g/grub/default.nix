{ stdenv
, autogen
, bison
, fetchTritonPatch
, fetchurl
, flex
, makeWrapper

, dejavu-fonts
, efibootmgr
, freetype
, fuse_2
, gettext
, libusb_1
, lvm2
, ncurses
, xz
, zfs

, type
}:

let
  inherit (stdenv.lib)
    any
    mapAttrsToList
    optionals
    optionalString;

  typeMap = {
    "bios-i386" = {
      platform = "pc";
      target = "i386";
    };
    "efi-x86_64" = {
      platform = "efi";
      target = "x86_64";
    };
    "efi-i386" = {
      platform = "efi";
      target = "i386";
    };
  };

  inherit (typeMap."${type}")
    platform
    target;

  version = "2.02";
in
stdenv.mkDerivation rec {
  name = "grub-${version}-${type}";

  src = fetchurl {
    url = "mirror://gnu/grub/grub-${version}.tar.xz";
    hashOutput = false;
    sha256 = "810b3798d316394f94096ec2797909dbf23c858e48f7b3830826b8daa06b7b0f";
  };

  nativeBuildInputs = [
    autogen
    bison
    flex
    makeWrapper
  ];

  buildInputs = [
    freetype
    fuse_2
    gettext
    libusb_1
    lvm2
    ncurses
    xz
    zfs
  ];

  patches = [
    (fetchTritonPatch {
      rev = "db2b09c5a771c8b7e822c8b09ef8ac7bfda31988";
      file = "g/grub/fix-bash-completion.patch";
      sha256 = "c9c6813abed894240070f9c107d1996e945395d8810479cccb559863a95d44ad";
    })
  ];

  postPatch = ''
    sed -i 's,/usr/share/fonts/truetype,${dejavu-fonts}/share/fonts/truetype,g' configure
    sed -i 's, -Werror,,' grub-core/Makefile.in
  '';

  configureFlags = [
    "--target=${target}"
    "--with-platform=${platform}"
    "--program-prefix="
    "--program-suffix="
    "--disable-werror"
    "--enable-grub-mkfont"
    "--enable-grub-themes"
    "--enable-grub-mount"
    "--enable-liblzma"
    "--enable-libzfs"
  ];

  postFixup = optionalString ("efi" == platform) ''
    progs="$(grep -r 'efibootmgr' -l "$out/bin")"
    for prog in $progs; do
      wrapProgram "$prog" \
        --prefix PATH : "${efibootmgr}/bin"
    done
  '';

  # We don't need any security / optimization features for a bootloader
  optFlags = false;
  pie = false;
  fpic = false;
  noStrictOverflow = false;
  fortifySource = false;
  stackProtector = false;
  optimize = false;

  passthru = rec {
    inherit
      platform
      target;

    srcVerification = fetchurl {
      failEarly = true;
      inherit (src) name urls outputHash outputHashAlgo;
      pgpsigUrl = map (n: "${n}.sig") src.urls;
      pgpKeyFingerprint = "E53D 497F 3FA4 2AD8 C9B4  D1E8 35A9 3B74 E82E 4209";
    };
  };

  meta = with stdenv.lib; {
    description = "GNU GRUB, the Grand Unified Boot Loader (2.x beta)";
    homepage = http://www.gnu.org/software/grub/;
    license = licenses.gpl3Plus;
    platforms = with platforms;
      x86_64-linux;
  };
}
