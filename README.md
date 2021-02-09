# bitnami

Powershell Client command for Key transfer
type $env:USERPROFILE\.ssh\id_rsa.pub | ssh bitnami@192.168.0.37 "cat >> .ssh/authorized_keys"
type $env:USERPROFILE\.ssh\id_ed25519.pub | ssh bitnami@192.168.0.37 "cat >> .ssh/authorized_keys"
