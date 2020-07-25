# Build and publish changed Docker image for multiple platforms GitHub Action

An action that examines which paths were modified by pushed commits and determines which images should be built and published. Uses [`buildx`](https://github.com/docker/buildx) under the hood for building multi platform images.

## Usage

> If `username` or `password` inputs are not provided, images will not be pushed to registry

```yaml
- name: Checkout code
  uses: actions/checkout@v2
- name: Publish changed images
  uses: dawidd6/action-docker-publish-changed@v3
  with:
    username: ${{secrets.USER}}
    password: ${{secrets.PASS}}
    token: ${{github.token}}
    registry: docker.io
    platforms: linux/amd64,linux/arm64,linux/arm
    tag: latest
```
