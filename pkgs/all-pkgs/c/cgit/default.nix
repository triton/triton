{ stdenv
, fetchgit

, openssl
, zlib
}:

stdenv.mkDerivation {
  name = "cgit-2016-11-25";

  src = fetchgit {
    version = 2;
    url = "https://git.zx2c4.com/cgit";
    rev = "2b993402c7ed5849606a5bf4d3c7cb212f491b06";
    sha256 = "1544496428c29d9c91f1d807636dfb0807ab8384648608e9c8d9284f8ca99e3c";
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
