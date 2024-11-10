{
  services.ollama = {
    enable = false;
    loadModels = [
      "llama3.2:8b"
      "starcoder2:3b"
      "codegemma:2b"
    ];
    acceleration = "cuda";
  };
}
