{ stdenv
, fetchurl
, fetchTritonPatch

, aspell
, dbus-glib
, glib
, hunspell
}:

let
  version = "1.6.0";
in
stdenv.mkDerivation rec {
  name = "enchant-${version}";

  src = fetchurl {
    url = "http://www.abisource.com/downloads/enchant/${version}/${name}.tar.gz";
    md5Url = "http://www.abisource.com/downloads/enchant/${version}/MD5SUM";
    sha256 = "0zq9yw1xzk8k9s6x83n1f9srzcwdavzazn3haln4nhp9wxxrxb1g";
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

  meta = with stdenv.lib; {
    homepage = http://www.abisource.com/enchant;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
