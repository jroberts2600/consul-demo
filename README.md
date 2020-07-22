# Consul Demo

This repo can be used to show Consul service discovery, Consul Connect, intentions and service failover between datacenters (via prepared query)

## Overview

### Demo Variants

- Single Region - located in `terraform/single-region-demo`
  - demonstrates: service discovery, Consul Connect, and intentions
- Multi Region - located in `terraform/multi-region-demo`
  - demonstrates: service discovery, Consul Connect, intentions and service failover between datacenters using a prepared query

### Branches

- `main` - primary branch - Terraform 0.12.x compatible code
- `terraform-0.11` - Terraform 0.11 compatible code - for use with TFC/TFE
  - requires setting TFC/TFE workspace to use Terraform 0.11.14

### Architecture & Diagrams

- [Simple Three Tier Architecture](./diagrams/1-High-Level-Architecture-sm.png)
  - Front tier: `web_client` service
  - Middle tier: two services `listing` and `product`
  - Back tier: `MongoDB` service
- [Resources Deployed in each Region](./diagrams/2-Deployed-Services-sm.png)
- [Consul Configuration Single DC](./diagrams/3-Consul-Config-Single-DC-sm.png)
  - Front Tier to the Middle Tier communicates using Consul Service Mesh
  - Middle Tier to Back Tier Communicates via Service Discovery only
    - Demo begins with Service Discovery by showing connections between Middle & Back Tier
    - Note: Intentions have no effect on the Back Tier, it's not using Consul Service Mesh
- [Multi Region Configuration](./diagrams/4-Consul-Config-Multi-DC-sm.png)

> A PowerPoint version and larger versions of these diagrams is included in the `./diagrams` directory

### Requirements

- AWS account & credentials
- AWS Route53 Hosted Zone ID
  - Terraform creates FQDNs for instances & load balancers
- Consul Enterprise License (Highly Recommended)
  - If not specified - Consul Enterprise demo-binary will shutdown in 30m
  - After no-license shutdown
    - demo will no longer work and `terraform destroy` will fail
    - fix by rebooting each host (or restart consul service on each host)
      - this re-starts Consul as Open Source Consul

### AWS AMIs

- AWS AMIs are **publicly** available in `us-east-1`, `us-east-2`, `us-west-1` and `us-west-2`
- To customize AMIs view the [Packer README](./packer/README.md)

## First Time Setup

### Deploying with Terraform CLI

- switch to the directory for the desired demo variant
  - for single region: `cd terraform/single-region-demo`
  - for multi-region: `cd terraform/multi-region-demo`
- Make a copy of the example variables file
  - `cp terraform.auto.tfvars.example terraform.auto.tfvars`
- Edit `terraform.auto.tfvars` and set values as described in comments

### Setup Terraform Cloud/Enterprise Workspaces

- Fork this repo
- Make a copy of the script [reference/setup-tfe-example.sh](.reference/setup-tfe-example.sh) and name it `setup-tfe.sh`
  - populate Variables in script
    - configure TFC/TFE organization
    - specify your repo and `demo` as branch
    - specify workspaces names for `single-region-demo` and `multi-region-demo`
      - script sets working directory for each workspace
    - configure other variables - see `terraform.auto.tfvars.example` for descriptions
- Run `setup-tfe.sh` to create TFC/TFE workspaces with VCS connections and populated variables

### Multi-Region Demo Notes

> The multi-region terraform code uses a post provisioner which requires specifying the AWS ssh keyname & the ssh private key itself (via file reference or as a string).  This process is simplified if you push your system's default ssh key (~/.ssh/id_rsa.pub) to the AWS regions used with this demo.

- (OPTIONAL) use script [reference/push-ssh-key-to-aws.sh](./reference/push-ssh-key-to-aws.sh) to push local SSH key to every AWS region using AWS CLI
  - edit script and set value of `aws_keypair_name` and `publickeyfile`
- Set Terraform variables (in `terraform.auto.tfvars` or `setup-tfe.sh`)
  - `ssh_key_name` - must exist in both AWS regions (default: us-west-2 & us-east-1)
  - Specify either `ssh_pri_key_data` or `ssh_pri_key_file` that refers to private SSH key referenced by `ssh_key_name`
    - `ssh_pri_key_file` - file path to the private key (does not work with TFC/TFE)
    - `ssh_pri_key_data` - contents of private key as data with newlines replaced with `\n` (required for TFC/TFE)
      - remove newlines with command: `awk '{printf "%s\\n", $0}' ~/.ssh/id_rsa`

## Demo Script

### Preparation

- Deploy with Terraform (takes 3-4 minutes)
- (OPTIONAL) add aliases from Terraform output `working_aliases` to .bash_profile
  - eliminates need to remove keys from known_hosts before each demo
