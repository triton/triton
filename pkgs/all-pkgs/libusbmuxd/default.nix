{ stdenv
, fetchurl

, inotify-tools
, libplist
}:

with {
  inherit (stdenv)
    isLinux;
  inherit (stdenv.lib)
    optionals
    wtFlag;
};

stdenv.mkDerivation rec {
  name = "libusbmuxd-1.0.10";
  src = fetchurl {
    url = "http://www.libimobiledevice.org/downloads/${name}.tar.bz2";
    sha256 = "1wn9zq2224786mdr12c5hxad643d29wg4z6b7jn888jx4s8i78hs";
  };

  buildInputs = [
    libplist
  ] ++ optionals isLinux [
    inotify-tools
  ];

  configureFlags = [
    # Flag is not a boolean
    #"--with-inotify"
    (if isLinux then
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
    maintainers = with maintainers; [ ];
    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];
  };
}
