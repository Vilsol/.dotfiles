# General nixpkgs evaluation settings. Package-specific overrides stay with the
# module that needs them (see ./kernel.nix for intel-vaapi-driver); everything
# that applies repo-wide lives here.
{
  nixpkgs.config = {
    allowUnfree = true;

    permittedInsecurePackages = [
      "python-2.7.18.6"
      "electron-24.8.6"
    ];

    segger-jlink.acceptLicense = true;
  };
}
