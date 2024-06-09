### Ansible Facts

**Ansible facts** are pieces of information about the remote system that Ansible gathers when it connects to the system. These facts are collected by the `setup` module and include details such as IP addresses, operating system, memory, and more. Facts are useful for making decisions in your playbooks based on the state of the remote system.

#### Example of Gathering Facts

By default, facts are gathered automatically at the beginning of a playbook run. You can access these facts using the `ansible_facts` variable.

```yaml
- name: Gather facts example
  hosts: all
  tasks:
    - name: Print the operating system
      debug:
        msg: "The operating system is {{ ansible_facts['os_family'] }}"
```

You can also disable fact gathering if you don't need it:

```yaml
- name: Playbook without fact gathering
  hosts: all
  gather_facts: no
  tasks:
    - name: Print a message
      debug:
        msg: "Facts gathering is disabled"
```

### Ansible Tags

**Ansible tags** allow you to run specific parts of your playbook. This is useful for running only a subset of tasks without executing the entire playbook, which can save time and resources.

#### Example of Using Tags

You can assign tags to tasks and then run the playbook with specific tags.

```yaml
- name: Playbook with tags
  hosts: all
  tasks:
    - name: Install a package
      apt:
        name: nginx
        state: present
      tags: install

    - name: Start the service
      service:
        name: nginx
        state: started
      tags: start

    - name: Print a message
      debug:
        msg: "Nginx is installed and started"
      tags: info
```

To run only the tasks with the `install` tag:

```sh
ansible-playbook playbook.yml --tags install
```

To skip tasks with the `info` tag:

```sh
ansible-playbook playbook.yml --skip-tags info
```

### Ansible Handlers

**Ansible handlers** are special tasks that are triggered by other tasks using the `notify` directive. Handlers are typically used for actions that should only occur when there is a change, such as restarting a service after a configuration file has been modified.

#### Example of Using Handlers

```yaml
- name: Playbook with handlers
  hosts: all
  tasks:
    - name: Install nginx
      apt:
        name: nginx
        state: present
      notify: Restart nginx

    - name: Copy nginx configuration
      copy:
        src: nginx.conf
        dest: /etc/nginx/nginx.conf
      notify: Restart nginx

  handlers:
    - name: Restart nginx
      service:
        name: nginx
        state: restarted
```

In this example, the `Restart nginx` handler will only be triggered if either the `Install nginx` or `Copy nginx configuration` task makes a change.

### Summary

- **Facts**: Automatically gathered information about remote systems, accessible via `ansible_facts`.
- **Tags**: Allow you to run specific tasks or skip them, useful for partial playbook execution.
- **Handlers**: Special tasks triggered by the `notify` directive, typically used for actions that should occur only when changes are made.

These concepts help you write more efficient, flexible, and maintainable Ansible playbooks.

Certainly! Ansible is a powerful automation tool used for configuration management, application deployment, and task automation. While basic Ansible usage involves writing simple playbooks and roles, there are several advanced topics that can help you leverage the full power of Ansible. Here are some complex Ansible topics:

### 1. **Ansible Vault**

Ansible Vault allows you to encrypt sensitive data such as passwords or keys within Ansible projects. This ensures that sensitive information is not exposed in plain text.

```bash
# Encrypt a file
ansible-vault encrypt secrets.yml

# Decrypt a file
ansible-vault decrypt secrets.yml

# Edit an encrypted file
ansible-vault edit secrets.yml

# Use the vault in a playbook
ansible-playbook playbook.yml --ask-vault-pass
```

### 2. **Dynamic Inventory**

Dynamic inventory allows Ansible to query external data sources to obtain the list of hosts and groups. This is useful for environments where the infrastructure is dynamic, such as cloud environments.

```python
# Example of a dynamic inventory script (dynamic_inventory.py)
import json

def main():
    inventory = {
        "all": {
            "hosts": ["host1", "host2"],
            "vars": {
                "ansible_user": "admin"
            }
        }
    }
    print(json.dumps(inventory))

if __name__ == "__main__":
    main()
```

```ini
# ansible.cfg
[defaults]
inventory = ./dynamic_inventory.py
```

### 3. **Custom Modules**

Ansible allows you to write custom modules in Python or any other language. Custom modules can be used to extend Ansible's functionality.

