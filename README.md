### DLP Self Deposit

[![Maintainability](https://api.codeclimate.com/v1/badges/e1c13ce3a205adcb3965/maintainability)](https://codeclimate.com/github/emory-libraries/dlp-selfdeposit/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/e1c13ce3a205adcb3965/test_coverage)](https://codeclimate.com/github/emory-libraries/dlp-selfdeposit/test_coverage)

#### Deployment

1. Connect to `vpn.emory.edu`
2. Pull the latest version of `main`
3. Ensure you have the ip address of the server you are deploying to set in the appropriate env variable in `.env.development` e.g. for Arch, the env variable `ARCH_SERVER_IP` must be set.
4. Ensure you are authorized to access the server you are deploying to. You can verify your access by trying to ssh into the server e.g. `ssh deploy@SERVER_IP_ADDRESS`.
5. To deploy, run `BRANCH={BRANCH_NAME_OR_TAG} bundle exec cap {ENVIRONMENT} deploy`. To deploy main for instance, you run `BRANCH=main bundle exec cap arch deploy`.

#### Local Development

##### Useful Links

- Hyrax: http://localhost:3000/
- Solr: http://localhost:8983/solr/#/
- Fedora Commons: http://localhost:8080/fcrepo/rest

#### Documentation

- [PDF Viewer](/public/PDF_README.md)
