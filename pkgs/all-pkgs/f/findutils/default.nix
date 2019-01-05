{ stdenv
, fetchTritonPatch
, fetchurl

, type ? "full"
}:

let
  inherit (stdenv.lib)
    optionalString;
in
stdenv.mkDerivation rec {
  name = "findutils-4.6.0";

  src = fetchurl {
    url = "mirror://gnu/findutils/${name}.tar.gz";
    sha256 = "178nn4dl7wbcw499czikirnkniwnx36argdnqgz4ik9i6zvwkm6y";
  };

  patches = [
    (fetchTritonPatch {
      rev = "589213884b9474d570acbcb99ab58dbdec3e4832";
      file = "f/findutils/glibc-2.28-1.patch";
      sha256 = "84b916c0bf8c51b7e7b28417692f0ad3e7030d1f3c248ba77c42ede5c1c5d11e";
    })
    (fetchTritonPatch {
      rev = "589213884b9474d570acbcb99ab58dbdec3e4832";
      file = "f/findutils/glibc-2.28-2.patch";
      sha256 = "482e1a2f7acdca9f73affdce8cad51beaabb5ab99f64ed66391a8b36ed3dc822";
    })
  ];

  # We don't want to depend on bootstrap-tools
  ac_cv_path_SORT = "sort";

  postInstall = optionalString (type != "full") ''
    rm -r "$out"/share
  '';

  dontPatchShebangs = true;

  allowedReferences = [
    "out"
  ] ++ stdenv.cc.runtimeLibcLibs;

  meta = with stdenv.lib; {
    description = "GNU Find Utilities, basic directory searching utilities";
    homepage = http://www.gnu.org/software/findutils/;
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
