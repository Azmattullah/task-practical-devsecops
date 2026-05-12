Use this prompt with Anthropic Claude, OpenAI ChatGPT, or any coding agent like Cursor/Cline/Windsurf to generate the complete solution.

You are a Senior DevOps Engineer.

Build a complete production-style but minimal-complexity solution for the following technical challenge.

The implementation must be simple, clean, beginner-friendly, and avoid unnecessary enterprise overengineering.

---

## TECHNICAL CHALLENGE

1. Set up and secure Docker host machines using Infrastructure as Code (IaC).

2. Docker hosts must be accessible securely from Docker clients using TLS security.

3. Configure multiple Docker hosts (`Node A` and `Node B`) so containers can communicate across hosts using Docker Overlay Networking.

4. Implement service discovery using Consul so containers can communicate using DNS names like:

   nginx.service.consul

5. Demonstrate that a container running on Node A can communicate with a container running on Node B.

6. Follow security best practices during implementation.

---

## IMPORTANT IMPLEMENTATION REQUIREMENTS

Keep the implementation SIMPLE.

Avoid:

* Kubernetes
* Helm
* Complex microservice architecture
* CI/CD pipelines
* Overly modular Terraform
* Overly complicated Ansible roles
* Multiple Terraform modules
* Vault
* Service mesh
* External DNS
* Cloud load balancers

Use only:

* Terraform
* Ansible
* Docker Swarm
* Docker Overlay Network
* Consul

The goal is:

* simplicity
* readability
* reproducibility
* security
* demonstration of core DevOps knowledge

---

## EXPECTED PROJECT STRUCTURE

terraform/
├── main.tf
├── variables.tf
├── outputs.tf

ansible/
├── inventory.ini
├── docker-install.yml
├── consul.yml
├── swarm.yml
├── security.yml

docker-stack.yml

README.md

Keep the structure minimal and clean.

---

## INFRASTRUCTURE REQUIREMENTS

Use Terraform to provision:

* Node A VM
* Node B VM

Infrastructure can target:

* AWS EC2
  OR
* GCP Compute Engine

Choose the simplest implementation.

Each node should have:

* Ubuntu 22.04
* Docker Engine
* Docker Swarm enabled
* Private networking between nodes

Terraform should:

* provision VMs
* create firewall/security rules
* expose only necessary ports
* output public IPs

---

## SECURITY REQUIREMENTS

Implement the following:

1. Docker Remote API over TLS

   * Enable Docker daemon TLS
   * Use port 2376
   * Disable insecure Docker API

2. SSH hardening

   * Disable password authentication
   * Use SSH key authentication only

3. Firewall rules
   Allow only:

   * SSH (22)
   * Docker Swarm ports
   * Consul ports
   * Overlay networking ports

4. Docker security

   * Use non-privileged containers
   * Avoid privileged mode
   * Use lightweight images like alpine/nginx

5. Internal networking

   * Keep Consul internal-only
   * Keep overlay traffic internal-only

---

## DOCKER SWARM REQUIREMENTS

Initialize Docker Swarm.

* Node A should act as manager
* Node B should join as worker

Create overlay network:

app-network

Example:

docker network create 
--driver overlay 
app-network

---

## CONSUL REQUIREMENTS

Deploy Consul using Docker containers.

Requirements:

* Consul server on Node A
* Consul agent on Node B
* Enable DNS-based service discovery

Containers should resolve:

nginx.service.consul

Use:

* Registrator
  OR
* manual service registration

Choose the simpler implementation.

---

## DEMO APPLICATION REQUIREMENTS

Deploy:

1. nginx container on Node A
2. alpine/curl test container on Node B

Both must join:

* app-network

Demonstrate:

From Node B:

curl [http://nginx.service.consul](http://nginx.service.consul)

Expected output:

* nginx welcome page

---

## ANSIBLE REQUIREMENTS

Use Ansible to:

* install Docker
* configure Docker daemon TLS
* install Consul
* initialize Swarm
* join worker node
* apply security configuration

Keep playbooks simple and readable.

Avoid:

* advanced roles
* galaxy dependencies
* excessive templating

---

## README REQUIREMENTS

Generate a complete README.md containing:

1. Architecture overview
2. Project structure
3. Prerequisites
4. Terraform deployment steps
5. Ansible execution steps
6. Docker Swarm setup explanation
7. Consul explanation
8. Security implementation details
9. Overlay networking explanation
10. Verification commands
11. Cleanup steps
12. Screenshots section placeholders

README should be:

* beginner friendly
* step-by-step
* production-style
* easy to follow

---

## OUTPUT REQUIREMENTS

Generate complete working code for:

* Terraform files
* Ansible playbooks
* Docker stack file
* Consul configuration
* Docker daemon TLS configuration
* Inventory files
* README.md

Also explain:

* why each component is used
* how overlay networking works
* how Consul DNS works
* how security is implemented

Keep everything concise, clean, and practical.

Do NOT overengineer the solution.
