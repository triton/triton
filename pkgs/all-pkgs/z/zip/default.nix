{ stdenv
, fetchurl
}:

stdenv.mkDerivation {
  name = "zip-3.0";

  src = fetchurl {
    name = "zip30.tgz";
    multihash = "QmdEzR5wvn7fEm5GGeksoxgitrNdo6pkwK68cjzmomqCmL";
    sha256 = "0sb3h3067pzf3a7mlxn1hikpcjrsvycjcnj9hl9b1c3ykcgvps7h";
  };

  makefile = "unix/Makefile";

  buildFlags = [
    "generic"
  ];

  preInstall = ''
    installFlagsArray+=("prefix=$out")
  '';

  installFlags = [
    "INSTALL=cp"
  ];

  meta = with stdenv.lib; {
    description = "Compressor/archiver for creating and modifying zipfiles";
    homepage = http://www.info-zip.org;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
