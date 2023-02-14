# Kit

[![CodeQL](https://github.com/alexec/kit/actions/workflows/codeql-analysis.yml/badge.svg)](https://github.com/alexec/kit/actions/workflows/codeql-analysis.yml)
[![Go](https://github.com/alexec/kit/actions/workflows/go.yml/badge.svg)](https://github.com/alexec/kit/actions/workflows/go.yml)
[![goreleaser](https://github.com/alexec/kit/actions/workflows/goreleaser.yml/badge.svg)](https://github.com/alexec/kit/actions/workflows/goreleaser.yml)

## Why

Improve developer productivity.

## Background

Modern developments has moved away from monolith services to micro-services. Development may depends on other services, which maybe your own organizations services, or they could be a Open Source project (such as Kafak or Postgres) available as container images.

## What

Shift-lest testing from test environments into graph of processes that represent the local build and runtime execution of your app. Automatically re-build and re-start the application when source code changes. Robustly start and stop.

```mermaid
---
title: Example of an app
---
flowchart LR
    classDef container fill:#f1d3a1,stroke-width:0
    classDef host fill:#e6eff6,stroke-width:0
    api(name: api\ncommand: java -jar target/api.jar\nworkingDir: ./api\nports: 8080):::host --> build-api(name: build-api\ncommand: mvn package\nworkingDir: ./api\nwatch: ./api):::host
    api --> mysql(name: mysql\n image: mysql:latest):::container
    processor(name: processor\ncommand: ./processor):::host --> build-processor(name: build-processor\ncommand: go build ./processor\nwatch: ./processor):::host
    processor --> kafka(name: kafka\nimage: ./src/images/kafka):::container
    processor --> object-storage(name: object-storage\nimage: minio:latest):::container
    processor --> api
    ui(name: ui\ncommand: yarn start\nworkingDir: ./ui\nports: 4000):::host --> build-ui(name: build-ui\ncommand: yarn install\nworkingDir: ./ui):::host
    ui --> api
```

## How

- You specify a set of **tasks** that run in **containers** or as **host processes**.
- Tasks may have a **mutex**, so you can prevent tasks running concurrently.
- Task may run to **completion** (e.g. a build or tests) or run **indefinitely** (e.g. a web service or database).
- You can specify **liveness probes** for your tasks to see if they're working, automatically restarting them
  when they go wrong.
- You can specify **readiness probes** for your tasks to see if they're ready.
- You can specify **dependencies** between tasks, when upstream tasks become successful or ready downstream tasks
  are automatically started.
- Tasks run concurrently and their status is **muxed into a single terminal window** so you're not overwhelmed by
  pages of terminal output.
- You can specify **watches on your source code**, when changes occur, tasks are automatically re-run.
- When you're done, **close your terminal** or **ctrl+c** to and they're all cleanly stopped.
- **Logs are captured** so you can look at them anytime.

You could think of it as `docker compose up` or `podman kube play` that supports host processes, or `foreman` that
supports containers.

| tool                | container processes | host processes | auto re-run | ctrl+c to stop | terminal mux | log capture | probes |
|---------------------|---------------------|----------------|-------------|----------------|--------------|-------------|--------|
| `kit`               | ✔                   | ✔              | ✔           | ✔              | ✔            | ✔           | ✔      |
| `docker compose up` | ✔                   | ✖              | ✖           | ✖?             | ✔            | ✔           | ✖      |
| `podman play kube`  | ✔                   | ✖              | ✖           | ✖              | ✖            | ✔           | ✔?     |
| `foreman run`       | ✖                   | ✔              | ✖           | ✔              | ✔            | ✖           | ✖      |

Tilt, Skaffold, and Garden are in the same problem space, but they all cross the boundary into deployment and often require Kubernetes.

You could also think of it as a more sophisticated `make -j4`.

## Install

```bash
brew tap alexec/kit --custom-remote https://github.com/alexec/kit
brew install kit
```

## Usage

Create your [`tasks.yaml`](tasks.yaml) file, e.g.:


```yaml
spec:
  tasks:
  - command: go build -v .
    name: build-bar
    watch: demo/bar/main.go
    workingDir: demo/bar
  - command: ./demo/bar/bar
    dependencies: build-bar
    env:
    - PORT=9090
    name: bar
    ports: "9090"
  - dependencies: bar
    name: up
```

Start:

```bash
kit up
```

You'll see something like this:

![screenshot](screenshot.png)

Logs are stored in `./logs`.

## Reference

### Container

The `image` field can be either:

1. An conventional image tag. E.g. `ubunutu`.
2. A path to a a directory containing contain a `Dockerfile`, e.g. `.foo`.

If it is a path to a directory containing `Dockerfile`, that file is built, and tagged.

```yaml
    # conventional image? run in Docker
    - name: baz
      image: httpd
    # path image? build and run in Docker
    - name: qux
      image: demo/qux
```

Any container with the same name as the container name in the YAML is stopped and re-created whenever the process
starts.

### Host Process

If `image` field is omitted, the value of `command` is used to start the process on the host:

```yaml
    # no image? this is a host process
    - name: foo
      command: [ go, run, ./demo/foo ]
```
### Noop

If `image` field is omitted and `command` is omitted, the task does nothing. This is used if you want to start several tasks, and conventionally you'd name the task `up`.

### Auto Rebuild and Restart

You can specify a set of files to watch for changes that result in a re-build:

```yaml
  - watch: demo/bar
    name: bar
```        

### Liveness Probe

If the process is not alive (i.e. "dead"), then it is killed and restarted. Just like Kubernetes.

### Quitting

Enter Ctrl+C to send a `SIGTERM` to the process. Each sub-process is then gets sent `SIGTERM`. If they do not exit
within 30s, then they get a `SIGKILL`. You may wish to reduce this number:

```yaml
spec:
  terminationGracePeriodSeconds: 3
```

You can kill the tool using `kill` for another terminal. If you `kill -9`, then the sub-process will keep
running and you must manually clean up.

## Killing One Process

* To kill a host process: `kill $(lsof -ti:$host_port)`
* To kill a container process: `docker kill $name`.

## References

- [Containers from scratch](https://medium.com/@ssttehrani/containers-from-scratch-with-golang-5276576f9909)
