To deploy

Use docker build

docker build -t ss .

Then to init & launch

docker run -ti --entrypoint /bin/bash -p 8088:8088 ss

then inside the container:

init-superset.sh


to launch ss each time, which container is running:

run-ss.sh

or connect from another shell and run it:

docker exec -ti <containerID>  bash

run-ss.sh

