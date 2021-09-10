#cache
# Build
FROM gradle:jdk-alpine AS builder
USER root
RUN apk update &&  apk add tzdata
# Locale
ENV LANG ru_RU.UTF-8
ENV LANGUAGE ru_RU:ru
ENV LC_LANG ru_RU.UTF-8
ENV LC_ALL ru_RU.UTF-8
# Timezone
RUN echo "Europe/Kiev" > /etc/timezone
ENV TZ Europe/Kiev
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
# copy the project files
#COPY ./pom.xml ./pom.xml
# build all dependencies for offline use
#RUN mvn dependency:go-offline -B
# copy other files
#COPY . /home/project
#COPY ./build /
#COPY ./gradle /home/gradle/project/gradle
WORKDIR /home/gradle/project
EXPOSE 8080
ENV GRADLE_USER_HOME /home/gradle/project
COPY . /home/gradle/project
RUN ./gradlew build

FROM java:jre-alpine
RUN addgroup -S myuser && adduser -S myuser -G myuser
USER myuser
EXPOSE 8080
WORKDIR /app
COPY --from=0 /home/gradle/project/build/libs/project-0.0.1-SNAPSHOT.jar .
COPY --from=0 /home/gradle/project/build/libs/dev.db .
ENTRYPOINT java -jar project-0.0.1-SNAPSHOT.jar --Xmx=200m
HEALTHCHECK --interval=5s --timeout=10s --retries=3 CMD --tries=1 --spider http://localhost/ || exit 1
