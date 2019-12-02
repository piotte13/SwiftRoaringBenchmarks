# SwiftRoaringBenchmarks

## Docker

```bash
$ git clone https://github.com/piotte13/SwiftRoaringBenchmarks.git
$ cd SwiftRoaringBenchmarks
$ docker build -t swift-roaring-benchmarks-docker .
$ docker run -it swift-roaring-benchmarks-docker

# If you want to copy graphs back to your local machine (host)
$ CONTAINER_ID=$(docker ps -alq)
$ docker cp $CONTAINER_ID:/usr/src/Graphs .
```