{ stdenv
, fetchTritonPatch
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "tcp-wrappers-7.6-p${toString (stdenv.lib.length patches)}";

  src = fetchurl {
    url = [
      "ftp://ftp.porcupine.org/pub/security/tcp_wrappers_7.6.tar.gz"
      "http://files.ichilton.co.uk/nfs/tcp_wrappers_7.6.tar.gz"
    ];
    sha256 = "0p9ilj4v96q32klavx0phw9va21fjp8vpk11nbh6v2ppxnnxfhwm";
  };

  patches = [
    (fetchTritonPatch {
      rev = "519ce6ac3cbbfdd4e101fedac50d9ed62a1fa2b1";
      file = "tcp-wrappers/00_man_quoting.diff";
      sha256 = "c0e10e4c052be12f63d3efba66f8f069c4f4ca2448da3d9021a4706c51494971";
    })
    (fetchTritonPatch {
      rev = "519ce6ac3cbbfdd4e101fedac50d9ed62a1fa2b1";
      file = "tcp-wrappers/00_man_typos";
      sha256 = "24f3499795cf1c6f01e4d12322b67b67d048b6bbc6eb2ba6918f52643a9f2526";
    })
    (fetchTritonPatch {
      rev = "519ce6ac3cbbfdd4e101fedac50d9ed62a1fa2b1";
      file = "tcp-wrappers/01_man_portability";
      sha256 = "6a96b08899ffa2b18ea63086283de1659c59bb062fac9c68a7f9385295d338f2";
    })
    (fetchTritonPatch {
      rev = "519ce6ac3cbbfdd4e101fedac50d9ed62a1fa2b1";
      file = "tcp-wrappers/05_wildcard_matching";
      sha256 = "f77d39a7b5a288927c65866aa83e74acdeec3dd4126c9a4e6fea0ac6309ac738";
    })
    (fetchTritonPatch {
      rev = "519ce6ac3cbbfdd4e101fedac50d9ed62a1fa2b1";
      file = "tcp-wrappers/06_fix_gethostbyname";
      sha256 = "b8ec4d418d9cbcc9ef7e4761712c4fa990430e8f64a5182a9523395548b437b5";
    })
    (fetchTritonPatch {
      rev = "519ce6ac3cbbfdd4e101fedac50d9ed62a1fa2b1";
      file = "tcp-wrappers/10_usagi-ipv6";
      sha256 = "a99622edce5f443134c82d327ae8ece4b8ce46e91a3d37248a436b713573675e";
    })
    (fetchTritonPatch {
      rev = "519ce6ac3cbbfdd4e101fedac50d9ed62a1fa2b1";
      file = "tcp-wrappers/11_tcpd_blacklist";
      sha256 = "3b4bdfd8f38cd534ff9414a21505cb1e5fcc7da5fa29eac387f90a1d254d7bb5";
    })
    (fetchTritonPatch {
      rev = "519ce6ac3cbbfdd4e101fedac50d9ed62a1fa2b1";
      file = "tcp-wrappers/11_usagi_fix";
      sha256 = "e22e57966909a7ce56c2a12c647a0d182fafd33041e41fe767e925509a1a0ec4";
    })
    (fetchTritonPatch {
      rev = "519ce6ac3cbbfdd4e101fedac50d9ed62a1fa2b1";
      file = "tcp-wrappers/12_makefile_config";
      sha256 = "d62014ec66d21cb3052922cfe7dbda700caf6c30c647dae93ed9f78431c5644e";
    })
    (fetchTritonPatch {
      rev = "519ce6ac3cbbfdd4e101fedac50d9ed62a1fa2b1";
      file = "tcp-wrappers/13_shlib_weaksym";
      sha256 = "1d5863f239c1a241ff11bb103de95cce7b61a46b48e46a08409f90bd87a0232f";
    })
    (fetchTritonPatch {
      rev = "519ce6ac3cbbfdd4e101fedac50d9ed62a1fa2b1";
      file = "tcp-wrappers/14_cidr_support";
      sha256 = "aa0a663ebafb6ba1806dff6c405e8b822d11c3b0c6a223cdd6a978c87a016925";
    })
    (fetchTritonPatch {
      rev = "519ce6ac3cbbfdd4e101fedac50d9ed62a1fa2b1";
      file = "tcp-wrappers/15_match_clarify";
      sha256 = "8dcb13dbe285426d6e1723c3d1e3dc9bcb76ccae766640505d9fd4b7203375ac";
    })
    (fetchTritonPatch {
      rev = "519ce6ac3cbbfdd4e101fedac50d9ed62a1fa2b1";
      file = "tcp-wrappers/aclexec";
      sha256 = "c22a8f6909987c8076641d8d6bf0c609e29e1e8a90f3f46ebf6b75f3864c4fe0";
    })
    (fetchTritonPatch {
      rev = "519ce6ac3cbbfdd4e101fedac50d9ed62a1fa2b1";
      file = "tcp-wrappers/catch-sigchld";
      sha256 = "90bd4d185304771f5a569fd4919d64061747f948a13eef4da243c835949bb8c6";
    })
    (fetchTritonPatch {
      rev = "519ce6ac3cbbfdd4e101fedac50d9ed62a1fa2b1";
      file = "tcp-wrappers/expand_remote_port";
      sha256 = "886f966a32270e08ca9998603665763f5f27ca00411eb7348339473f28419105";
    })
    (fetchTritonPatch {
      rev = "519ce6ac3cbbfdd4e101fedac50d9ed62a1fa2b1";
      file = "tcp-wrappers/fix_parsing_long_lines";
      sha256 = "591358e684a1f94aaff09f38ebd7340325b2d3436eefa8f2994753cdba40420a";
    })
    (fetchTritonPatch {
      rev = "519ce6ac3cbbfdd4e101fedac50d9ed62a1fa2b1";
      file = "tcp-wrappers/fix_static";
      sha256 = "8d18e33e572c437fa06153e053c36a3d4ee6efdac3e230a5ad7facafb7f95f97";
    })
    (fetchTritonPatch {
      rev = "519ce6ac3cbbfdd4e101fedac50d9ed62a1fa2b1";
      file = "tcp-wrappers/fix_warnings";
      sha256 = "6591422fe877bf741c0651e77ce9c8eb2c4910da4ee7024f0851c10bc7e0a067";
    })
    (fetchTritonPatch {
      rev = "519ce6ac3cbbfdd4e101fedac50d9ed62a1fa2b1";
      file = "tcp-wrappers/have_strerror";
      sha256 = "aca759dbc60124d1286f4d0330d69aa6b70c0d16e52f0b7c351ae9a8b49dc3b5";
    })
    (fetchTritonPatch {
      rev = "519ce6ac3cbbfdd4e101fedac50d9ed62a1fa2b1";
      file = "tcp-wrappers/ignore_missing_inetdconf";
      sha256 = "4ac90e428f081b4cfe0ba0f0d8e389c48382b754b6bfea50a30b2874a4e713cb";
    })
    (fetchTritonPatch {
      rev = "519ce6ac3cbbfdd4e101fedac50d9ed62a1fa2b1";
      file = "tcp-wrappers/initgroups";
      sha256 = "e3e4d2be9748e4af3fcd70084cdac21dec7ab229e9bb326a1f967c08c32fc5c3";
    })
    (fetchTritonPatch {
      rev = "519ce6ac3cbbfdd4e101fedac50d9ed62a1fa2b1";
      file = "tcp-wrappers/man_fromhost";
      sha256 = "37dec7355f60b2ef91497edd966fb018a70d55b0c8a5db56b78ea7de3d52ec7f";
    })
    (fetchTritonPatch {
      rev = "519ce6ac3cbbfdd4e101fedac50d9ed62a1fa2b1";
      file = "tcp-wrappers/match_port";
      sha256 = "e6785d21a45188d404f43026f51c6d8286a06fb97b70d84cea66d278369881bd";
    })
    (fetchTritonPatch {
      rev = "519ce6ac3cbbfdd4e101fedac50d9ed62a1fa2b1";
      file = "tcp-wrappers/more_man_pages";
      sha256 = "9d2761d9704de0ee9ead6c0f76fe47abcab76aed3f7e0c2b4bc2f2b3a81b8d4a";
    })
    (fetchTritonPatch {
      rev = "519ce6ac3cbbfdd4e101fedac50d9ed62a1fa2b1";
      file = "tcp-wrappers/restore_sigalarm";
      sha256 = "2683f719f0e15339ec1ad00b3d0ed619e2c6d49bd58aa6b249eed1f31170dda4";
    })
    (fetchTritonPatch {
      rev = "519ce6ac3cbbfdd4e101fedac50d9ed62a1fa2b1";
      file = "tcp-wrappers/rfc931.diff";
      sha256 = "f8621652b5d93194990396c4b9b56c5d65ef46b04a458fcf734ca39d1386f7b4";
    })
    (fetchTritonPatch {
      rev = "519ce6ac3cbbfdd4e101fedac50d9ed62a1fa2b1";
      file = "tcp-wrappers/safe_finger";
      sha256 = "16775bd0d3400443003f22ea48a4f06888cc5aaa9fb1fb0749d0cc562aa49225";
    })
    (fetchTritonPatch {
      rev = "519ce6ac3cbbfdd4e101fedac50d9ed62a1fa2b1";
      file = "tcp-wrappers/sig_fix";
      sha256 = "4271d894cd4d87054e9a359bc5922bb65d64f4dc4d7463b3abea506878c4e30a";
    })
    (fetchTritonPatch {
      rev = "519ce6ac3cbbfdd4e101fedac50d9ed62a1fa2b1";
      file = "tcp-wrappers/siglongjmp";
      sha256 = "3a511a273f460915d18f40be3c36cb1ed2486473a11397cea5307153534e4db5";
    })
    (fetchTritonPatch {
      rev = "519ce6ac3cbbfdd4e101fedac50d9ed62a1fa2b1";
      file = "tcp-wrappers/size_t";
      sha256 = "3a719e357c02dc0dc24363efa38b0d168b4f292e2cf92ec53e8fa71a95742fa6";
    })
    (fetchTritonPatch {
      rev = "519ce6ac3cbbfdd4e101fedac50d9ed62a1fa2b1";
      file = "tcp-wrappers/tcpdchk_libwrapped";
      sha256 = "2b468184f2eb81bda3cad8fd70abe9a0ea08829921615be459736ebaf8fe204c";
    })
    (fetchTritonPatch {
      rev = "519ce6ac3cbbfdd4e101fedac50d9ed62a1fa2b1";
      file = "tcp-wrappers/tcp-wrappers-7.6-headers.patch";
      sha256 = "86d24cdf5d1c7f88d21b174988234d5024f506982e029e173c06cb5456c46bb0";
    })
    (fetchTritonPatch {
      rev = "519ce6ac3cbbfdd4e101fedac50d9ed62a1fa2b1";
      file = "tcp-wrappers/tcp-wrappers-7.6-redhat-bug11881.patch";
      sha256 = "b8b3bbbe223d3496b25070d1fbc62d9a1424709e20d380b55390b13f03b46e03";
    })
  ];

  preBuild = ''
    buildFlagsArray+=(
      "REAL_DAEMON_DIR=$out/bin"
      "linux"
    )
  '';

  # The build is very fragile so don't even try
  parallelBuild = false;

  installPhase = ''
    mkdir -p "$out/"{bin,include,lib,share/man/man{3,5,8}}
    cp -v safe_finger tcpd tcpdchk tcpdmatch try-from "$out/bin"
    cp -v shared/lib*.so* "$out/lib"
    cp -v *.h "$out/include"
    cp -v *.3 "$out/share/man/man3"
    cp -v *.5 "$out/share/man/man5"
    cp -v *.8 "$out/share/man/man8"
  '';

  meta = with stdenv.lib; {
    description = "TCP Wrappers, a network logger, also known as TCPD or LOG_TCP";
    homepage = ftp://ftp.porcupine.org/pub/security/index.html;
    license = "BSD-style";
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
