{ stdenv
, fetchurl
}:

let
  name = "man-pages-4.15";

  tarballUrls = [
    "mirror://kernel/linux/docs/man-pages/${name}.tar"
  ];
in
stdenv.mkDerivation rec {
  inherit name;

  src = fetchurl {
    url = map (n: "${n}.xz") tarballUrls;
    hashOutput = false;
    sha256 = "ce707f2a28ee49496595af163d0cac24a9b7b88ab9aa5e5057abaa3d03cec106";
  };

  preBuild = ''
   makeFlagsArray+=("MANDIR=$out/share/man")
  '';

  preferLocalBuild = true;

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.sign") tarballUrls;
      pgpDecompress = true;
      pgpKeyFingerprint = "E522 595B 52ED A4E6 BFCC  CB5E 8561 9911 3A35 CE5E";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    description = "Linux development manual pages";
    homepage = http://www.kernel.org/doc/man-pages/;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
