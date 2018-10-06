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
    version = "0.7.11";
    maxLinuxVersion = "4.18";
    src = fetcher {
      inherit version;
      sha256 = "4dff9ecce6e02061242d9435febe88c1250de83b96d392b712bccf31c459517a";
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
    date = "2018-10-04";
    maxLinuxVersion = "4.18";
    src = fetcher {
      fetchzipVersion = 6;
      rev = "dfbe26750308d757d20af8eb5aefef49ec65d4a8";
      sha256 = "24412cd635ef937e7b4f209c2d0c628df527f5ffce8f13bc43a7531b8cc69fcf";
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
