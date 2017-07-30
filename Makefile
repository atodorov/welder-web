eslint:
	npm run eslint

stylelint:
	npm run stylelint

build-test:
	npm install
	npm run build

unit-test:
	npm run test:cov

end-to-end-test:
	sudo docker run --rm --name end_to_end --network welder \
	    -v test-result-volume:/result -v `pwd`:/mddb -e MDDB='/mddb/metadata.db' \
	    weld/end-to-end:latest \
	    xvfb-run -a -s '-screen 0 1024x768x24' npm run test

e2e-before-install:
	if [ -f ${CACHE_FILE_FEDORA} ]; then gunzip -c ${CACHE_FILE_FEDORA} | sudo docker load; fi
	if [ -f ${CACHE_FILE_WEB} ]; then gunzip -c ${CACHE_FILE_WEB} | sudo docker load; fi
	if [ -f ${CACHE_FILE_API} ]; then gunzip -c ${CACHE_FILE_API} | sudo docker load; fi
	if [ -f ${CACHE_FILE_END_TO_END} ]; then gunzip -c ${CACHE_FILE_END_TO_END} | sudo docker load; fi
	git clone https://github.com/weldr/welder-deployment.git
	git clone https://github.com/weldr/bdcs-api-rs.git
	wget https://s3.amazonaws.com/weldr/metadata.db
	sudo docker network create welder
	mv welder-deployment/Dockerfile-weld-f25 welder-deployment/Dockerfile

e2e-install:
	sudo docker build --cache-from weld/fedora:25 -t weld/fedora:25 welder-deployment/
	sudo docker build --cache-from weld/end-to-end:latest -t weld/end-to-end:latest test/end-to-end/
	sudo docker build --cache-from weld/web:latest -t weld/web:latest .
	sudo docker build --cache-from weld/bdcs-api:latest -t weld/bdcs-api:latest bdcs-api-rs/
	sudo docker run -d --name api --restart=always -p 4000:4000 -v bdcs-recipes-volume:/bdcs-recipes -v `pwd`:/mddb --network welder --security-opt label=disable weld/bdcs-api
	sudo docker run -d --name web --restart=always -p 80:3000 --network welder weld/web
	mkdir -p $CACHE_DIR
	if [[ ${TRAVIS_BRANCH} == "master" ]] && [[ ${TRAVIS_PULL_REQUEST} == "false" ]]; then sudo docker save weld/fedora:25 | gzip > ${CACHE_FILE_FEDORA}; fi
	if [[ ${TRAVIS_BRANCH} == "master" ]] && [[ ${TRAVIS_PULL_REQUEST} == "false" ]]; then sudo docker save weld/web:latest | gzip > ${CACHE_FILE_WEB}; fi
	if [[ ${TRAVIS_BRANCH} == "master" ]] && [[ ${TRAVIS_PULL_REQUEST} == "false" ]]; then sudo docker save weld/bdcs-api:latest | gzip > ${CACHE_FILE_API}; fi
	if [[ ${TRAVIS_BRANCH} == "master" ]] && [[ ${TRAVIS_PULL_REQUEST} == "false" ]]; then sudo docker save weld/end-to-end:latest | gzip > ${CACHE_FILE_END_TO_END}; fi