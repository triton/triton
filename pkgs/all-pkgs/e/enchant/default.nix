{ stdenv
, fetchurl
, fetchTritonPatch
, lib

, aspell
, dbus-glib
, glib
, hunspell
}:

let
  inherit (lib)
    replaceChars;

  version = "1.6.1";
  versionFormatted = replaceChars ["."] ["-"] version;
in
stdenv.mkDerivation rec {
  name = "enchant-${version}";

  src = fetchurl {
    url = "https://github.com/AbiWord/enchant/releases/download/"
      + "enchant-${versionFormatted}/${name}.tar.gz";
    sha256 = "bef0d9c0fef2e4e8746956b68e4d6c6641f6b85bd2908d91731efb68eba9e3f5";
  };

  buildInputs = [
    aspell
    dbus-glib
    glib
    hunspell
  ];

  patches = [
    (fetchTritonPatch {
      rev = "36ad89df3c22215909e7292c6bf1d4d90192fa49";
      file = "enchant/hunspell-fix.patch";
      sha256 = "54e325f71959828f1f04e03cd33b9b80f0dfdc89b68859c08e51831052f1b346";
    })
  ];

  meta = with lib; {
    homepage = https://abiword.github.io/enchant/;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
