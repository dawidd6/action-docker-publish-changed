const core = require('@actions/core')
const exec = require('@actions/exec')
const github = require('@actions/github')
const path = require('path')
const fs = require('fs')

async function main() {
  try {
    const token = core.getInput("token", { required: true })
    const username = core.getInput("username")
    const password = core.getInput("password")
    const platforms = core.getInput("platforms", { required: true })
    const tag = core.getInput("tag", { required: true })

    const client = github.getOctokit(token)

    // Parse JSON event file.
    const eventPath = process.env.GITHUB_EVENT_PATH
    const eventJson = fs.readFileSync(eventPath, { encoding: "utf-8" })
    const event = JSON.parse(eventJson)

    // Get directories where changed files in pushed commits reside.
    let changedDirs = []
    for (const eventCommit of event.commits) {
      const commit = await client.repos.getCommit({
        ...github.context.repo,
        ref: eventCommit.id
      })

      for (const file of commit.data.files) {
        const dir = path.dirname(file.filename)

        if (changedDirs.includes(dir)) {
          continue
        }

        changedDirs.push(dir)
      }
    }

    // Determine images names by reading every directory.
    // If a Dockerfile is found in a directory then "directory name" == "image name".
    // If not then go up the stack and repeat.
    let dirs = []
    for (const dir of changedDirs) {
      let currentDir = dir
      let foundDockerfile = false

      do {
        const files = fs.readdirSync(currentDir)

        for (const file of files) {
          if (file == "Dockerfile") {
            foundDockerfile = true
            break
          }
        }

        if (foundDockerfile) {
          break
        }

        currentDir = path.dirname(currentDir)
      } while (currentDir != ".");

      if (currentDir == ".") {
        currentDir = path.resolve(currentDir)
      }

      if (foundDockerfile) {
        if (dirs.includes(currentDir)) {
          continue
        }

        dirs.push(currentDir)
      }
    }

    // Login to registry if desired.
    if (username && password) {
      await exec.exec("docker", ["login", "-u", username, "-p", password])
    }

    // Setup buildx if there are any images to be built.
    if (dirs.length > 0) {
      await exec.exec("docker", ["run", "--privileged", "docker/binfmt:66f9012c56a8316f9244ffd7622d7c21c1f6f28d"])
      await exec.exec("docker", ["buildx", "create", "--use", "--name", "builder"])
      await exec.exec("docker", ["buildx", "inspect", "--bootstrap", "builder"])
    }

    // Build images.
    for (const dir of dirs) {
      const image = path.basename(dir)

      await exec.exec("docker", [
        "buildx",
        "build",
        ... (username && password) ? ["--push"] : [],
        "--platform", platforms,
        "-t", `${username ? username : github.context.actor}/${image}:${tag}`,
        dir
      ])
    }
  } catch (error) {
    core.setFailed(error.message)
  }
}

main()
