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
  name = "grub-2.02-beta3";

  src = fetchurl {
    name = "${name}.tar.xz";
    url = "http://alpha.gnu.org/gnu/grub/grub-2.02~beta3.tar.xz";
    multihash = "QmWKaXPG17wgsgchV5gEbV6ZKCzTSjQVbtwXdtaeoocxV6";
    sha256 = "30ec3d555e52a702c3eef449872ef874eff28b320f40b55ffc47f70db8e5ada1";
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
