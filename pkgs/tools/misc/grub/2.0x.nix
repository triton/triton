{ stdenv
, autogen
, bison
, fetchurl
, flex
, python, autoconf, automake
, gettext, ncurses, libusb_1, freetype, lvm2, zfs
, efiSupport ? false
}:

let
  inherit (stdenv.lib)
    any
    mapAttrsToList
    optionals;

  pcSystems = {
    "i686-linux".target = "i386";
    "x86_64-linux".target = "i386";
  };

  efiSystems = {
    "i686-linux".target = "i386";
    "x86_64-linux".target = "x86_64";
  };

  canEfi = any (system: stdenv.system == system) (mapAttrsToList (name: _: name) efiSystems);
  inPCSystems = any (system: stdenv.system == system) (mapAttrsToList (name: _: name) pcSystems);

in

assert efiSupport -> canEfi;

stdenv.mkDerivation rec {
  name = "grub-2.02-rc1";

  src = fetchurl {
    name = "${name}.tar.xz";
    url = "http://alpha.gnu.org/gnu/grub/grub-2.02~rc1.tar.xz";
    multihash = "QmbZLy1z443d6vqg4CrW1YTmpmib1r3hF8EpWtwK4KiT63";
    hashOutput = false;
    sha256 = "445239e9b96d1143c194c1d37851cf4196b83701c60172e49665e9d453d80278";
  };

  nativeBuildInputs = [
    autogen
    bison
    flex
    python
  ];

  buildInputs = [ ncurses libusb_1 freetype gettext lvm2 zfs ];

  patches = [
    ./fix-bash-completion.patch
  ];

  configureFlags = [
    "--enable-libzfs"
  ] ++ optionals efiSupport [
    "--with-platform=efi"
    "--target=${efiSystems.${stdenv.targetSystem}.target}"
    "--program-prefix="
  ];

  # save target that grub is compiled for
  grubTarget =
    if efiSupport then
      "${efiSystems.${stdenv.targetSystem}.target}-efi"
    else if inPCSystems then
      "${pcSystems.${stdenv.targetSystem}.target}-pc"
    else 
      throw "Unsupported Target";

  # We don't need any security / optimization features for a bootloader
  optFlags = false;
  pie = false;
  fpic = false;
  noStrictOverflow = false;
  fortifySource = false;
  stackProtector = false;
  optimize = false;

  passthru = rec {
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
