# ================================
# Build
# ================================
FROM swift:5.8 as build

# setup
RUN apt-get -qq update && apt-get -qq upgrade
WORKDIR /build

# create dependency cache
COPY ./Package.* ./
RUN swift package resolve

# build
COPY . .
RUN swift build -c release --static-swift-stdlib

# stage (executable and bundle)
WORKDIR /staging
RUN cp "$(swift build --package-path /build -c release --show-bin-path)/FactsAPI" ./
RUN find -L "$(swift build --package-path /build -c release --show-bin-path)/" -regex '.*\.resources$' -exec cp -Ra {} ./ \;

# ================================
# Run
# ================================
FROM ubuntu:22.04 as run

# setup
RUN apt-get -qq update && apt-get -qq upgrade
RUN useradd --user-group --create-home --system --skel /dev/null --home-dir /app factsapi
WORKDIR /app

# stage
COPY --from=build --chown=factsapi:factsapi /staging /app

# run
USER factsapi:factsapi
EXPOSE 8080
ENTRYPOINT ["./FactsAPI"]
CMD ["serve", "--env", "production", "--hostname", "0.0.0.0", "--port", "8080"]
