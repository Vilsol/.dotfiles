{config, ...}: {
  services.ollama = {
    enable = config.full-desktop;
    loadModels = [
      "deepseek-r1:32b"
      "qwen2.5-coder:7b"
    ];
    acceleration = "cuda";
  };
  services.open-webui.enable = config.full-desktop;
}
