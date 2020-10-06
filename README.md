# VS Coder Server on Kubernetes
This is a optimized Code Server image for Kubernetes which is used in the [Calavera Project](https://github.com/simwak/calavera).

Be aware, that only your home directory `/home/coder/` will be persistent!  
`kubectl` is configured for defined namespace (`$NAMESPACE`).