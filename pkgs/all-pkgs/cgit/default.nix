{ stdenv
, fetchgit

, openssl
, zlib
}:

stdenv.mkDerivation {
  name = "cgit-2016-05-20";

  src = fetchgit {
    url = "https://git.zx2c4.com/cgit";
    rev = "41508c091186ece4cdc5d79c5ac0d2eda3d3edef";
    sha256 = "0zljfl2a5z0nv689h7a6a36q61573hibsi3802i6vqi3g2ygl6p7";
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
