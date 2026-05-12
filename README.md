# Practical DevSecOps: Secure Docker Swarm & Consul Infrastructure

This project demonstrates a production-style but minimal-complexity DevOps deployment. It provisions secure infrastructure on Google Cloud Platform (GCP) using Terraform, configures the nodes securely using Ansible, clusters them with Docker Swarm, and provides DNS-based service discovery using Consul.

## 1. Architecture Overview

- **Cloud Provider**: Google Cloud Platform (GCP)
- **Infrastructure**: Two Ubuntu 22.04 VMs (Node A as Manager, Node B as Worker).
- **Networking**: VPC with strict firewall rules, internal Docker Swarm overlay network (`app-network`).
- **Security**: SSH Key-only authentication, UFW Host Firewalls, Docker Daemon secured over TLS.
- **Service Discovery**: Consul cluster (Server on Node A, Agent on Node B) with manual service registration configured for the Nginx application.
- **Demo Application**: Nginx running on Node A, communicating over the overlay network with an Alpine curl client running on Node B.

## 2. Project Structure

```
.
├── terraform/
│   ├── main.tf          # GCP Infrastructure definition
│   ├── variables.tf     # Configurable variables
│   └── outputs.tf       # IP outputs
├── ansible/
│   ├── inventory.ini    # Hosts inventory template
│   ├── security.yml     # SSH hardening and UFW firewall rules
│   ├── docker-install.yml # Docker installation and TLS setup
│   ├── swarm.yml        # Docker Swarm initialization and joining
│   └── consul.yml       # Consul service discovery deployment
├── docker-stack.yml     # Demo application stack definition
└── README.md            # This documentation file
```

## 3. Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/downloads) installed locally.
- [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html) installed locally.
- GCP Account and `gcloud` CLI configured and authenticated.
- A valid SSH key pair for VM access (`~/.ssh/id_rsa`).

## 4. Terraform Deployment Steps

Navigate to the `terraform` directory and provision the infrastructure:

```bash
cd terraform
terraform init

# Deploy the infrastructure (replace your-gcp-project-id with your actual project ID)
terraform apply -var="project_id=your-gcp-project-id"
```

Note the `node_a_public_ip` and `node_b_public_ip` values output by Terraform.

## 5. Ansible Execution Steps

1. **Configure Inventory**: Open `ansible/inventory.ini` and replace `<NODE_A_PUBLIC_IP>` and `<NODE_B_PUBLIC_IP>` with the outputs from Terraform.
2. **Apply Security Hardening**:
   ```bash
   ansible-playbook -i ansible/inventory.ini ansible/security.yml
   ```
3. **Install Docker and Configure TLS**:
   ```bash
   ansible-playbook -i ansible/inventory.ini ansible/docker-install.yml
   ```
4. **Initialize Docker Swarm**:
   ```bash
   ansible-playbook -i ansible/inventory.ini ansible/swarm.yml
   ```
5. **Deploy Consul Service Discovery**:
   ```bash
   ansible-playbook -i ansible/inventory.ini ansible/consul.yml
   ```

## 6. Docker Swarm Setup Explanation

Docker Swarm clusters the two nodes together. `ansible/swarm.yml` initializes Swarm on Node A, extracting its unique worker join token, and executing it on Node B. This creates a unified orchestration platform. Node A acts as the manager (handling state and stack deployments), while Node B acts as a worker (executing container workloads).

## 7. Consul Explanation

Consul provides distributed, highly available DNS and service discovery. 
- **Node A** runs the Consul Server container (acting as the cluster leader).
- **Node B** runs the Consul Agent container (forwarding queries to the server).
- The Nginx service is statically registered on the Manager node via a volume-mounted JSON configuration, exposing its port to the Consul catalog.
- We expose Consul's DNS interface directly on port `53` to the host's internal IP. Docker daemon is configured to use this IP for DNS resolution, seamlessly granting all containers access to `.consul` addresses.

## 8. Security Implementation Details

Security is implemented at multiple layers:
- **Cloud Firewall**: GCP Firewall blocks all external traffic except SSH (22) and Docker TLS (2376). Swarm and Consul traffic is strictly confined to the internal `10.0.1.0/24` VPC subnet.
- **Host Hardening**: Ansible disables SSH password authentication, disables root login, and configures `ufw` to mirror the strict cloud firewall rules (Defense-in-Depth).
- **Docker TLS**: Standard unencrypted Docker sockets are disabled. Docker API is exposed remotely *only* over mutually authenticated TLS using freshly generated certificates on port 2376.

## 9. Overlay Networking Explanation

Docker Overlay networks (`app-network`) span across multiple Swarm hosts. A container on Node A gets a virtual IP (e.g., `10.0.X.X`). A container on Node B gets an IP in the same subnet. Docker handles VXLAN encapsulation natively under the hood, allowing Node A and Node B containers to communicate as if they were on the exact same physical switch, completely isolated from the host network.

## 10. Verification Commands

Once all Ansible playbooks have run successfully, deploy the application stack. SSH into Node A (Manager) to deploy it locally:

```bash
ssh ubuntu@<NODE_A_PUBLIC_IP>
# Inside Node A
docker stack deploy -c docker-stack.yml demo
```

**Verify Service Discovery & Overlay Networking:**
SSH into Node B and jump into the `test-client` container to curl the Nginx service:

```bash
ssh ubuntu@<NODE_B_PUBLIC_IP>
# Inside Node B
TEST_CONTAINER=$(docker ps -q -f name=demo_test-client)
docker exec -it $TEST_CONTAINER curl http://nginx.service.consul
```
**Expected Output:** You should see the standard "Welcome to nginx!" HTML page. This proves that Consul successfully resolved `nginx.service.consul` to the Nginx container's IP on Node A, and that traffic successfully routed across the `app-network` overlay network.

## 11. Cleanup Steps

To tear down the infrastructure and avoid incurring cloud charges:

```bash
cd terraform
terraform destroy -var="project_id=your-gcp-project-id"
```

## 12. Screenshots

*(Replace these placeholders with actual screenshots during testing)*

- `[Screenshot: Terraform Apply Output]`
- `[Screenshot: Ansible Playbook Success Logs]`
- `[Screenshot: docker node ls showing Manager and Worker]`
- `[Screenshot: curl http://nginx.service.consul Success Output]`
