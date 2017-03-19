{ stdenv
, autogen
, bison
, fetchTritonPatch
, fetchurl
, flex
, python

, dejavu-fonts
, freetype
, fuse
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
    optionals;

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
in
stdenv.mkDerivation rec {
  name = "grub-2.02-rc2-${type}";

  src = fetchurl {
    name = "${name}.tar.xz";
    url = "http://alpha.gnu.org/gnu/grub/grub-2.02~rc2.tar.xz";
    multihash = "QmQsrqeBaAaqQosxajjUB3WK9g1q3jjGb89hGEpdWBc7hS";
    hashOutput = false;
    sha256 = "053bfcbe366733e4f5a1baf4eb15e1efd977225bdd323b78087ce5fa172fc246";
  };

  nativeBuildInputs = [
    autogen
    bison
    flex
    python
  ];

  buildInputs = [
    freetype
    fuse
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
  '';

  configureFlags = [
    "--target=${target}"
    "--with-platform=${platform}"
    "--program-prefix="
    "--program-suffix="
    "--enable-grub-mkfont"
    "--enable-grub-themes"
    "--enable-grub-mount"
    "--enable-liblzma"
    "--enable-libzfs"
  ];

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
