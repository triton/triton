{ stdenv
, fetchurl

, type ? "full"
}:

let
  inherit (stdenv.lib)
    optionalString;

  version = "1.2.11";

  tarballUrls = version: [
    "http://zlib.net/zlib-${version}.tar.xz"
  ];
in
stdenv.mkDerivation rec {
  name = "zlib-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    multihash = "QmZzQvzKgsgEN5cKkm2FJ4Tw66vWsSw122Wab3jdJV76My";
    sha256 = "4ff941449631ace0d4d203e3483be9dbc9da454084111f97ea0a2114e19bf066";
  };

  postInstall = optionalString (type != "full") ''
    rm -r "$out"/share
  '';

  # Ensure we don't depend on anything unexpected
  allowedReferences = [
    "out"
  ] ++ stdenv.cc.runtimeLibcLibs;

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "1.2.11";
      pgpsigUrls = map (n: "${n}.asc") urls;
      pgpKeyFingerprint = "5ED4 6A67 21D3 6558 7791  E2AA 783F CD8E 58BC AFBA";
      inherit (src) outputHashAlgo;
      outputHash = "4ff941449631ace0d4d203e3483be9dbc9da454084111f97ea0a2114e19bf066";
    };
  };

  meta = with stdenv.lib; {
    description = "Lossless data-compression library";
    homepage = http://www.zlib.net/;
    license = licenses.zlib;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
