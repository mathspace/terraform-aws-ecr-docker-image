# syntax=docker/dockerfile:1
FROM python:3.7-alpine AS builder

# Assemble only Python, its native dependencies, and runtime data.
RUN <<'EOF'
set -eu
mkdir -p /runtime/usr/local/bin /runtime/usr/local/lib /runtime/etc/ssl/certs /runtime/tmp
chmod 1777 /runtime/tmp
python_exe="$(readlink -f "$(command -v python3)")"
cp -L "$python_exe" /runtime/usr/local/bin/
ln -s "$(basename "$python_exe")" /runtime/usr/local/bin/python3
ln -s python3 /runtime/usr/local/bin/python
cp -a /usr/local/lib/libpython* /usr/local/lib/python* /runtime/usr/local/lib/
find /usr/local/lib -type f -name '*.so*' -exec ldd {} \; 2>/dev/null > /tmp/runtime-libraries
ldd "$python_exe" >> /tmp/runtime-libraries
if grep -q '=> not found' /tmp/runtime-libraries; then cat /tmp/runtime-libraries; exit 1; fi
awk '$2 == "=>" && $3 ~ /^\// { print $3 } $1 ~ /^\// { print $1 }' /tmp/runtime-libraries \
    | sort -u | while read -r library; do cp -L --parents "$library" /runtime; done
cp /etc/ssl/certs/ca-certificates.crt /runtime/etc/ssl/certs/
cp /etc/passwd /etc/group /runtime/etc/
if [ -f /etc/nsswitch.conf ]; then cp /etc/nsswitch.conf /runtime/etc/; fi
rm -rf /runtime/usr/local/lib/python*/ensurepip /runtime/usr/local/lib/python*/site-packages/pip*
EOF

FROM scratch
COPY --from=builder /runtime/ /
ENV PATH="/usr/local/bin:/usr/bin:/bin" \
    LD_LIBRARY_PATH=/usr/local/lib \
    SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt \
    LANG=C.UTF-8

WORKDIR /src
COPY main.py /src/main.py
ENTRYPOINT ["python", "main.py"]
