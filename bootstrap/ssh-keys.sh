kubectl create secret generic ssh-keys-secret-combined --from-file=id_rsa=$HOME/.ssh/id_rsa --from-file=id_rsa.pub=$HOME/.ssh/id_rsa.pub --from-file=known_hosts=$HOME/.ssh/known_hosts
