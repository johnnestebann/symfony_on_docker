#!/usr/bin/env bash

# Determine if stdout is a terminal...
if test -t 1; then
    # Determine if colors are supported...
    ncolors=$(tput colors)

    if test -n "$ncolors" && test "$ncolors" -ge 8; then
        BOLD="$(tput bold)"
        YELLOW="$(tput setaf 3)"
        GREEN="$(tput setaf 2)"
        RED="$(tput setaf 1)"
        NC="$(tput sgr0)"
    fi
fi

# Verify operating system is supported...
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    MACHINE=linux
elif [[ "$OSTYPE" == "darwin"* ]]; then
    MACHINE=mac
else
    MACHINE="UNKNOWN"
fi

if [ "$MACHINE" == "UNKNOWN" ]; then
    echo "${RED}Unsupported operating system [$OSTYPE]."
    echo "${NC}GEMS supports macOS, Linux, and Windows (WSL2)." >&2
    exit 1
fi

# Verify docker is installed...
if ! command -v docker > /dev/null; then
    echo "${RED}Docker is not installed."
    echo "${NC}Please install Docker latest version -> https://docs.docker.com/engine/install/"
    exit 1
fi

# Verify docker compose is installed...
if ! command -v docker compose > /dev/null; then
    echo "${RED}Docker Compose plugin is not installed."
    echo "${NC}Please install Docker Compose plugin latest version -> https://docs.docker.com/compose/install/"
    exit 1
fi

# Verify git is installed...
if ! command -v git > /dev/null; then
    echo "${RED}Git is not installed."
    echo "${NC}Please install Git latest version -> https://git-scm.com/book/en/v2/Getting-Started-Installing-Git"
    exit 1
fi

# Function that prints the available commands...
function display_help {
    echo "${BOLD}App commands${NC}"
    echo
    echo "${YELLOW}Usage:${NC}" >&2
    echo "  app COMMAND [options] [arguments]"
    echo
    echo "Unknown commands are passed to the docker compose binary."
    echo
    echo "${YELLOW}App project commands:${NC}"
    echo
    echo "  ${BOLD}[command]       [alias]      [description]${NC}"
    echo
    echo "  ${GREEN}app install${NC}    [i]          Initialize the project"
    echo "  ${GREEN}app up${NC}         [u]          Start the project"
    echo "  ${GREEN}app stop${NC}       [d]          Stop the project"
    echo "  ${GREEN}app restart${NC}    [r]          Restart the project"
    echo "  ${GREEN}app rebuild${NC}    [b]          Rebuild the project"
    echo "  ${GREEN}app logs${NC}       [l]          See logs"
    echo "  ${GREEN}app ssh${NC}        [s]          SSH into the app container"
    echo "  ${GREEN}app quality${NC}    [q]          Run quality checkers"

    exit 1
}

# Proxy the "help" command...
if [ $# -gt 0 ]; then
    if [ "$1" == "help" ] || [ "$1" == "-h" ] || [ "$1" == "-help" ] || [ "$1" == "--help" ]; then
        display_help
    fi
else
    display_help
fi

case "$1" in
    install|i)
        docker buildx build -f ./infra/base/php/Dockerfile -t symfony-app-base .
        docker buildx build -f ./infra/dev/php/Dockerfile -t symfony-app .
        ./app up
        ;;
    up|u)
        docker compose up -d
        ;;
    stop)
        docker compose stop
        ;;
    restart|r)
        ./app stop
        ./app up
        ;;
    rebuild|b)
        docker compose kill
        ./app install
        ;;
    logs|l)
        docker compose logs -n 10 -f
        ;;
    ssh|s)
        docker compose exec -it -u user-app symfony-app-php sh
        ;;
    quality|q)
        docker compose exec -it -u user-app symfony-app-php php bin/console doctrine:migration:migrate --no-interaction
        docker compose exec -it -u user-app symfony-app-php php bin/console doctrine:schema:update --force
        docker compose exec -it -u user-app symfony-app-php php bin/console doctrine:fixtures:load --no-interaction
        docker compose exec -it -u user-app symfony-app-php vendor/bin/phpunit --coverage-html docs/coverage
        ;;
    *)
        docker compose $@
        ;;
esac

exit 1
