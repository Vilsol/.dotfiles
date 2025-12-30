{pkgs, ...}: {
  services.ollama = {
    enable = false;
    package = pkgs.ollama-cuda;
    loadModels = [
      "deepseek-r1:32b"
      "qwen2.5-coder:7b"
    ];
  };
}
