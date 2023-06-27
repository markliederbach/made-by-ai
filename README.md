# Made by AI <!-- omit in toc -->

A collection of AI-generated sites.

- [Getting Started](#getting-started)
  - [Clone Repository](#clone-repository)
  - [Prerequisites](#prerequisites)
- [Deployment](#deployment)
  - [Terraform Cloud](#terraform-cloud)
  - [Infrastructure](#infrastructure)
    - [AWS](#aws)
    - [CloudFlare](#cloudflare)
  - [Building and releasing website source code changes](#building-and-releasing-website-source-code-changes)


# Getting Started
## Clone Repository
```zsh
git clone git@github.com:markliederbach/made-by-ai.git
```

## Prerequisites
This project uses the following packages, which must be installed prior to any tasks:
- [Taskfile.dev](https://taskfile.dev) - used to wrap tasks such as installing dependencies, building artifacts, etc.

# Deployment
## Terraform Cloud
**Assumption:** You must have access to the [quark organization](https://app.terraform.io/app/quark), and specifically the `site-made-by-ai` workspaces.

This project uses Terraform Cloud to store its remote state. In order to access this state, you must login.
```
terraform login
```

## Infrastructure

From the project root, you can run `task terraform:plan` and `task terraform:apply` to manage terraform-provisioned resources in AWS.

**Note:** You must be logged into both AWS SSO, and have a Cloudflare API Token before performing infrastructure changes.

### AWS
First, ensure that you have SSO configured on your machine.
```zsh
$ aws configure sso
SSO start URL [None]: https://liederbach.awsapps.com/start
SSO Region [None]: us-east-1
Attempting to automatically open the SSO authorization page in your default browser.
If the browser does not open or you wish to use a different device to authorize this request, open the following URL:

https://device.sso.us-east-1.amazonaws.com/

Then enter the code:

CMNQ-VKCD
The only AWS account available to you is: 003521492892
Using the account ID 003521492892
The only role available to you is: AdministratorAccess
Using the role name "AdministratorAccess"
CLI default client Region [None]: us-west-2
CLI default output format [None]: json
CLI profile name [AdministratorAccess-003521492892]: liederbach-sso
```

In order to deploy, you must be logged into AWS. For AWS SSO (because it's not natively supported in terraform yet), you must do the following:
```
aws sso login --profile liederbach-sso
```

When you are taken to the browser, upon login, select "programmatic access". From there, copy and paste the `credentials file` profile to your local `~/.aws/credentials` file.

Now you are ready to run terraform operations locally.

### CloudFlare
In order to manage Cloudflare resources, you must have a local API Token with the proper permission scope. Store this token
in `CLOUDFLARE_API_TOKEN` so it will be automatically picked up by the Cloudflare provider.

The following configurations are managed by this repo:
- (Most) Zone Settings
- CNAME DNS records for S3
- Firewall Rules
- Cache Rules

The following configurations are **NOT** managed by this repo:
- Additional DNS records, such as MX (protonmail)
- Nameservers
- DNSSEC
- Under Attack Mode
- Development Mode
- Billing/Payment Settings

To manage these other settings, either manually configure in the console, or use a different repo - depending on the context.

## Building and releasing website source code changes
Since this site is a static website, pushing changes is very easy. Simply run

```
task upload
```

This task will build a release artifact and upload it to the S3 bucket (replacing what was there). From there, the site will be updated - or at least once Cloudflare updates its cache.
