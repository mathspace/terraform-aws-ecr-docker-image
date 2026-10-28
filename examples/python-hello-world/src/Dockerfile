# Certificates
FROM --platform=$BUILDPLATFORM debian:bookworm-slim AS certs
# This line busts the cache if there's security updates.
ADD https://deb.debian.org/debian/dists/bookworm/InRelease /tmp/bust-debian
ADD https://deb.debian.org/debian/dists/bookworm-updates/InRelease /tmp/bust-updates
ADD https://security.debian.org/debian-security/dists/bookworm-security/InRelease /tmp/bust-security
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates

FROM python:3.7-alpine
# This line busts the cache if there's security updates.
ADD https://deb.debian.org/debian/dists/bookworm/InRelease /tmp/bust-debian
ADD https://deb.debian.org/debian/dists/bookworm-updates/InRelease /tmp/bust-updates
ADD https://security.debian.org/debian-security/dists/bookworm-security/InRelease /tmp/bust-security

RUN mkdir /src
ADD main.py /src/main.py
RUN rm -rf /etc/ssl/certs /usr/share/ca-certificates
COPY --from=certs /usr/share/ca-certificates/ /usr/share/ca-certificates/
COPY --from=certs /etc/ssl/certs/ /etc/ssl/certs/
COPY --from=certs /etc/ca-certificates.conf /etc/ca-certificates.conf
COPY --from=certs /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
ENV SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt SSL_CERT_DIR=/etc/ssl/certs \
    REQUESTS_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt AWS_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt

WORKDIR /src

ENTRYPOINT ["python", "main.py"]
