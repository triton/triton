{ stdenv
, fetchurl
}:

let
  version = "29";
in
stdenv.mkDerivation {
  name = "wireless-tools-29";

  src = fetchurl {
    url = "http://www.hpl.hp.com/personal/Jean_Tourrilhes/Linux/wireless_tools.${version}.tar.gz";
    multihash = "QmWcqpZYVk8LzWR43ALGnAQd2stW67yfAywL3DjVR7Jsaq";
    sha256 = "18g5wa3rih89i776nc2n2s50gcds4611gi723h9ki190zqshkf3g";
  };

  preBuild = ''
    makeFlagsArray+=("PREFIX=$out")
  '';

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
