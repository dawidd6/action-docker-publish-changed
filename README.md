# Build and publish changed Docker image for multiple platforms Github Action

An action that examines which paths were modified by pushed commits and determines which images should be built and published. Uses [`buildx`](https://github.com/docker/buildx) under the hood for building multi platform images.

It will only work if one has a repository consisting of multiple directories (image names) with Dockerfiles in them. See for example: https://github.com/dawidd6/docker.

## Usage

```yaml
- name: Checkout
  uses: actions/checkout@v1
- name: Publish changed images
  uses: dawidd6/action-docker-publish-changed@v2
  with:
    docker_username: ${{github.event.repository.owner.login}}
    docker_password: ${{secrets.PASS}}
    github_token: ${{secrets.GITHUB_TOKEN}}
    platforms: linux/amd64,linux/arm64,linux/arm
    tag: latest
```
