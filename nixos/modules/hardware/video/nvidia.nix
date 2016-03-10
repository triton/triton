# This module provides the proprietary NVIDIA X11 / OpenGL drivers.

{ config, lib, pkgs, pkgs_i686, ... }:

with lib;

let

  drivers = config.services.xserver.videoDrivers;

  # FIXME: should introduce an option like
  # ‘hardware.video.nvidia.package’ for overriding the default NVIDIA
  # driver.
  nvidiaForKernel = kernelPackages:
    if elem "nvidia" drivers || elem "nvidia-long" drivers then
      kernelPackages.nvidia-drivers_long
    else if elem "nvidia-short" drivers then
      kernelPackages.nvidia-drivers_short
    else if elem "nvidia-testing" drivers then
      kernelPackages.nvidia-drivers_testing
    else if elem "nvidia-legacy304" drivers then
      kernelPackages.nvidia-drivers_legacy304
    else if elem "nvidia-legacy340" drivers then
      kernelPackages.nvidia-drivers_legacy340
    else if elem "nvidia-vulkan" drivers then
      kernelPackages.nvidia-drivers_vulkan
    else null;

  nvidia-drivers = nvidiaForKernel config.boot.kernelPackages;
  nvidia-drivers_libs32 = (nvidiaForKernel pkgs_i686.linuxPackages).override {
    buildConfig = "userspace";
    libsOnly = true;
    kernel = null;
  };

  enabled = nvidia-drivers != null;
in

{

  config = mkIf (config.services.xserver.enable && enabled) {

    services.xserver.drivers = singleton {
      name = "nvidia";
      modules = [
        nvidia-drivers
      ];
      libPath = [
        nvidia-drivers
      ];
    };

    services.xserver.screenSection = ''
      Option "RandRRotation" "on"
    '';

    hardware.opengl.package = nvidia-drivers;
    hardware.opengl.package32 = nvidia-drivers_libs32;

    environment.systemPackages = [
      nvidia-drivers
    ];

    boot.extraModulePackages = [
      nvidia-drivers
    ];

    # nvidia-uvm is required by CUDA applications.
    boot.kernelModules = [
      "nvidia-uvm"
    ];

    # Create /dev/nvidia-uvm when the nvidia-uvm module is loaded.
    services.udev.extraRules = ''
      KERNEL=="nvidia_uvm", RUN+="${pkgs.stdenv.shell} -c 'mknod -m 666 /dev/nvidia-uvm c $(grep nvidia-uvm /proc/devices | cut -d \  -f 1) 0'"
    '';

    boot.blacklistedKernelModules = [
      "nouveau"
      "nvidiafb"
    ];

    services.acpid.enable = true;

    environment.etc."OpenCL/vendors/nvidia.icd".source = "${nvidia-drivers}/lib/vendors/nvidia.icd";

  };

}
