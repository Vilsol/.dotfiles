{
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      AllowUsers = ["vilsol"];
      X11Forwarding = true;
      PermitRootLogin = "no";
    };
  };
}
