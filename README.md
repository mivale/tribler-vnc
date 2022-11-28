# Tribler VNC "bridge"

## Preamble

Everythin written here assumes the current release 7.12.1 of Tribler. If at any point the Tribler developers decide to change things, this project might become completely redundant.

Also note that this is NOT A WEB GUI for Tribler. It's not.

## Intro

This project was created because I wanted to be able to leave Tribler running on my nas instead of on my laptop (duh).

Because Tribler currently has a tight integration with an api that's started when the gui is started, you can't run the api on a different server. Also there's no option to point to an api on a different host than `127.0.0.1`

Since building a web interface using the well-documented api was too much work, I chose this path.

## What this project does

It downloads the release as given in the `Makefile` and builds a docker image from which you can start a container in any of the regular ways of starting docker containers.

Then it builds an image which has all the required dependencies installed, adds a start-x11 script and sets it as the CMD (you can override this script if you need more stuff done during startup).

## Added bonus

### An accessible api on port 20100

Since the api is bound to localhost within the container, there's no option to access it but to have a "tunnel". This is done within the container using `socat`.

Access it on `http://mynas:20100/docs`. Don't forget to fetch the api_key from the generated `settings/7.12/triblerd.conf`

### Log rotation

Since Tribler is rather heavy on the logging, any container it is running in would have many GBs of docker logs after letting it run for a while. These logs are a lot harder to remove than logs in a mounted path.

They are rotated after 100M of logging with a limit of 5.

## Yeah, yeah, enough already

If you have no knowledge how to build and run containers you're a little out of luck, since I will not answer any questions that can not be answered by teaching yourself docker.

I did it. You can too. Use the net to answer your questions.

OTOH, I've made it as easy as I could to build and run this thing. Inspect the `Makefile` for more info.

### Quickstart

```bash
make build
make run
make logs
```

To run it with `docker compose`, you can use the provided `docker-compose.yml` as a starting point.

Point VNC viewer to `[your-ip]` and login with the password "tribler"

Hint: MacOS has a built in command `vncviewer`. Just run it from the terminal.

## Happy Tribling
