## For creating the simple-node docker image

`docker build -t simple-node .`

## To run the image as container (and close it as soon as we exit the container) on port 3000 (mapping 3000 on our machine : 3000 from inside of container)

`docker run --rm -p 3000:3000 simple-node`

## For tagging and pushing an image to container registry (GCP as example here)

`docker tag imageName registry.url/docker-image-name:tag`

`docker tag kuard gcr.io/kuar-demo/kuard-amd64:blue`

And then

`docker push gcr.io/kuar-demo/kuard-amd64:blue`

## Run container in detach mode

`docker run -d --name kuard --publish 8080:8080 gcr.io/kuar-demo/kuard-amd64:blue`

## For stopping and removing a container

`docker stop containerID
docker rm containerID`

## For limiting resource usage

`docker run -d --name kuard --publish 8080:8080 --memory 200m --memory-swap 1G gcr.io/kuar-demo/kuard-amd64:blue`

## Limiting CPU resources

`docker run -d --name kuard --publish 8080:8080 --cpu-shares 1024 --memory 200m --memory-swap 1G gcr.io/kuar-demo/kuard-amd64:blue`

## Cleanup

`docker rmi <image-id>`

OR

`docker rmi <tag-name>`
