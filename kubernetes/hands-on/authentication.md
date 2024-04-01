# Authentication, Role Based Access Control, Service Account

Authentication
It is related to authenticate user to use specific cluster.
Theory of the creating authentication is explained in short:
user creates .key (key file) and .csr (certificate signing request file includes username and roles) with openssl application
user sends .csr file to the K8s admin
K8s admin creates a K8s object with this .csr file and creates .crt file (certification file) to give user
user gets this .crt file (certification file) and creates credential (set-credentials) in user's pc with certification.
user creates context (set-context) with cluster and credential, and uses this context.
now it requires to get/create authorization for the user.
Role Based Access Control (RBAC, Authorization)
It provides to give authorization (role) to the specific user.
"Role", "RoleBinding" K8s objects are used to bind users for specific "namespace".
"ClusterRole", "ClusterRoleBinding" K8s objects are used to bind users for specific "namespace".