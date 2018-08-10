{ stdenv
, fetchFromGitHub
, fetchTritonPatch
, fetchurl
}:

let
  fetcher = { fetchzipVersion ? null, version ? null, rev ? null, sha256 }:
    if fetchzipVersion != null then
      fetchFromGitHub {
        owner = "zfsonlinux";
        repo = "zfs";
        rev = if version != null then "zfs-${version}" else rev;
        inherit sha256;
        version = fetchzipVersion;
      }
    else
      fetchurl {
        url = "https://github.com/zfsonlinux/zfs/releases/download/zfs-${version}/zfs-${version}.tar.gz";
        inherit sha256;
      };

in
{
  "stable" = rec {
    version = "0.7.9";
    maxLinuxVersion = "4.17";
    src = fetcher {
      inherit version;
      sha256 = "f50ca2441c6abde4fe6b9f54d5583a45813031d6bb72b0011b00fc2683cd9f7a";
    };
    patches = [
      (fetchTritonPatch {
        rev = "a061e816f5a9fa5565f53a4213edb75b42ee5607";
        file = "z/zfs/0002-Fix-binary-paths.patch";
        sha256 = "a114332256ed06c51c2e9c019f0b810947f65393d5b82bcf1e72b13c351c7fe6";
      })
    ];
  };
  "dev" = {
    date = "2018-08-03";
    maxLinuxVersion = "4.18";
    src = fetcher {
      fetchzipVersion = 6;
      rev = "c8c308362c2f0a43adbe21a44b3443a27d2c7ca9";
      sha256 = "a05f7b7490b4e94a64e5bdf30e21e5058f64b84963e5b3088ea47512f24c9dae";
    };
    patches = [
      (fetchTritonPatch {
        rev = "3294dce1acb29f03f81d4326e91c0e72613578ca";
        file = "z/zfs/0001-Fix-binary-paths.patch";
        sha256 = "8e2b8380c0570c7ea44a8d7c93b2045341f77b94b6c8745c59576eec331c51cc";
      })
    ];
  };
}
