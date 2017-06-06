{ stdenv
, fetchTritonPatch
, fetchurl

, inotify-tools
, libplist
}:

let
  inherit (stdenv)
    targetSystem;
  inherit (stdenv.lib)
    elem
    optionals
    platforms
    wtFlag;
in

stdenv.mkDerivation rec {
  name = "libusbmuxd-1.0.10";
  src = fetchurl {
    url = "http://www.libimobiledevice.org/downloads/${name}.tar.bz2";
    sha256 = "1wn9zq2224786mdr12c5hxad643d29wg4z6b7jn888jx4s8i78hs";
  };

  buildInputs = [
    libplist
  ] ++ optionals (elem targetSystem platforms.linux) [
    inotify-tools
  ];

  patches = [
    (fetchTritonPatch {
      rev = "272bdf3b004be583496e804d7c80553ddbef18a9";
      file = "l/libusbmuxd/CVE-2016-5104.patch";
      sha256 = "9f3a84c8d0a32df13985f6574f5f0e86af435a67606612c0811df631070a97e3";
    })
  ];

  configureFlags = [
    # Flag is not a boolean
    (if elem targetSystem platforms.linux then
       null
     else
       "--without-inotify")
  ];

  meta = with stdenv.lib; {
    description = "USB multiplex daemon for Apple iPhone/iPod Touch devices";
    homepage = "http://www.libimobiledevice.org";
    license = with licenses; [
      gpl2Plus
      lgpl21Plus
    ];
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
