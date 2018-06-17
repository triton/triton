{ stdenv
, buildPythonPackage
, fetchPyPi

, libarchive
}:

let
  version = "2.8";
in
buildPythonPackage {
  name = "libarchive-c-${version}";

  src = fetchPyPi {
    package = "libarchive-c";
    inherit version;
    sha256 = "06d44d5b9520bdac93048c72b7ed66d11a6626da16d2086f9aad079674d8e061";
  };

  postPatch = ''
    grep -r 'libarchive_path' | awk -F: '{print $1}' | sort | uniq | xargs -n 1 -P $NIX_BUILD_CORES \
      sed \
        -e 's,(libarchive_path),("${libarchive}/lib/libarchive.so"),g' \
        -e '/libarchive_path =/d' \
        -i
  '';

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
