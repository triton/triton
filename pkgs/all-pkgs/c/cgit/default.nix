{ stdenv
, fetchgit

, openssl
, zlib
}:

stdenv.mkDerivation {
  name = "cgit-2016-10-01";

  src = fetchgit {
    version = 2;
    url = "https://git.zx2c4.com/cgit";
    rev = "ef3108656b9c6e22604c18bd9d05bdc847d81e87";
    sha256 = "1ws73z22fl0jq6hb119k8fva02qq4dx2h7lciyigp0xj1sa2gdcq";
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
