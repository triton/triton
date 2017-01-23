{ stdenv
, fetchgit

, openssl
, zlib
}:

stdenv.mkDerivation {
  name = "cgit-2017-01-23";

  src = fetchgit {
    version = 2;
    url = "https://git.zx2c4.com/cgit";
    rev = "be39d22328f841536b8e44e8aaeed80a74ebb353";
    sha256 = "28e4e9c1c36e430c855526cdc00ba284312a50b061439de9cd078ee07ed637dd";
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