```python
# Example of a custom Ansible module (my_module.py)
from ansible.module_utils.basic import AnsibleModule

def run_module():
    module_args = dict(
        name=dict(type='str', required=True)
    )

    module = AnsibleModule(
        argument_spec=module_args,
        supports_check_mode=True
    )

    result = dict(
        changed=False,
        original_message='',
        message=''
    )

    name = module.params['name']
    result['original_message'] = name
    result['message'] = f'Hello, {name}!'

    module.exit_json(**result)

def main():
    run_module()

if __name__ == '__main__':
    main()
```

### 4. **Ansible Galaxy**

Ansible Galaxy is a repository for Ansible roles. You can use it to share roles with the community or download roles created by others.

```bash
# Install a role from Ansible Galaxy
ansible-galaxy install username.role_name

# Create a new role
ansible-galaxy init my_role
```

### 5. **Jinja2 Templates**

Jinja2 is a templating engine used by Ansible to generate files dynamically. You can use Jinja2 templates to create configuration files based on variables.

```yaml
# Example of a Jinja2 template (template.j2)
server {
listen 80;
server_name {{ server_name }};
location / {
proxy_pass http://{{ backend }};
}
}
```

```yaml
# Example of a playbook using a Jinja2 template
- name: Deploy Nginx configuration
  hosts: webservers
  vars:
    server_name: example.com
    backend: 127.0.0.1:8080
  tasks:
    - name: Template Nginx config
      template:
        src: template.j2
        dest: /etc/nginx/sites-available/default
```

### 6. **Ansible Tower / AWX**

Ansible Tower (commercial) and AWX (open-source) provide a web-based interface for managing Ansible playbooks, inventories, and schedules. They offer features like role-based access control, job scheduling, and real-time job status updates.

### 7. **Callbacks and Plugins**

Ansible supports custom callbacks and plugins to extend its functionality. Callbacks can be used to trigger actions based on playbook events, while plugins can extend core Ansible features.

```python
# Example of a custom callback plugin (callback_plugins/my_callback.py)
from ansible.plugins.callback import CallbackBase

class CallbackModule(CallbackBase):
    def v2_runner_on_ok(self, result):
        host = result._host
        print(f"Task succeeded on {host.name}")
```

### 8. **Error Handling and Debugging**

Advanced error handling and debugging techniques can help you manage complex playbooks. This includes using `ignore_errors`, `failed_when`, and `debug` tasks.

```yaml
# Example of error handling in a playbook
- name: Example playbook
  hosts: all
  tasks:
    - name: This task might fail
      command: /bin/false
      ignore_errors: yes

    - name: Conditional failure
      command: /bin/true
      failed_when: "'some_condition' in result.stdout"

    - name: Debugging output
      debug:
        msg: "The value of my_var is {{ my_var }}"
```

### 9. **Ansible Collections**

Ansible Collections are a distribution format for Ansible content that can include playbooks, roles, modules, and plugins. Collections make it easier to share and reuse Ansible content.

```bash
# Install a collection
ansible-galaxy collection install community.general

# Use a collection in a playbook
- name: Example playbook using a collection
  hosts: localhost
  tasks:
    - name: Use a module from the collection
      community.general.some_module:
        param: value
```

### 10. **Ansible Testing with Molecule**

Molecule is a testing framework for Ansible roles. It allows you to test roles in different environments and scenarios.

```bash
# Initialize a new Molecule scenario
molecule init scenario --scenario-name default -r my_role

# Run tests
molecule test
```

### 11. **Ansible and CI/CD Integration**

Integrating Ansible with CI/CD pipelines (e.g., Jenkins, GitLab CI) can automate the deployment process. This involves running Ansible playbooks as part of the CI/CD pipeline.

```yaml
# Example of a GitLab CI pipeline
stages:
  - deploy

deploy:
  stage: deploy
  script:
    - ansible-playbook -i inventory playbook.yml
```

### 12. **Ansible and Kubernetes**

Ansible can be used to manage Kubernetes resources. The `k8s` module allows you to interact with Kubernetes clusters.

```yaml
# Example of managing Kubernetes resources with Ansible
- name: Deploy to Kubernetes
  hosts: localhost
  tasks:
    - name: Create a Kubernetes namespace
      k8s:
        api_version: v1
        kind: Namespace
        name: my-namespace

    - name: Deploy a pod
      k8s:
        state: present
        definition:
          apiVersion: v1
          kind: Pod
          metadata:
            name: my-pod
            namespace: my-namespace
          spec:
            containers:
              - name: my-container
                image: nginx
```

