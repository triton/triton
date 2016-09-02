{ stdenv
, fetchurl
, makeWrapper

, expect
}:

stdenv.mkDerivation rec {
  name = "dejagnu-1.6";

  src = fetchurl {
    url = "mirror://gnu/dejagnu/${name}.tar.gz";
    hashOutput = false;
    sha256 = "00b64a618e2b6b581b16eb9131ee80f721baa2669fa0cdee93c500d1a652d763";
  };

  nativeBuildInputs = [
    makeWrapper
  ];

  buildInputs = [
    expect
  ];

  postInstall = ''
    wrapProgram "$out/bin/runtest" \
      --prefix PATH ":" "${expect}/bin"
  '';

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.sig") src.urls;
      pgpKeyFingerprint = "CB0B 3145 2BBE 8629 3301  3D91 7636 2888 B559 88D4";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    description = "Framework for testing other programs";
    homepage = http://www.gnu.org/software/dejagnu/;
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