- (OPTIONAL) bookmark web URLs specified in Terraform output `working connections`
- Edit `~/.ssh/known_hosts` and remove entries from previous demos (unless using ssh aliases)
- Follow instruction in Terraform output `working connections`
  - Open two URL's in Browser
    - web-page rendered by `web_client` service
    - Consul UI
- Verify the all services are running in Consul UI

### Introduction

- Show [High Level Architecture](./diagrams/1-High-Level-Architecture-sm.png) diagram

> Explain the three tiers and communications between the services.  We are going to start by discussing Service Discovery and Service Registration

### Service Discovery

> In order for services to be discoverable via Consul, they first must register themselves.

#### Service Discovery - Service Registration

- open new terminal tab & connect to `MongoDB` instance
  - use connection string in terraform output `working connections`

> This instance's Consul client publishes all the services running on it to Consul.  In this demo, MongoDB is the only service on this host, so let's review it's config.

- run `./1-cat-cons-config.sh` to display `MongoDB` service configuration

> Explain service config & health check basics.  Consul uses this information to build a Service Catalog.  Consul monitors health checks to insure only healthy services listed in catalog.

- (optional) - show service tab on Consul UI, select MondoDB & show service checks
- you can `exit` the ssh connection to `MongoDB` instance

#### Service Discovery - Overview

> Once services are registered, other services can easily discover them.  Let's show how the listing service connects to MongoDB.

- open new terminal tab & connect to `listing` instance
  - use connection string in terraform output `working connections`

> The listing service is written in NodeJS and isn't Consul aware.  It reads the environment variables DB_URL to get MongoDB servers address.

- run `./1-cat-system.sh` to show listing service systemd configuration

> It's systemd config set DB_URL Environment Var to mongodb.service.consul.

- run `./2-dig.sh` to show a dns query using dig for all mongodb services

> Consul automatically resolves service names via DNS to an IP where mongodb is running.  Dig queries Consul via DNS and returns healthy mongodb service.

- (optional) ping the mongodb service: `ping mongodb.service.consul`
- (optional) list services registered with Consul: `consul catalog services`

#### Service Discovery - Network Traffic

> Service discovery allows service to easily discover and connect to other services.  But Network traffic is unencrypted unless services coded with encryption.

- run `./3-nw-traffic.sh` to show network traffic between `listing` and `mongodb`
  - Traffic will stream immediately as the connection to mongodb is persistent
  - Watch the traffic and press `ctrl-c` after you see the database records displayed

> Point out that the data including db creds is traversing network in plaintext.

- Hit _Cntl-C_ to exit network traffic dump
- you can `exit` the ssh connection to `listing` instance

### Consul Service Mesh

> Next we're going to talk about Consul Service Mesh and some of the enhancements it brings.

- Show [Consul Configuration Single DC](./diagrams/3-Consul-Config-Single-DC-sm.png) diagram

> You'll notice that the Front Tier and Middle tier have sidecar-proxies.  They are configured to communicate via Consul Service Mesh.  The Back Tier is configured to only use Service Discovery.

- open new terminal tab & connect to `webclient` instance
  - use connection string in terraform output `working connections`

#### Consul Service Mesh - Configuration

> In the diagram, webclient communicates with listing & product services.  Let's show how the webclient service is configured.

- run `./1-cat-system.sh` to show webclient service systemd configuration

> Systemd config sets Environment Vars for listing & product to localhost @ unique ports.  So how are these local ports re-directed to the proper services? via the proxy.

- run `./2-cat-cons-config.sh` to display `webclient` service configuration

> Describe the connect-sidecar service block.  Upstream connections bind a local port to services in Consul.  Consul proxies localhost:10001 to `product` services AND encrypts the traffic.  Consul proxies localhost:10002 to `listing` services AND encrypts the traffic.  (Note: product uses "prepared query" to enable failover to other datacenters.)

- run `./3-dig.sh` to show a dns query using dig for all product services
- (optional) list listing services using dig: `dig +short listing.connect.consul srv`

> Like earlier, this host resolves service names to an IP where product is running.  Notice, here we search on servicename.CONNECT.consul instead of .SERVICE.consul.  This limits our results to services using Consul Connect.

- (optional) query mongoDB service using connect `dig +short mongodb.connect.consul srv`

> Nothing returned as the MongoDB services are not configured to use Consul Connect (refer to diagram if necessary).

#### Consul Service Mesh - Network Traffic

> The sidecar proxies use TLS to encrypt communications.

- run `./4-nw-traffic.sh` to show network traffic between `webclient` and `product`
- wait or refresh the web_client web-page to see network traffic

> As we can see, the network traffic is TLS encrypted gibberish.

