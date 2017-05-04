# random bash scripts

# Install CLI tools

Installs the following CLI tools:

- terraform
- kops
- kubectl
- helm

No-op if the tool is already installed with the correct version.
Supports Mac and Linux.

```bash
# install all cli tools:
curl https://raw.githubusercontent.com/blockai/scripts/master/install-cli-tools.sh | bash
# install just helm and kubectl
curl https://raw.githubusercontent.com/blockai/scripts/master/install-cli-tools.sh | bash -s helm kubectl
# install just helm v2.4.2 and kubectl
curl https://raw.githubusercontent.com/blockai/scripts/master/install-cli-tools.sh | HELM_VERSION=2.4.0 bash -s helm kubectl
```

# Update k8s registry secret

Uses `aws ecr get-login` to get the user/pass for your AWS registry and
saves it as a Kubernetes secret named `aws-ecr-registry`.

Assumes the aws cli is available and  AWS credentials are set either
through environment variables (`AWS_ACCESS_KEY_ID` and
`AWS_SECRET_ACCESS_KEY`) or `~/.aws/credentials`.

```bash
# prints which cluster the command will use
kubectl config current-context

curl https://raw.githubusercontent.com/blockai/scripts/master/update-k8s-registry-secret.sh | bash
```
