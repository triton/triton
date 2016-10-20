{ stdenv
, fetchgit

, openssl
, zlib
}:

stdenv.mkDerivation {
  name = "cgit-2016-10-12";

  src = fetchgit {
    version = 2;
    url = "https://git.zx2c4.com/cgit";
    rev = "c330a2e5f86e1f77d3b724877935e11014cefa21";
    sha256 = "0x82fhvzbc7i4z0rda8vd0xv26ifg4c2r64alxwv3b9p798fz2gp";
  };

  buildInputs = [
    openssl
    zlib
  ];

  preBuild = ''
    makeFlagsArray+=("prefix=$out")
  '';

  preInstall = ''
    installFlagsArray+=(
      "CGIT_SCRIPT_PATH=$out/share/cgit/www"
    )
  '';

  preFixup = ''
    find . -type f -executable -exec strip -s -v {} \;
  '';

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
