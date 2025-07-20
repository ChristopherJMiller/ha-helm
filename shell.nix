{
  pkgs ? import <nixpkgs> { },
}:

pkgs.mkShell {
  packages = with pkgs; [
    git
    kubectl
    pre-commit
    kustomize
    kubernetes-helm
    kubernetes-helmPlugins.helm-unittest
    minikube
  ];
}
