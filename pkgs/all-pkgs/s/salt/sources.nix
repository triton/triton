{ }:

# https://docs.saltstack.com/en/latest/topics/releases/index.html
# https://saltstack.com/product-support-lifecycle/

{
  "2016.3" = {
    version = "2016.3.5";
    sha256 = "fec215dfdec33ca6826453e5437656f9ed5e4a121ef3db6341f91f799cd3e751";
  };
  "2016.11" = {
    version = "2016.11.4";
    sha256 = "fb4109b28d3fd898291c162e42ef843fbd4c3e57244075670fa8f366e705765f";
  };
  head = {
    fetchzipversion = 2;
    version = "2017-02-17";
    rev = "deba6d26554720953409d2280e366621f40f5162";
    sha256 = "bcfd9417a3a37909c4835dc401d57d6eb3c90b89e30526f4e76bf8d7df177afd";
  };
}
