### DLP Self Deposit

[![Maintainability](https://api.codeclimate.com/v1/badges/e1c13ce3a205adcb3965/maintainability)](https://codeclimate.com/github/emory-libraries/dlp-selfdeposit/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/e1c13ce3a205adcb3965/test_coverage)](https://codeclimate.com/github/emory-libraries/dlp-selfdeposit/test_coverage)

#### Deployment

1. Connect to `vpn.emory.edu`
2. Pull the latest version of `main`
3. Stub AWS' environment variables for `Emory Account 70` within the same terminal window. These can be found in the page loaded after logging into [Emory's AWS](https://aws.emory.edu). Directions below:
  a. After logging in, the page should be the `AWS access portal`. A table of multiple accounts should be presesnt (typically three). Expand the `Emory Account 70` option.
  b. Clicking on `Access keys` will open a modal with multiple credential options. Option 1 (`Set AWS environment variables`) is necessary for successful deployment.
  c. Copy the variables in Option 1, paste them into the terminal window that the deployment script will be processed, and press enter.
5. To deploy, run `BRANCH={BRANCH_NAME_OR_TAG} bundle exec cap {ENVIRONMENT} deploy`. To deploy main to the arch environment, for instance, you run `BRANCH=main bundle exec cap arch deploy`.

### Deployment Troubleshooting

If errors occur when running the deployment script, there could be a couple of factors causing them:
- Ensure you are authorized to access the server you are deploying to. You can verify your access by trying to ssh into the server e.g. `ssh deploy@SERVER_IP_ADDRESS`.
- The server IP lookup processing may not be working. In this case, stub the backup environment variables for the desired server in the local `.env.development` file. The list of backup environment variables are below:

```
ARCH_SERVER_IP=
TEST_SERVER_IP=
PROD_SERVER_IP=
```

#### Local Development

##### Useful Links

- Hyrax: http://localhost:3000/
- Solr: http://localhost:8983/solr/#/
- Fedora Commons: http://localhost:8080/fcrepo/rest

#### Documentation

- [PDF Viewer](/public/PDF_README.md)
