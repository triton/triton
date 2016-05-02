{ stdenv
, fetchFromGitHub
, fetchpatch
, fetchTritonPatch

, popt
}:

stdenv.mkDerivation rec {
  name = "efivar-${version}";
  version = "0.23";

  src = fetchFromGitHub {
    owner = "rhinstaller";
    repo = "efivar";
    rev = version;
    sha256 = "8002bd15c3fda3511352a393556817281f2ef70a4eba8d2c24ac0dc192df9355";
  };

  buildInputs = [
    popt
  ];

  patches = [
    # Remove patch for 0.24+
    (fetchTritonPatch {
      rev = "a4ffceabb7dc8678c71803facfde88d9c0b4fac2";
      file = "efivar/efivar-0.21-nvme_ioctl.h.patch";
      sha256 = "f71fb95d12800bc6934213ee2541dbeea2adb8e545929330b4baf5a049bb52e6";
    })
  ];

  postPatch =
    /* FIXME:
       ld.so not properly linked in with ld --no-allow-shlib-undefined
       https://sourceware.org/bugzilla/show_bug.cgi?id=19249 */ ''
      sed -i gcc.specs \
        -e 's/--no-allow-shlib-undefined//'
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

  # Parallel building should be fixed in 0.24+
  parallelBuild = false;

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
