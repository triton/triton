{ stdenv
, fetchgit

, openssl
, zlib
}:

stdenv.mkDerivation {
  name = "cgit-2016-07-12";

  src = fetchgit {
    version = 1;
    url = "https://git.zx2c4.com/cgit";
    rev = "ff9893ac8192579a00dd4c73ddff18ab232099a6";
    sha256 = "0x3bs8088jxqvhi1kk7clzs08802l2dxhnqd5npi902ib8b562xc";
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
