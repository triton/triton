{ stdenv
, fetchTritonPatch
, fetchzip
}:

stdenv.mkDerivation rec {
  name = "time-1.7.2";

  src = fetchzip {
    version = 2;
    url = "http://git.savannah.gnu.org/cgit/time.git/snapshot/${name}.tar.xz";
    multihash = "QmZwpQZrzub9eKaxsR4JGi2rQxCAx85m794ueVbuFYrHF8";
    sha256 = "7792e109a3b586a498c3aa8fd42adcf45288001df0049d389d8c6fcf9115423c";
  };

  patches = [
    (fetchTritonPatch {
      rev = "31c27f1dfcd48150b1b91d5a9dc284679adf66ad";
      file = "t/time/1.7-Recompute-CPU-usage-at-microsecond-level.patch";
      sha256 = "ee1141a413d25aae7c9d1bfa9661106b84333ec4494ef20f1fae21e755158af2";
    })
    (fetchTritonPatch {
      rev = "31c27f1dfcd48150b1b91d5a9dc284679adf66ad";
      file = "t/time/1.7-ru_maxrss-is-in-kilobytes-on-Linux.patch";
      sha256 = "71318d632ae07020d993b15b42e6573eea0cb1a34a604a9b797015afe7729c74";
    })
  ];

  meta = with stdenv.lib; {
    description = "Tool that runs programs and summarizes the system resources they use";
    homepage = http://www.gnu.org/software/time/;
    license = licenses.gpl3;
		maintainers = with maintainers; [
			wkennington
		];
    platforms = with platforms;
      x86_64-linux;
  };
}
