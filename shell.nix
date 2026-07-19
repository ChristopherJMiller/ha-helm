{
  pkgs ? import <nixpkgs> { },
}:

let
  # Wrap helm so the unittest plugin is registered (otherwise `helm unittest`
  # isn't found — the plugin package alone doesn't set HELM_PLUGINS).
  helm = pkgs.wrapHelm pkgs.kubernetes-helm {
    plugins = [ pkgs.kubernetes-helmPlugins.helm-unittest ];
  };
in
pkgs.mkShell {
  packages = with pkgs; [
    git
    kubectl
    pre-commit
    kustomize
    helm
    chart-testing
    minikube
  ];
}
