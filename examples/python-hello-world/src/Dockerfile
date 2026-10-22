FROM python:3.7-alpine
# Bump to force an OS image rebuild for updated certificates and other fixes.
RUN echo cachebuster-1

RUN mkdir /src
ADD main.py /src/main.py

WORKDIR /src

ENTRYPOINT ["python", "main.py"]
