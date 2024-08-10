{pkgs, ...}: {
  systemd.user.services.minikube-shutdown = {
    enable = true;
    description = "Stop minikube";
    script = ''${pkgs.minikube}/bin/minikube stop || true'';
    wantedBy = ["shutdown.target"];
  };
}
