# 09-auth

Creates the Cognito User Pool, public web app client, and the IRSA IAM role used by `backend/backend-login-service`.

The Kubernetes ServiceAccount is declared in GitOps so Argo CD owns workload manifests. Terraform owns only AWS-side identity and permissions.
