{ fetchTritonPatch }:
{
  "7" = {
    version = "7.2.0";
    sha256 = "1cf7adf8ff4b5aa49041c8734bbcf1ad18cc4c94d0029aae0f4e48841088479a";
    patches = [
      (fetchTritonPatch {
        rev = "8d29376d9dbe106435e0f58523fef8617da47972";
        file = "g/gcc/0001-libcpp-Remove-path-impurities.7.1.0.patch";
        sha256 = "10ed16616d7ed59d4c215367a63b6a1646b8be94be81737bd48403f6ff26d083";
      })
      (fetchTritonPatch {
        rev = "8d29376d9dbe106435e0f58523fef8617da47972";
        file = "g/gcc/0002-libcpp-Enforce-purity-for-time-functions.7.1.0.patch";
        sha256 = "616d16c4586a6ae4823a2e780a0655bf45f07caaacdc5886b73b41a3f5b9ab3d";
      })
      (fetchTritonPatch {
        rev = "8d29376d9dbe106435e0f58523fef8617da47972";
        file = "g/gcc/0003-Don-t-look-in-usr.7.1.0.patch";
        sha256 = "e6ca5a8e0d850c3ab7be2aca4b4dbf0295e1ea5ddeb606f39773bd2144ae3d67";
      })
    ];
  };
}
