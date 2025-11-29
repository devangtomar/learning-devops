# Ansible playbooks, roles & full repo layout — complete reference + examples

> A single place that explains **plays**, **playbooks**, **roles**, the **Ansible repo layout**, inventories (INI & YAML), `group_vars` / `host_vars`, `ansible.cfg`, **vault**, handlers, modules for **databases** and **webservers**, plugins, and example YAML for every common file.

---

## Quick definitions

- **Play**: a mapping in a playbook that defines _which hosts_ the tasks should run on and _which roles/tasks/vars_ to apply. Each play targets a host group.
- **Playbook**: a YAML file containing one or more plays. This is what you run with `ansible-playbook`.
- **Role**: a structured collection of tasks, handlers, files, templates, variables, defaults and metadata designed for reusability. Roles live in `roles/` and follow a strict directory layout.
- **Inventory**: list of hosts and groups (INI or YAML format). Can include host and group variables.
- **Vault**: Ansible's method of encrypting secrets (files or strings) using `ansible-vault`.
- **Handler**: a special task triggered by `notify` from other tasks (commonly used to restart services).

---

## Typical repository top-level tree (opinionated but covers everything)

```
ansible-repo/
├── ansible.cfg
├── requirements.yml             # optional: dependencies for ansible-galaxy (roles/collections)
├── inventories/
│   ├── production/              # environment-based inventory (YAML or INI)
│   │   ├── hosts.yml
│   │   └── group_vars/
│   │       ├── all.yml
│   │       └── webservers.yml
│   └── staging/
│       ├── hosts.ini
│       └── host_vars/
│           └── db1.yml
├── site.yml                     # entry-point playbook (often calls roles)
├── webservers.yml               # smaller playbooks for specific roles
├── databases.yml
├── roles/
│   ├── webserver/               # example role
│   │   ├── defaults/            # default vars (can be overridden)
│   │   │   └── main.yml
│   │   ├── vars/                # role vars (higher precedence)
│   │   │   └── main.yml
│   │   ├── tasks/               # tasks run by the role
│   │   │   └── main.yml
│   │   ├── handlers/            # handlers (service restarts etc.)
│   │   │   └── main.yml
│   │   ├── files/               # static files copied as-is
│   │   ├── templates/           # jinja2 templates
│   │   ├── meta/                # role metadata, dependencies
│   │   │   └── main.yml
│   │   └── tests/               # optional: molecule or simple test playbooks
│   │       └── inventory
│   └── database/
│       ├── defaults/
│       ├── vars/
│       ├── tasks/
│       ├── handlers/
│       └── meta/
├── group_vars/                  # repository-wide group vars (if not per-inventory)
│   └── all.yml
├── host_vars/                   # repository-wide host vars
│   └── server1.yml
├── vault/                       # optional location to keep encrypted files
│   └── secrets.yml               # encrypted with ansible-vault
├── library/                     # custom modules
├── module_utils/                # module shared code
├── filter_plugins/              # custom jinja2 filters
├── callback_plugins/            # custom callbacks
├── lookup_plugins/              # custom lookups
├── playbooks/                   # place for many playbook files (optional)
├── files/                       # global static files
├── templates/                   # global templates
└── README.md
```

> This covers standard parts and optional extension points (plugins, custom modules, etc.).

---

## `ansible.cfg` (example)

```ini
[defaults]
inventory = ./inventories/production/hosts.yml
roles_path = ./roles
library = ./library
forks = 20
host_key_checking = False
retry_files_enabled = False
log_path = ./ansible.log
callback_whitelist = profile_tasks
vault_identity_list = dev@/path/to/vault_pass

[privilege_escalation]
become = True
become_method = sudo

[ssh_connection]
ssh_args = -o ControlMaster=auto -o ControlPersist=60s

# Optional: control behavior when using collections
collections_paths = ./collections
```

---

## Inventories

### INI-format (simple)

`inventories/staging/hosts.ini`

```ini
[webservers]
web1.example.com ansible_user=deploy
web2.example.com ansible_user=deploy

[dbservers]
db1.example.com ansible_user=postgres
```

### YAML-format (supports host_vars inline)

`inventories/production/hosts.yml`

