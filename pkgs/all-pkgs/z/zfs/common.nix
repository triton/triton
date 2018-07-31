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
    date = "2018-07-31";
    maxLinuxVersion = "4.18";
    src = fetcher {
      fetchzipVersion = 6;
      rev = "492f64e941e3d6b947d1cc387a1a380c0c738b09";
      sha256 = "516ed491fc63734dd3cb46ad9e5d031c063c6fade35579d1c37e48cbc476abb5";
    };
    patches = [
      ../../../../../zfs/0001-Fix-binary-paths.patch
    ];
  };
}
