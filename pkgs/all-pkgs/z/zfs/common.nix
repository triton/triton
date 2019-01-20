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
    version = "0.7.12";
    maxLinuxVersion = "4.19";
    src = fetcher {
      inherit version;
      sha256 = "720e3b221c1ba5d4c18c990e48b86a2eb613575a0c3cc84c0aa784b17b7c2848";
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
    date = "2018-11-01";
    maxLinuxVersion = "4.20";
    src = fetcher {
      fetchzipVersion = 6;
      rev = "6644e5bb6e1a6c25c5006c819abf93c7bb662e80";
      sha256 = "a7ea9b3c33143f06120f1fb638735835ebca7dee927d865d0fd58ad1c1603adb";
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