```yaml
all:
  children:
    webservers:
      hosts:
        web1.example.com:
          ansible_user: deploy
        web2.example.com:
          ansible_user: deploy
    dbservers:
      hosts:
        db1.example.com:
          ansible_user: postgres
  vars:
    # variables available to all hosts
    ntp_server: time.example.org
```

### `group_vars` and `host_vars`

`inventories/production/group_vars/all.yml`

```yaml
ansible_python_interpreter: /usr/bin/python3
app_env: production
monitoring_enabled: true
```

`inventories/staging/host_vars/db1.yml`

```yaml
postgresql_version: "13"
postgresql_databases:
  - name: appdb
    owner: appuser
```

---

## site.yml (entry playbook)

```yaml
- name: Apply base config and roles to all hosts
  hosts: all
  become: true
  roles:
    - common

- name: Configure and deploy web tier
  hosts: webservers
  become: true
  roles:
    - role: webserver
      vars:
        webserver_listen_port: 8080

- name: Configure DB servers
  hosts: dbservers
  become: true
  roles:
    - database
```

---

## Role structure and sample files

We'll show a `roles/webserver` example.

```
roles/webserver/
├── defaults/main.yml
├── vars/main.yml
├── tasks/main.yml
├── handlers/main.yml
├── templates/
│   └── vhost.conf.j2
├── files/
│   └── static-content/index.html
├── meta/main.yml
└── README.md
```

### `roles/webserver/defaults/main.yml` (lowest precedence)

```yaml
# defaults for webserver role
webserver_package: nginx
webserver_listen_port: 80
webserver_user: www-data
webroot: /var/www/html
```

### `roles/webserver/vars/main.yml` (higher precedence than defaults)

```yaml
# role-specific variables that usually shouldn't be overridden by playbooks
webserver_config_file: /etc/nginx/sites-available/app.conf
```

### `roles/webserver/tasks/main.yml`

```yaml
---
- name: Ensure webserver package is installed
  package:
    name: "{{ webserver_package }}"
    state: present

- name: Create webroot directory
  file:
    path: "{{ webroot }}"
    state: directory
    owner: "{{ webserver_user }}"
    mode: "0755"

- name: Deploy site template
  template:
    src: vhost.conf.j2
    dest: "{{ webserver_config_file }}"
  notify: Reload webserver

- name: Deploy static content
  copy:
    src: static-content/index.html
    dest: "{{ webroot }}/index.html"
    owner: "{{ webserver_user }}"
    mode: "0644"

- name: Ensure service is enabled and started
  service:
    name: "{{ webserver_package }}"
    state: started
    enabled: true
```

### `roles/webserver/handlers/main.yml`

```yaml
---
- name: Reload webserver
  service:
    name: "{{ webserver_package }}"
    state: reloaded
```

### `roles/webserver/templates/vhost.conf.j2`

```jinja
server {
    listen {{ webserver_listen_port }};
    server_name {{ ansible_fqdn | default(inventory_hostname) }};

    root {{ webroot }};

    location / {
        try_files $uri $uri/ =404;
    }
}
```

### `roles/webserver/meta/main.yml` (role metadata)

```yaml
---
role_name: webserver
galaxy_info:
  author: YourName
  description: "Installs and configures nginx for our app"
  license: MIT
  min_ansible_version: 2.9
  platforms:
    - name: Ubuntu
      versions:
        - bionic
        - focal
dependencies:
  - role: common
```

---

## Database role example (PostgreSQL & MySQL support sketch)

`roles/database/tasks/main.yml`

```yaml
---
- name: Install DB server package
  package:
    name: "{{ db_package }}"
    state: present

- name: Ensure DB service is running
  service:
    name: "{{ db_service }}"
    state: started
    enabled: true

- name: Create application database (Postgres)
  community.postgresql.postgresql_db:
    name: "{{ app_db_name }}"
    state: present
  when: db_type == 'postgresql'

- name: Create application database (MySQL)
  community.mysql.mysql_db:
    name: "{{ app_db_name }}"
    state: present
  when: db_type == 'mysql'
```

`roles/database/defaults/main.yml`

```yaml
# defaults for database role
db_type: postgresql # or 'mysql'
postgresql_version: "13"
mysql_version: "8"
app_db_name: appdb
```

