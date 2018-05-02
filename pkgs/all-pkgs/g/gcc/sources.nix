{ fetchTritonPatch }:
{
  "8" = {
    version = "8.1.0";
    sha256 = "1d1866f992626e61349a1ccd0b8d5253816222cdc13390dcfaa74b093aa2b153";
    patches = [
      (fetchTritonPatch {
        rev = "8e60932cc6002332b7d031568bdb72ec2b494f1c";
        file = "g/gcc/0001-libcpp-Determine-if-we-should-enforce-purity.7.3.0.patch";
        sha256 = "f09d4135ed4b3a6ec5e82334667d1925ac65fc0ceecd0875ecca2c747cb0375e";
      })
      (fetchTritonPatch {
        rev = "8e60932cc6002332b7d031568bdb72ec2b494f1c";
        file = "g/gcc/0002-libcpp-Remove-path-impurities.7.3.0.patch";
        sha256 = "5b1350e80ff5d661dbcfb46ad9b429bb0d9de7ade9071fc4ad5f56f86cc9335f";
      })
      (fetchTritonPatch {
        rev = "8e60932cc6002332b7d031568bdb72ec2b494f1c";
        file = "g/gcc/0003-libcpp-Enforce-purity-for-time-functions.7.3.0.patch";
        sha256 = "7bea633c39650f2d3434f7cff52641ad6230989b98bd20ee908cc27250ce6572";
      })
      (fetchTritonPatch {
        rev = "7eb0a3fd9e53dbc2c1561f1605fd250f441cdfec";
        file = "g/gcc/0004-Workaround-for-impurity-detection.7.3.0.patch";
        sha256 = "b8a118de8a3ae4f15d9b130f137b9f48281f0c7352cd23d79ae4f50214e9ccc1";
      })
    ];
  };
}
