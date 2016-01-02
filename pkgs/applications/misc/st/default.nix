{ stdenv, fetchurl, writeText, xorg, ncurses, fontconfig
, conf? null}:

with stdenv.lib;

stdenv.mkDerivation rec {
  name = "st-0.6";
  
  src = fetchurl {
    url = "http://dl.suckless.org/st/${name}.tar.gz";
    sha256 = "0avsfc1qp8zvshsfjwwrkvk411jlqy58z225bsdhjkl1qc40qcc5";
  };

  configFile = optionalString (conf!=null) (writeText "config.def.h" conf);
  preBuild = optionalString (conf!=null) "cp ${configFile} config.def.h";
  
  buildInputs = [ xorg.libX11 ncurses xorg.libXext xorg.libXft fontconfig ];

  NIX_LDFLAGS = "-lfontconfig";

  installPhase = ''
    TERMINFO=$out/share/terminfo make install PREFIX=$out
  '';
    
  meta = {
    homepage = http://st.suckless.org/;
    license = stdenv.lib.licenses.mit;
    maintainers = with maintainers; [viric];
    platforms = platforms.linux;
  };
}