> Note: To use `community.*` modules you typically need the corresponding collection installed (via `ansible-galaxy collection install community.postgresql`), which can be declared in `requirements.yml`.

---

## `requirements.yml` (roles & collections)

```yaml
roles:
  - name: geerlingguy.redis
    src: geerlingguy.redis
    version: 3.0.0

collections:
  - name: community.mysql
  - name: community.postgresql
```

Install with:

```bash
ansible-galaxy install -r requirements.yml --roles-path roles
ansible-galaxy collection install -r requirements.yml --collections-path collections
```

---

## Vault (secrets)

Create an encrypted file with:

```bash
ansible-vault create vault/secrets.yml
# or edit
ansible-vault edit vault/secrets.yml
```

Example encrypted file content (plaintext shown then you encrypt):

`vault/secrets.yml` (plaintext before encrypt)

```yaml
db_password: S3cretPassw0rd
api_key: "abcd-1234-efgh-5678"
```

Use in a playbook:

```yaml
- hosts: dbservers
  vars_files:
    - vault/secrets.yml
  tasks:
    - name: Create DB user with vault password
      community.postgresql.postgresql_user:
        name: appuser
        password: "{{ db_password }}"
        state: present
```

You can also encrypt a single variable inline with `ansible-vault encrypt_string 's3cr3t' --name 'api_key'` and copy the resulting encrypted blob into source control.

---

## Handlers — best practices

- Handlers should be idempotent and named clearly (e.g., `Restart nginx`, `Reload systemd daemon`).
- Tasks should `notify` handlers when they change state.

Example handler and usage already shown in the webserver role.

---

## Common extras & advanced files/directories

- `library/` — custom modules (Python files). Example: `library/my_company_module.py`.
- `module_utils/` — helper utilities shared across custom modules.
- `filter_plugins/` — custom jinja2 filters (Python). Example: `filter_plugins/my_filters.py`.
- `lookup_plugins/` — custom lookup behavior.
- `callback_plugins/` — custom callbacks, e.g., to change logging or output.
- `tests/` or `molecule/` — testing; `molecule/` scenarios for roles.
- `collections/` — vendored collections if you prefer to store them in repo.
- `docs/` — role/playbook documentation.

---

## Example: small end-to-end playbook set (files shown)

**site.yml** (already shown) calls roles.

**webservers.yml**

```yaml
- name: Deploy app to webservers
  hosts: webservers
  become: true
  roles:
    - role: webserver
      vars:
        webserver_listen_port: 8080
```

**databases.yml**

```yaml
- name: Setup databases
  hosts: dbservers
  become: true
  roles:
    - database
```

---

## Example inventory including host-specific variables

`inventories/production/hosts.yml` (expanded example)

```yaml
all:
  children:
    webservers:
      hosts:
        web1.example.com:
          ansible_user: deploy
          app_env: production
          host_contact: ops@example.com
        web2.example.com:
          ansible_user: deploy
    dbservers:
      hosts:
        db1.example.com:
          ansible_user: postgres
          postgresql_version: "13"
          db_role: primary
        db2.example.com:
          ansible_user: postgres
          db_role: replica
```

---

## Other useful patterns and tips

- **Role defaults vs vars** — `defaults/main.yml` is intended for values users can easily override; `vars/main.yml` is higher precedence and should be used sparingly.
- **Encrypt only secrets** — keep non-secret template/config under source control and encrypt only secret files in `vault/`.
- **Modular playbooks** — split by environment or component: `site.yml` -> includes `webservers.yml`, `databases.yml`.
- **Use `ansible-lint` and `yamllint`** to keep playbooks clean.
- **Test roles with Molecule** for multiple platforms.
- **Use collections** to pick up community modules (e.g., `community.postgresql` and `community.mysql`).

---

## Minimal set of sample files (copy-ready) — quick reference

- `ansible.cfg` — see earlier
- `inventories/production/hosts.yml` — see earlier
- `group_vars/all.yml` — see earlier
- `roles/webserver/tasks/main.yml` — see earlier
- `roles/webserver/handlers/main.yml` — see earlier
- `roles/database/tasks/main.yml` — see earlier
- `site.yml` — see earlier
- `vault/secrets.yml` — see earlier
- `requirements.yml` — see earlier