- Hit _Cntl-C_ to exit network traffic dump
- you can `exit` the ssh connection to `webclient` instance

#### Consul Service Mesh - Intentions

> Intention enable defining specific services that each service can communicate.

- Show Web Client web page, and point out its communicating with Listing & Product

> Now we'll stop all services (that are configured for Service Mesh) from communicating.

- Open Consul UI and select Intentions tab
  - Create an Intention from `*` to `*` of type `Deny` and click save
- Show Web Client web page and point out it cannot communicate with Listing or Product services

> Lets allow web_client to communicate with the listing service.

- Switch back to Consul Intentions UI
  - Create Intention from `web_client` to `listing` of type `Allow` and click save
- Show Web Client web page and point out it can now communicate with Listing

> (OPTIONAL) Intentions specify which service can initiate communications.

- Switch back to Consul Intentions UI
  - Create Intention from `product` to `web_client` of type `Allow` and click save
- Show Web Client web page and point out the it still cannot communicate with product

> Note: web_client cannot talk to product because the intention added allows product to initiate connections to web_client, and not other way around.  So, lets add a connection that allows web_client to initiate communications with product.

- Switch back to Consul Intentions UI
  - Create Intention from `web_client` to `product` of type `Allow` and click save
- Show Web Client web page and point out both working again

> **Describe "Scalability of Intentions"**:  If you have 6 `web_client` instances, 17 `listing` instances and 23 `product` instances; you'd have `6 * 17 + 6 * 23 = 240` endpoint combinations to define.  These can be replaced with just _2_ intention definitions.
> **Another example**: If you double the number of backends, you have to add _another_ 240 endpoint combinations.  With Intentions, you do _nothing_ because intentions follow the service.

#### Consul Service Mesh - Summary

> Steps required to configure `web_client` to talk to `product` via connect

  1. Configure services for Service Mesh
  2. Tell `web_client` that `product` service is reachable on localhost ports
  3. Consul Service Mesh handles balancing traffic between 1, 2, 20, 100 healthy instances
  4. Consul Service Mesh _encrypts_ all network traffic
  5. `web_client` knows _nothing_ about TLS
  6. `web_client` knows _nothing_ about mutual-TLS authentication
  7. `web_client` doesn't have to manage certificates, keys, CRLs, CA certs...
  8. `web_client` simply makes the same _simple, unencrypted requests_ it always has

> By configuring `product` to listen only on `localhost`, you've reduced the security boundary to individual server instances --- all network traffic is _encrypted_.  Only steps necessary to enable existing application to configure Consul Service Mesh and  _configure app to communicate to port on localhost_.

  1. `product` knows _nothing_ about TLS
  2. `product` knows _nothing_ about mutual-TLS authentication
  3. `product` doesn't have to manage certificates, keys, CRLs, CA certs...
  4. `product` simply sees _simple, unencrypted traffic_ coming to it

### Configuration K/V (OPTIONAL)

> Describe how the web_client service has been displaying configuration information from Consul's K/V store.

- Show Web Client web page, point out **Configuration** Section
  - the `product` service reads the Consul K/V store (along with the mongodb records)
  - data returns to `web_client` and displayed

### Datacenter Failover - (MULTI-REGION DEMO ONLY)

> Webclient service is configured to use a "prepared query" to find the `product` service.  If every product service in the current DC fails, it looks for the service in other DCs.  Additional info on the prepared query can be found in the [prepared_query reference](./reference/prepared_query.md)

- Show Web Client web page
  - point out **Configuration** Section under Product API
  - shows **datacenter = dc1**

> Now we're going to trigger the product service to fail in this datacenter.

- Open Consul UI and select Key/Value tab (make sure it's in dc1)
  - Click on `product` folder and value `run`
  - Change value from `true` to `false`
- Switch to the Consul UI services and watch the `product` services fail their health checks
  - wait until there are two failures for `product` and its proxy

> Now that the service has failed, let view the webpage.

- Show Web Client web page & hit refresh
  - point out **Configuration** Section under Product API
  - now shows **datacenter = dc2**, as the instance responding is in DC2

#### Datacenter Failover - Optional Drill-down (MULTI-REGION DEMO ONLY)

- ssh into any one of the previous servers (in DC1)
- type `dig +short product.connect.consul srv`
  - no product services are available in this DC
- type `dig +short product.query.consul srv`
  - but by searching the prepared query (as the web_client is doing) shows services in the other datacenter
- disable the failover by setting the `product/run` key back to `true`
  - wait for the services to become active again in DC1
  - type `dig +short product.query.consul srv` and show how he results have changed back to this DC
  - type `dig +short product.connect.consul srv` - shows the same results as the query, as all the services in this DC are working