These are just a few of the advanced topics in Ansible. Mastering these concepts can significantly enhance your ability to automate complex tasks and manage large-scale infrastructure efficiently.

Certainly! Here are some additional advanced Ansible topics that can help you further enhance your automation capabilities:

### 13. **Ansible Roles and Best Practices**

Ansible roles are a way to organize playbooks and other files in a standardized file structure. This makes it easier to reuse and share Ansible code. Best practices include:

- **Directory Structure**: Follow the standard directory structure for roles.
- **Modularity**: Break down tasks into smaller, reusable roles.
- **Documentation**: Include README files and document variables and usage.
- **Testing**: Use Molecule to test roles.

```bash
# Create a new role
ansible-galaxy init my_role
```

### 14. **Ansible Network Automation**

Ansible can be used to automate network devices. The `network_cli` connection type and various network modules allow you to manage network configurations.

```yaml
- name: Configure network devices
  hosts: switches
  connection: network_cli
  tasks:
    - name: Configure interface
      ios_config:
        lines:
          - description Configured by Ansible
          - ip address 192.168.1.1 255.255.255.0
        parents: interface GigabitEthernet0/1
```

### 15. **Ansible and Cloud Automation**

Ansible can manage cloud resources across various providers like AWS, Azure, and Google Cloud. Modules for each provider allow you to create, manage, and destroy cloud resources.

```yaml
- name: Create an EC2 instance
  hosts: localhost
  tasks:
    - name: Launch instance
      ec2:
        key_name: my_key
        instance_type: t2.micro
        image: ami-123456
        wait: yes
```

### 16. **Ansible and Docker**

Ansible can manage Docker containers and images. The `docker_container` and `docker_image` modules allow you to automate Docker operations.

```yaml
- name: Manage Docker containers
  hosts: localhost
  tasks:
    - name: Pull a Docker image
      docker_image:
        name: nginx
        source: pull

    - name: Run a Docker container
      docker_container:
        name: my_nginx
        image: nginx
        state: started
```

### 17. **Ansible and Windows Automation**

Ansible can manage Windows hosts using the `winrm` connection type and various Windows-specific modules.

```yaml
- name: Manage Windows hosts
  hosts: windows
  tasks:
    - name: Install IIS
      win_feature:
        name: Web-Server
        state: present
```

### 18. **Ansible and Security Automation**

Ansible can be used to automate security tasks such as patch management, compliance checks, and vulnerability scanning.

```yaml
- name: Apply security patches
  hosts: all
  tasks:
    - name: Update all packages
      yum:
        name: "*"
        state: latest
```

### 19. **Ansible and Service Mesh**

Ansible can be used to manage service mesh configurations, such as Istio or Linkerd, by deploying and configuring the necessary components.

```yaml
- name: Deploy Istio
  hosts: localhost
  tasks:
    - name: Apply Istio manifests
      k8s:
        state: present
        src: istio-manifests.yaml
```

### 20. **Ansible and CI/CD Pipelines**

Integrating Ansible with CI/CD pipelines can automate the deployment process. This involves running Ansible playbooks as part of the CI/CD pipeline.

```yaml
# Example of a Jenkins pipeline
pipeline {
agent any
stages {
stage('Deploy') {
steps {
sh 'ansible-playbook -i inventory playbook.yml'
}
}
}
}
```

### 21. **Ansible and Event-Driven Automation**

Event-driven automation involves triggering Ansible playbooks based on events from monitoring systems, webhooks, or other sources.

```yaml
# Example of an event-driven automation using a webhook
- name: Trigger playbook on webhook event
  hosts: localhost
  tasks:
    - name: Wait for webhook
      uri:
        url: http://webhook.url
        method: POST
        body: '{"event": "deploy"}'
        status_code: 200
```

### 22. **Ansible and API Integration**

Ansible can interact with REST APIs using the `uri` module, allowing you to automate tasks that involve external services.

```yaml
- name: Interact with REST API
  hosts: localhost
  tasks:
    - name: Get data from API
      uri:
        url: https://api.example.com/data
        method: GET
        return_content: yes
      register: api_response

    - name: Print API response
      debug:
        msg: "{{ api_response.content }}"
```

### 23. **Ansible and Configuration Management Databases (CMDB)**

Ansible can integrate with CMDBs to dynamically obtain configuration data and manage infrastructure.

