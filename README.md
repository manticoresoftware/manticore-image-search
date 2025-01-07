# Demo: Image Search with Manticore Search

**Publicly available demo - [image.manticoresearch.com](https://image.manticoresearch.com/)**

[Blogpost about this project](https://manticoresearch.com/blog/reverse-image-search-demo/)

## Just run the demo locally

To run the project on your local machine, you need to have Docker installed with the compose plugin. Follow these commands to start:

```
git clone https://github.com/manticoresoftware/manticore-image-search.git
cd manticore-image-search
cd docker/containers/manticore

wget https://github.com/manticoresoftware/manticore-image-search/releases/download/241204/backup.tar.gz && rm -fr backup && sudo tar --numeric-owner -xzpf backup.tar.gz

cd ../..
docker compose down -v
docker compose up
```

Take note that running untar as root is essential to maintain proper user permissions and ensure they are correctly mapped to the manticore user within the container.

After completing these steps, the project should be accessible at [http://localhost/](http://localhost/).

## Further configuration

The default port for the server is 80, so if you need to change it, update the `nginx` section in `app/config/app.ini.yml`.

## Preparing for deployment

If you plan to extend this project beyond a simple Manticore Image Search demo and want to run your own version from this repository, we've got you covered with remote server deployment. To get started, first grab [yoda](https://github.com/Muvon/yoda) and give its documentation a quick read to understand how it works.

#### Deployment

For deployment, tweak the `docker/Envfile` with your server details and make sure you have passwordless authentication set up with your SSH key. Then, simply run:

```bash
yoda deploy --env=production
```

#### Setting up a new server in 5 steps

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
