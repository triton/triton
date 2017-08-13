{ stdenv
, fetchgit

, openssl
, zlib
}:

stdenv.mkDerivation {
  name = "cgit-2017-08-10";

  src = fetchgit {
    version = 3;
    url = "https://git.zx2c4.com/cgit";
    rev = "51cc456b773a3bb7253fad2146c1a0d2b0fa98cb";
    multihash = "QmaLBxCZxBictEMjkqVhhucgGJRbyC3DwduHY68JiRLRgf";
    sha256 = "726227d351687922bdb0b28ab70846fc7063ee96e40b6d9c13337c3413d0165f";
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