```yaml
- name: Fetch data from CMDB
  hosts: localhost
  tasks:
    - name: Query CMDB
      uri:
        url: https://cmdb.example.com/api/hosts
        method: GET
        return_content: yes
      register: cmdb_response

    - name: Use CMDB data
      debug:
        msg: "{{ cmdb_response.content }}"
```

### 24. **Ansible and ChatOps**

ChatOps involves integrating Ansible with chat platforms like Slack or Microsoft Teams to trigger playbooks and receive notifications.

```yaml
- name: Send notification to Slack
  hosts: localhost
  tasks:
    - name: Notify Slack
      slack:
        token: xoxb-1234567890
        msg: "Deployment completed successfully"
        channel: "#deployments"
```

### 25. **Ansible and Serverless Computing**

Ansible can manage serverless functions and services, such as AWS Lambda, using the appropriate modules.

```yaml
- name: Deploy AWS Lambda function
  hosts: localhost
  tasks:
    - name: Create Lambda function
      lambda:
        name: my_lambda_function
        state: present
        runtime: python3.8
        handler: lambda_function.lambda_handler
        code: s3://my-bucket/my-function.zip
```

### 26. **Ansible and Infrastructure as Code (IaC)**

Ansible can be used alongside other IaC tools like Terraform to manage infrastructure. Ansible can handle configuration management while Terraform manages resource provisioning.

```yaml
# Example of using Terraform with Ansible
- name: Apply Terraform configuration
  hosts: localhost
  tasks:
    - name: Run Terraform
      command: terraform apply -auto-approve
```

### 27. **Ansible and Immutable Infrastructure**

Immutable infrastructure involves creating and deploying new instances rather than updating existing ones. Ansible can automate the creation and deployment of immutable infrastructure.

```yaml
- name: Deploy immutable infrastructure
  hosts: localhost
  tasks:
    - name: Create new instance
      ec2:
        key_name: my_key
        instance_type: t2.micro
        image: ami-123456
        wait: yes

    - name: Terminate old instance
      ec2:
        instance_ids: i-1234567890abcdef0
        state: absent
```

### 28. **Ansible and Blue-Green Deployments**

Blue-green deployments involve running two identical production environments (blue and green) and switching traffic between them. Ansible can automate the process of switching traffic and updating environments.

```yaml
- name: Blue-green deployment
  hosts: localhost
  tasks:
    - name: Deploy to green environment
      k8s:
        state: present
        definition:
          apiVersion: apps/v1
          kind: Deployment
          metadata:
            name: my-app-green
            namespace: my-namespace
          spec:
            replicas: 3
            template:
              metadata:
                labels:
                  app: my-app
                  version: green
              spec:
                containers:
                  - name: my-container
                    image: my-app:green

    - name: Switch traffic to green environment
      k8s:
        state: present
        definition:
          apiVersion: v1
          kind: Service
          metadata:
            name: my-app
            namespace: my-namespace
          spec:
            selector:
              app: my-app
              version: green
```

### 29. **Ansible and Canary Deployments**

Canary deployments involve gradually rolling out changes to a small subset of users before deploying to the entire infrastructure. Ansible can automate the process of deploying and monitoring canary releases.

```yaml
- name: Canary deployment
  hosts: localhost
  tasks:
    - name: Deploy canary release
      k8s:
        state: present
        definition:
          apiVersion: apps/v1
          kind: Deployment
          metadata:
            name: my-app-canary
            namespace: my-namespace
          spec:
            replicas: 1
            template:
              metadata:
                labels:
                  app: my-app
                  version: canary
              spec:
                containers:
                  - name: my-container
                    image: my-app:canary

    - name: Monitor canary release
      uri:
        url: http://my-app-canary.example.com/health
        method: GET
        status_code: 200
```

### 30. **Ansible and Chaos Engineering**

Chaos engineering involves intentionally introducing failures to test the resilience of systems. Ansible can automate chaos experiments to ensure systems can handle unexpected disruptions.

```yaml
- name: Chaos engineering experiment
  hosts: localhost
  tasks:
    - name: Terminate random instance
      ec2:
        instance_ids: "{{ lookup('aws_ec2', 'tag:Environment=production', region='us-west-2') | random }}"
        state: absent
```

These advanced topics can help you leverage Ansible to its full potential, enabling you to automate complex tasks, manage large-scale infrastructure, and ensure the reliability and security of your systems.
