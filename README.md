# Build and publish changed Docker image Github Action

An action that examines which paths were modified by pushed commits and determines which images should be built and published.

It will only work if one has a repository consisting of multiple directories (image names) with Dockerfiles in them. See for example: https://github.com/dawidd6/docker.

## Usage

```yaml
- name: Checkout
  uses: actions/checkout@v1
- name: Publish changed images
  uses: dawidd6/action-docker-publish-changed@master
  with:
    docker_username: ${{github.event.repository.owner.login}}
    docker_password: ${{secrets.PASS}}
    github_token: ${{secrets.GITHUB_TOKEN}}
```
