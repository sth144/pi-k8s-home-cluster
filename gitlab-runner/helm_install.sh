helm install k8s-runner gitlab/gitlab-runner --set gitlabUrl=https://gitlab.sth144.duckdns.org --set runnerRegistrationToken=$(cat ./.env.REGISTRATION_TOKEN) -f values.yaml
