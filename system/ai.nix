{config, ...}: {
  services.ollama = {
    enable = config.full-desktop;
    loadModels = ["llama3"];
    acceleration = "cuda";
  };
}
