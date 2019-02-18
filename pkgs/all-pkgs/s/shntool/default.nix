{ stdenv
, fetchurl
, lib
, makeWrapper

#, alac-decoder
, flac
, mac
#, shorten
, sox
, wavpack
}:

let
  version = "3.0.10";
in
stdenv.mkDerivation rec {
  name = "shntool-${version}";

  src = fetchurl {
    url = "http://shnutils.freeshell.org/shntool/dist/src/${name}.tar.gz";
    multihash = "QmXkBizEKhTxjqK2effFa6roHV8E4mJQHUyELwqMeCVBgc";
    sha256 = "74302eac477ca08fb2b42b9f154cc870593aec8beab308676e4373a5e4ca2102";
  };

  nativeBuildInputs = [
    makeWrapper
  ];

  postInstall = ''
    wrapProgram "$out"/bin/shntool \
      --prefix PATH : "${flac}/bin" \
      --prefix PATH : "${mac}/bin" \
      --prefix PATH : "${sox}/bin" \
      --prefix PATH : "${wavpack}/bin"
  '';

  meta = with lib; {
    description = "WAVE data processing and reporting utility";
    homepage = http://shnutils.freeshell.org/shntool/;
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
