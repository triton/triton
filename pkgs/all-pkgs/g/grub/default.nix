{ stdenv
, bison
, fetchTritonPatch
, fetchurl
, flex
, makeWrapper
, python2

, dejavu-fonts
, efibootmgr
, freetype
, fuse_2
, gettext
, lvm2
, xz
, zfs

, type
}:

let
  inherit (stdenv.lib)
    any
    mapAttrsToList
    optionals
    optionalString
    replaceStrings;

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

  version = "2.04~rc1";
  version' = replaceStrings ["~"] ["-"] version;
in
stdenv.mkDerivation rec {
  name = "grub-${version'}-${type}";

  src = fetchurl {
    name = "grub-${version'}.tar.xz";
    url = "https://alpha.gnu.org/gnu/grub/grub-${version}.tar.xz";
    multihash = "QmeTicFn54TQYjWKBNM2e8X7DvbJxsFef6xQCxwyhmuiHS";
    hashOutput = false;
    sha256 = "62ab4435aff769233d09618d5ec36651ef4e4f6ae3939bbcb2f9b98c2a42adc8";
  };

  nativeBuildInputs = [
    bison
    flex
    makeWrapper
    python2
  ];

  buildInputs = [
    freetype
    fuse_2
    lvm2
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
    grep -q '/usr/share/fonts/truetype' configure
    sed -i 's,/usr/share/fonts/truetype,${dejavu-fonts}/share/fonts/truetype,g' configure
  '';

  configureFlags = [
    "--program-prefix="
    "--program-suffix="
    "--target=${target}"
  ] ++ optionals (platform != "efi") [
    "--enable-efiemu"
  ] ++ [
    "--enable-cache-stats"
    "--enable-boot-time"
    "--enable-grub-mkfont"
    "--enable-grub-themes"
    "--enable-grub-mount"
    "--enable-device-mapper"
    "--enable-liblzma"
    "--enable-libzfs"
    "--disable-werror"
    "--with-platform=${platform}"
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
      fullOpts = {
        pgpsigUrl = map (n: "${n}.sig") src.urls;
        pgpKeyFingerprint = "E53D 497F 3FA4 2AD8 C9B4  D1E8 35A9 3B74 E82E 4209";
      };
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
