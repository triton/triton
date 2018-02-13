{ stdenv
, fetchurl
, lib

, channel
}:

# The celt codec has been deprecated and is now a part of the opus codec.
# Do NOT link new applications against these libraries.

let
  inherit (lib)
    optionals
    versionAtLeast;

  sources = {
    "0.5" = {
      version = "0.5.1.3";
      multihash = "QmRSQj9eJJTiRNKvYeXcm4Dow1PRSvujBp5uKeFGofGzNy";
      sha256 = "fc2e5b68382eb436a38c3104684a6c494df9bde133c139fbba3ddb5d7eaa6a2e";
    };
    "0.11" = {
      version = "0.11.3";
      multihash = "QmZmsAcAezXXCLo2ZFP6zkS93FJNUtK3zkQGm5Ywe8SYnD";
      sha256 = "7e64815d4a8a009d0280ecd235ebd917da3abdcfd8f7d0812218c085f9480836";
    };
  };
  source = sources."${channel}";
in
stdenv.mkDerivation rec {
  name = "celt-${source.version}";

  src = fetchurl {
    url = "mirror://xiph/celt/${name}.tar.gz";
    inherit (source) sha256;
  };

  configureFlags = optionals (versionAtLeast source.version "0.11") [
    "--enable-custom-modes"
  ];

  meta = with lib; {
    description = "Ultra-low delay audio codec";
    homepage = http://www.celt-codec.org/;
    license = licenses.bsd2;
    maintainers = with maintainers; [
      codyopel
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
