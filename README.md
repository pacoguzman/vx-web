# vx-web [![Build Status](https://travis-ci.org/vexor/vx-web.png)](https://travis-ci.org/vexor/vx-web)

Web interface of [Vexor CI](http://vexor.io/)

## Configuration

Set up your `.env`:

    cp .env.example .env.development

Create a github application and replace `GITHUB_KEY` / `GITHUB_SECRET` by using your Client ID / Client Secret

## Database

    rake db:setup

## System dependencies

For running JavaScript tests:

    brew update
    brew install node
    npm install -g karma karma-cli karma-jasmine karma-phantomjs-launcher karma-coffee-preprocessor

## How to run the test suite

    bundle exec rspec
    bundle exec rake karma:templates karma:run
