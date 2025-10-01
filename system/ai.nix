{config, ...}: {
  services.ollama = {
    enable = false;
    loadModels = [
      "deepseek-r1:32b"
      "qwen2.5-coder:7b"
    ];
    acceleration = "cuda";
  };
}
