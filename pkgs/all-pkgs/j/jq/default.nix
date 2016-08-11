{ stdenv
, fetchTritonPatch
, fetchurl

#, oniguruma  # Broken for some reason
}:

stdenv.mkDerivation rec {
  name = "jq-1.5";

  src = fetchurl {
    url = "https://github.com/stedolan/jq/releases/download/${name}/${name}.tar.gz";
    sha256 = "c4d2bfec6436341113419debf479d833692cc5cdab7eb0326b5a4d4fbe9f493c";
  };

  buildInputs = [
    #oniguruma
  ];

  patches = [
    (fetchTritonPatch {
      rev = "17b376c8a31a31c1b962aa6a856830cbafd13651";
      file = "jq/jq-1.5-cve-2015-8863.patch";
      sha256 = "c0cc0da8be2324ece805b6324173d6b12c4865c744cec38d95a51c338442ee5c";
    })
  ];

  # For some reason jq doesn't have the rpath for libjq.so
  preFixup = ''
    patchelf \
      --set-rpath "$out/lib:$(patchelf \
      --print-rpath "$out/bin/jq")" \
      "$out/bin/jq"
  '';

  meta = with stdenv.lib; {
    description = "A lightweight and flexible command-line JSON processor";
    license = licenses.mit;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
