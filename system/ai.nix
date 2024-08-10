{
  services.ollama = {
    enable = false;
    loadModels = ["llama3"];
    acceleration = "cuda";
  };
}
