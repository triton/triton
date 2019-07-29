{ stdenv
, fetchTritonPatch
, fetchurl
, gperf_3-0

, zlib
}:

let
  version = "0.15.1b";
in
stdenv.mkDerivation rec {
  name = "libid3tag-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/mad/libid3tag/${version}/${name}.tar.gz";
    sha256 = "63da4f6e7997278f8a3fef4c6a372d342f705051d1eeb6a46a86b03610e26151";
  };

  nativeBuildInputs = [
    gperf_3-0
  ];

  propagatedBuildInputs = [
    zlib
  ];

  patches = [
    (fetchTritonPatch {
      rev = "37a2a3f8348589f2ee6390d3aa20774866054147";
      file = "l/libid3tag/0001-fix-utf16.patch";
      sha256 = "88dc4e0b31aed1fdc2507cd2bb33a16d7a8c49472f080a409c49df6758e3dde8";
    })
    (fetchTritonPatch {
      rev = "37a2a3f8348589f2ee6390d3aa20774866054147";
      file = "l/libid3tag/0002-fix-unknown-encoding.patch";
      sha256 = "c2fa0fa78b56d3615c36035a0a791ef6e09c80c8ed565b2ccd737e46928ff44d";
    })
    (fetchTritonPatch {
      rev = "37a2a3f8348589f2ee6390d3aa20774866054147";
      file = "l/libid3tag/0003-CVE-2008-2109.patch";
      sha256 = "b1f8b4ca18dd4d5682a7071631132d1a2652e4b8e33b533f5c7b519348c6a4d4";
    })
  ];

  # Configure script is not compatible with busybox ash
  postPatch = ''
    patchShebangs configure
  '';
  
  postInstall = ''
    grep -r 'id3_compat_fixup'
    mkdir -p "$out"/lib/pkgconfig
    sed \
      -e "s,@out@,$out,g" \
      -e 's,@version@,${version},g' \
      ${./id3tag.pc} > "$out"/lib/pkgconfig/i3dtag.pc
  '';
  
  meta = with stdenv.lib; {
    description = "ID3 tag manipulation library";
    homepage = http://mad.sourceforge.net/;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
