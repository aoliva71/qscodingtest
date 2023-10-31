# qs-tf

## General info

To address for scalability and resiliency, I've decided the application is deployed as a static webapp hosted on cloudfront.

This way there will be no single point of failure in terms of compute resources.

Being an "Hello, World!" type of application, there is no need for any particular architecture (no message queues, no db, no lambdas...).

To test the deployment, hostnames to be contacted is returned by the "tf apply" output.

`website_hostname` is the s3 endpoint and `website_cloudfront_hostname` the cloudfront endpoint.

The webapp itself is just fetching data from public available api that creates fake company details. Such details are the rendered to a simple page.

To turn this hello world into something more sound, there should be:

1) no plaintext traffic allowed at all, which is always good to start with
2) authentication (possibly oauth2 using for instance providers like google, facebook, microsoft azure)
3) imagining the api has to be part of the application and not external, it should have its own apigw
4) such apigw should then have throttling configured, forward requests to a compute resource such as a lambda (for example) to do the heavy lifting, and if it makes sense for the type of application, enable caching.
5) a db should be kept to track which companies where contacted, which were interested, and which became customers.
6) static files could still be served via cloudfront, so that part should stay

## Maintenance

A possible strategy to allow deployments with no downtime, could be achieved for instance by simply switching a dns record.
Example scenraio: callcentre.mydomain.com being an alias (CNAME) for deployment-a.cloudfront.net.
new (parallel deployment) is deployment-b.cloudfront.net.
whenever happy with the deployment-b, the alias can be moved to point to it.

## Limitations/exclusions

I've gone for AWS access key id/secret key for simplicity but openid connect would have been a better option.

## Deploy/undeploy

I don't have a personal Terraform Cloud account so I'm afraid instead of GitHub Actions and CI/CD, I'm going to need manual actions.

To deploy run:
```
terraform init
terraform plan -out=terraform.plan
terraform apply terraform.plan
```

The output of `terraform apply terraform.plan` will output cloudfront and s3 endpoint names.
Both can be used with the difference cloudfront hostname points to an edge location.

To undeploy:
```
terraform plan -destroy -out=destroy.plan
terraform apply destroy.plan
```
