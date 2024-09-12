#!/usr/bin/bash

TOP=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
PRECMD=''
DOCKER=$(which docker)
IMAGES=()
CLI_BUILD_ARGS=()
CLI_TAG=''
ARG_FILE=''
BUILDER=''
USAGE=$(cat <<-END
Usage: $(basename $0) [OPTION]... [IMAGE]...
Build docker IMAGEs

Options:
  -r|--registry REGISTRY  set registry to upload images
  -p|--platform PLATFORM  build images for PLATFORM(s)
  -b|--builder BUILDER    Use a specific Docker builder
  -f|--file FILE          Load build arguments from file FILE
                          The file is searched in the same directory
                          the Dockerfile for the image is in.
                          First line is used as TAG for the new image
  -a|--arg ARG=VALUE      Add build arg for docker.
                          Can be used multiple times
  -t|--tag TAG            Set the TAG for the images to build
  -n|--dry-run            Don't run commands, just print them
  -h|--help               Print this screen and exit
END
)

## Parse command line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    -r|--registry)
      REGISTRY="$2"
      shift
      shift
      ;;
    -p|--platform)
      PLATFORM="$2"
      shift
      shift
      ;;
    -b|--builder)
      BUILDER="$2"
      shift
      shift
      ;;
    -f|--file)
      ARG_FILE="$2"
      shift
      shift
      ;;
    -a|--arg)
      CLI_BUILD_ARGS+=("$2")
      shift
      shift
      ;;
    -t|--tag)
      CLI_TAG="$2"
      shift
      shift
      ;;
    -n|--dry-run)
      PRECMD=echo
      shift
      ;;
    -h|--help)
      echo "$USAGE"
      exit 0
      ;;
    -*|--*)
      echo "Unknown option $1"
      echo "Run '$0 --help' to see valid options"
      exit 1
      ;;
    *)
      IMAGES+=("$1")
      shift
      ;;
  esac
done

## Check mandatory positional arguments
if [[ ${#IMAGES[@]} == 0 ]] ; then
  echo "No images given, nothing to do"
  exit 0
fi

OPTS="--pull"

if [[ -n $BUILDER ]] ; then
  OPTS="$OPTS --builder $BUILDER"
fi

if [[ -n $PLATFORM ]] ; then
  OPTS="$OPTS --platform=$PLATFORM"
fi

if [[ -n $REGISTRY ]] ; then
  OPTS="$OPTS --push"
fi

## build docker images
for image in "${IMAGES[@]}" ; do
  if [[ ! -d ${TOP}/${image} ]] ; then
    echo "Image ${image} not found! Skipping"
    continue
  fi

  cd ${TOP}/${image}

  if [[ -f .needs_ssh ]] ; then
    if [[ -z $SSH_AUTH_SOCK ]] ; then
      echo "The image requires access to your ssh key."
      echo "This script makes use of the SSH agent the 'SSH_AUTH_SOCK' environment variable!"
      continue
    fi
    OPTS="$OPTS --ssh default"
  fi


  TAG=''
  if [[ -n $ARG_FILE ]] && [[ -f $ARG_FILE ]] ; then
    FILE_BUILD_ARGS=($(cat $ARG_FILE))
    for arg in "${FILE_BUILD_ARGS[@]:1}"; do
      OPTS="$OPTS --build-arg $arg"
    done
    TAG=${FILE_BUILD_ARGS[0]}
  fi
  if [[ ${#CLI_BUILD_ARGS[@]} > 0 ]] ; then
    for arg in "${CLI_BUILD_ARGS[@]}"; do
      OPTS="$OPTS --build-arg $arg"
    done
  fi

  if [[ -z $TAG ]] ; then
    if [[ -n $CLI_TAG ]] ; then
      TAG=$CLI_TAG
    else
      TAG="latest"
    fi
  fi

  SHORTTAG=${TAG%%.*}

  echo
  echo ======== $image - BEGIN ======
  echo

  TARGETS=($(grep -o "ta_[[:print:]]\+" Dockerfile))
  if (( ${#TARGETS[@]} == 0 )) ; then
    IMG="${REGISTRY:+${REGISTRY}/}${image}"

    TAG_LIST="-t ${IMG}:${TAG}"
    if [[ "$SHORTTAG" != "$TAG" ]] ; then
      TAG_LIST="$TAG_LIST -t ${IMG}:${SHORTTAG}"
    fi
    if [[ "$TAG" != "latest" ]] ; then
      TAG_LIST="$TAG_LIST -t ${IMG}:latest"
    fi

    $PRECMD $DOCKER build $OPTS $TAG_LIST .
  else
    for TA in "${TARGETS[@]}"; do
      IMG="${REGISTRY:+${REGISTRY}/}${TA#*_}"

      TAG_LIST="-t ${IMG}:${TAG}"
      if [[ "$SHORTTAG" != "$TAG" ]] ; then
        TAG_LIST="$TAG_LIST -t ${IMG}:${SHORTTAG}"
      fi
      if [[ "$TAG" != "latest" ]] ; then
        TAG_LIST="$TAG_LIST -t ${IMG}:latest"
      fi

      $PRECMD $DOCKER build $OPTS --target $TA $TAG_LIST .
    done
  fi

  echo
  echo ======== $image - END ======
  echo

  cd ${TOP}

done

