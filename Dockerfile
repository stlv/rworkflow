FROM ruby:2.5-alpine

ENV PROJECT_NAME rworkflow

RUN apk --no-cache upgrade && \
    gem update && \
    mkdir /$PROJECT_NAME

WORKDIR ${PROJECT_NAME}

COPY . ./

RUN bundle install

CMD ["ruby", ${PROJECT_NAME}]
