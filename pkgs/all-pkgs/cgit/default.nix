{ stdenv
, fetchgit

, openssl
, zlib
}:

stdenv.mkDerivation {
  name = "cgit-2016-05-12";

  src = fetchgit {
    url = "https://git.zx2c4.com/cgit";
    rev = "21bf30b043c5bcbf4bb92d7e79cb642ab9c2287d";
    sha256 = "0s1sg891kwgw1a6bbpms3k7xzynf0w0yzlphgid51xljrh1mcfv4";
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
