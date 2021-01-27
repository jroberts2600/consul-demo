# Building Demo Images

The code which built all of the images is in the `packer` directory. The Packer code is there to enable customization of the demo, and view application configuration changes as you investigate Consul.

The images can be built by following these steps:

- `cd packer`
- edit `Makefile` and adjust variables
  - `CONSUL_VER` - version of Consul to build into AMIs
  - `AMI_PREFIX` - default "consul-demo"
  - `AMI_OWNER` - specifies AWS AMI owner ID
- change Terraform code if needed
  - if custom prefix used bu changing the `ami_prefix` variable
  - set the `ami_owner` variable
- export the AWS_REGION to build AMIs
  - `export AWS_REGION="us-west-2"`
- view & edit the packer templates (`.json` files in packer directory)
  - adjust variables defined at the beginning of each template
- use make to build all the aws images with command
  - `make aws`
- All images will be built and pushed to your AWS environment
