{ stdenv
, fetchTritonPatch
, fetchzip
}:

stdenv.mkDerivation rec {
  name = "time-1.7.3-RC1";

  src = fetchzip {
    version = 2;
    url = "http://git.savannah.gnu.org/cgit/time.git/snapshot/9cf20c04418e0ac22d077638d935325847368d42.tar.xz";
    multihash = "Qmds3jGfVTszo8yUFn8Hp1UoZb8wMDousy1F5tt8N7YLUP";
    sha256 = "c0516c7c162457983ae04d691403f227813d3d22d21046d238b84c83c53ffed2";
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
