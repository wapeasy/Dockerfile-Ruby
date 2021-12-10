#!/usr/bin/env bash 

RUBY_MAJOR="2.7"
RUBY_VERSION="ruby-2.7.5"

# Ubuntu 20.04
core_name="ubuntu-focal"

docker_image_ver="v0.1"
docker_image_workspace="/home/ruby/workspace/"
docker_container_name="MyRuby"
docker_container_port="4000"
mount_path=""

optspec=":m:n:p:svh-:"

_usage() {
    ###### U S A G E : Help and ERROR ######
    echo "usage: [-v] [--version[=]<value>]"
    echo "Options: *(must)"
    echo "  -m   --mount          mount local dir (*)"
    echo "  -n   --name           docker container name (*)"
    echo "  -s   --stop           docker container stop"
    echo "  -p   --port           hostPort(32768):containerPort"
    echo "       --rm             docker container rm"
    echo "  -h   --help           help"
    echo "  -v   --version        version ..."
}

_docker_creat() {
    echo "${docker_container_name} Container Creat..."
    docker run -itd \
            --name ${docker_container_name} \
            -v ${mount_path}:${docker_image_workspace} \
            -p 32768:${docker_container_port} \
            ${RUBY_VERSION}/${core_name}:${docker_image_ver} /bin/bash
}

_docker_start() {
    echo "${docker_container_name} Container Start..."
    docker start ${docker_container_name}
}

_docker_exec() {
    echo "${docker_container_name} Container Exec..."
    docker exec -it ${docker_container_name} /bin/bash
}

_docker_stop() {
    echo "${docker_container_name} Container Stop..."
    docker stop ${docker_container_name}
}

_docker_rm() {
    echo "${docker_container_name} Container rm..."
    docker rm ${docker_container_name}
}

_docker_run() {
    local container_state
    container_state=`docker inspect --format {{.State.Status}} ${docker_container_name}`

    # if [[ $(docker inspect --format {{.State.Status}} ${docker_container_name}) ]]; then
    if [[ ${container_state} ]]; then
        case ${container_state} in
            exited)
                _docker_start
                _docker_exec
            ;;
            running)
                _docker_exec
            ;;
        esac
    else 
        _docker_creat
        _docker_exec
    fi
}

_main() {
    _docker_run
}

while getopts "$optspec" optchar; do
    case "${optchar}" in
        -)
            case "${OPTARG}" in
                mount)
                    val="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                    mount_path=${val}
                    break
                    ;;
                mount=*)
                    val=${OPTARG#*=}
                    opt=${OPTARG%=$val}
                    echo "Parsing option: '--${opt}', value: '${val}'" >&2
                    break
                    ;;
                name)
                    val="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                    docker_container_name="${val}"
                    break
                    ;;
                port)
                    val="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                    docker_container_port=${val}
                    break
                    ;;
                stop)
                    _docker_stop
                    exit 2
                    ;;
                rm)
                    _docker_rm
                    exit 2
                    ;;
                help)
                    _usage
                    exit 2
                    ;;
                version)
                    echo "${docker_image_ver}"
                    exit 2
                    ;;
                *)
                    if [ "$OPTERR" = 1 ] && [ "${optspec:0:1}" != ":" ]; then
                        echo "Unknown option --${OPTARG}" >&2
                    fi
                    ;;
            esac;;
        m)
            mount_path=${OPTARG}
            break
            ;;
        n)
            docker_container_name=${OPTARG}
            break
            ;;
        p)
            docker_container_port=${OPTARG}
            break
            ;;
        h)
            _usage
            exit 2
            ;;
        v)
            echo "${docker_image_ver}"
            exit 2
            ;;
        s)
            _docker_stop
            exit 2
            ;;
        *)
            if [ "$OPTERR" != 1 ] || [ "${optspec:0:1}" = ":" ]; then
                echo "Non-option argument: '-${OPTARG}'" >&2
            fi
            ;;
    esac
done

_main