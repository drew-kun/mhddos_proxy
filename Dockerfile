FROM golang:1.16-alpine as bomber
ENV REPO="github.com/codesenberg/bombardier"
ENV REPO_EDIT="github.com/PXEiYyMH8F/bombardier@78-add-proxy-support"
WORKDIR /app
RUN go mod init bombardier_tmp
RUN go mod edit -replace ${REPO}=${REPO_EDIT}
RUN go get ${REPO}
RUN CGO_ENABLED=0 go install -v -ldflags '-extldflags "-static"' ${REPO}
RUN /go/bin/bombardier --help


FROM python:3
WORKDIR /mhddos_proxy
COPY src/MHDDoS/requirements.txt /mhddos_proxy/MHDDoS/requirements.txt
RUN pip install --no-cache-dir -r MHDDoS/requirements.txt
COPY --from=bomber /go/bin/bombardier /root/go/bin/bombardier
COPY src/ /mhddos_proxy
COPY mhddos/ /mhddos_proxy
ENTRYPOINT ["python3", "./runner.py"]
