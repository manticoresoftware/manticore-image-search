# Demo: Image Search with Manticore Search

**Publicly available demo - [image.manticoresearch.com](https://image.manticoresearch.com/)**

[Blogpost about this project](https://manticoresearch.com/blog/reverse-image-search-demo/)

## Just run the demo locally

To run the project on your local machine, you need to have Docker installed with the compose plugin. Follow these commands to start:

```
git clone https://github.com/manticoresoftware/manticore-image-search.git
cd manticore-image-search
docker compose down -v
docker compose up
```

After completing these steps, the project should be accessible at [http://localhost/](http://localhost/). 

## Further configuration

The default port for the server is 80, so if you need to change it, update the `nginx` section in `app/config/app.ini.tpl`.

## Preparing for Deployment

If you aim to use this project beyond a Manticore Search demo, such as an alternative to GitHub's issue search, there's a method for deploying it on a remote server. First, install [yoda](https://github.com/Muvon/yoda) on your machine and familiarize yourself with its documentation.

#### Deployment

For deployment, tweak the `docker/Envfile` with your server details and make sure you have passwordless authentication set up with your SSH key. Then, simply run:

```bash
yoda deploy --env=production
```

#### Setting Up a New Server in 5 Steps

Please remember, deployment happens from the default branch to the server from the local machine. You can use the `--branch` flag with the `yoda` command to deploy from a different branch.

Place your public keys in the `docker/.ssh/authorized_keys` folder on the local machine.

1. Start by initializing a new server using Rocky Linux 9 as the base operating system.
2. Enter your server's IP address in the `Envfile` file on your local machine.
3. Execute the following command to prepare the server and also set up SSH keys for you:

    ```bash
    yoda setup --host=server-ip
    ```

4. Kick off the deployment process with the next command:

    ```bash
    yoda deploy --host=server-ip
    ```

    or

    ```bash
    yoda deploy --env=production --branch=main
    ```

5. Wait for it to finish, and then you're good to go!
