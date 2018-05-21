FROM fedora:latest
LABEL maintainer="Brian C. Lane" \
      email="bcl@redhat.com" \
      baseimage="Fedora:latest" \
      description="A welder-web container running on Fedora"

ARG NODE_FILE

RUN dnf install --setopt=deltarpm=0 --verbose -y gnupg tar xz curl nginx && dnf clean all

CMD nginx -g "daemon off;"
EXPOSE 3000

RUN echo 'PATH=/usr/local/bin/:$PATH' >> /etc/bashrc

COPY $NODE_FILE .
RUN tar -xJf $NODE_FILE -C /usr/local --strip-components=1

## Do the things more likely to change below here. ##

COPY ./docker/nginx.conf /etc/nginx/

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# Update node dependencies only if they have changed
COPY ./package.json /welder/package.json
RUN cd /welder/ && npm install

# Copy the rest of the UI files over and compile them
COPY . /welder/
RUN cd /welder/ && node run build --with-coverage
