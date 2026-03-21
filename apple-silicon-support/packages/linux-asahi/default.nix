{
  lib,
  callPackage,
  linuxPackagesFor,
  _kernelPatches ? [ ],
}:

let
  linux-asahi-pkg =
    {
      stdenv,
      lib,
      fetchFromGitHub,
      fetchpatch,
      buildLinux,
      ...
    }:
    buildLinux rec {
      inherit stdenv lib;

      pname = "linux-asahi";
      version = "6.19.7";
      modDirVersion = version;
      extraMeta.branch = "6.19";

      src = fetchFromGitHub {
        owner = "AsahiLinux";
        repo = "linux";
        rev = "5aefe0fbf7e3f8d9ea937e36103ad46143024706";
        hash = "sha256-2QtS7iaE0/UvOhNXko+Gjji7zza1G3GqFUCPVXPPLBs=";
      };

      kernelPatches = [
        {
          name = "Asahi config";
          patch = null;
          structuredExtraConfig = with lib.kernel; {
            # Needed for GPU
            ARM64_16K_PAGES = yes;

            ARM64_MEMORY_MODEL_CONTROL = yes;
            ARM64_ACTLR_STATE = yes;

            # Might lead to the machine rebooting if not loaded soon enough
            APPLE_WATCHDOG = yes;

            # Can not be built as a module, defaults to no
            APPLE_M1_CPU_PMU = yes;

            # Defaults to 'y', but we want to allow the user to set options in modprobe.d
            HID_APPLE = module;

            APPLE_PMGR_MISC = yes;
            APPLE_PMGR_PWRSTATE = yes;
          };
          features.rust = true;
        }
      ]
      ++ _kernelPatches;
    };

  linux-asahi = callPackage linux-asahi-pkg { };
in
lib.recurseIntoAttrs (linuxPackagesFor linux-asahi)
