{
  age,
  config,
  ...
}: {
  nix = {
    optimise.automatic = true;

    settings.auto-optimise-store = true;

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
  };

  age.identityPaths = [
    "/home/vilsol/.ssh/id_25519"
  ];

  age.secrets.secret1.file = ../secrets/secret1.age;

  environment.etc.foo = {
    text = config.age.secrets.secret1.path;
  };
}
