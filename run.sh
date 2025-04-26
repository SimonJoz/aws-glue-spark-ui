#!/bin/bash

# ---------------------------------------------------------------
# Spark History Server Docker Container Launch Script
# ---------------------------------------------------------------

# Exit immediately if a command exits with a non-zero status
set -e

# Source configuration file
source ./config.sh

# Docker image name
DOCKER_IMAGE="glue/sparkui:latest"

# Function to print usage instructions
usage() {
    echo ""
    echo "Usage: $0 {profile|access|temporary}"
    echo "  profile     : Run the server using an AWS CLI named profile."
    echo "  access      : Run the server using AWS Access Key and Secret Key."
    echo "  temporary   : Run the server using AWS Temporary Credentials (Session Token)."
    exit 1
}

build_image() {
  # Check if the Docker image already exists
  if ! docker image inspect $DOCKER_IMAGE > /dev/null 2>&1; then
    echo -e "Building Docker image..."
    docker build -t $DOCKER_IMAGE .
  else
    echo -e "Docker image '$DOCKER_IMAGE' already exists. Skipping build."
  fi
}

run_profile() {
  if [ -z "$AWS_PROFILE_NAME" ]; then
    echo "Error: AWS_PROFILE_NAME is not set. Please check config.sh"
    exit 1
  fi

  build_image

  echo "Running Spark History Server with AWS CLI profile: $AWS_PROFILE_NAME"
  docker run -itd -v ~/.aws:/root/.aws \
  -e AWS_PROFILE="$AWS_PROFILE_NAME" \
  -e SPARK_HISTORY_OPTS="$SPARK_HISTORY_OPTS -Dspark.history.fs.logDirectory=$AWS_S3_LOG_BUCKET -Dspark.hadoop.fs.s3a.aws.credentials.provider=com.amazonaws.auth.DefaultAWSCredentialsProviderChain" \
  -p 18080:18080 glue/sparkui:latest "/opt/spark/bin/spark-class org.apache.spark.deploy.history.HistoryServer"
}


run_access_key_and_secret() {
  if [ -z "$AWS_ACCESS_KEY_ID" ] || [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
    echo "Error: AWS_ACCESS_KEY_ID or AWS_SECRET_ACCESS_KEY is not set. Please check config.sh."
    exit 1
  fi

  build_image

  echo "Running Spark History Server with AWS Access Key and Secret Key"
  docker run -itd -e SPARK_HISTORY_OPTS="$SPARK_HISTORY_OPTS -Dspark.history.fs.logDirectory=$AWS_S3_LOG_BUCKET -Dspark.hadoop.fs.s3a.access.key=$AWS_ACCESS_KEY_ID -Dspark.hadoop.fs.s3a.secret.key=$AWS_SECRET_ACCESS_KEY" \
  -p 18080:18080 glue/sparkui:latest "/opt/spark/bin/spark-class org.apache.spark.deploy.history.HistoryServer"
}

run_temp_creds() {
  if [ -z "$AWS_ACCESS_KEY_ID" ] || [ -z "$AWS_SECRET_ACCESS_KEY" ] || [ -z "$AWS_SESSION_TOKEN" ]; then
    echo "Error: AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, or AWS_SESSION_TOKEN is not set. Please check config.sh"
    exit 1
  fi

  build_image

  echo "Running Spark History Server with AWS Temporary Credentials"
  docker run -itd -e SPARK_HISTORY_OPTS="$SPARK_HISTORY_OPTS -Dspark.history.fs.logDirectory=$LOG_DIR -Dspark.hadoop.fs.s3a.access.key=$AWS_ACCESS_KEY_ID -Dspark.hadoop.fs.s3a.secret.key=$AWS_SECRET_ACCESS_KEY -Dspark.hadoop.fs.s3a.session.token=$AWS_SESSION_TOKEN -Dspark.hadoop.fs.s3a.aws.credentials.provider=org.apache.hadoop.fs.s3a.TemporaryAWSCredentialsProvider" \
  -p 18080:18080 glue/sparkui:latest "/opt/spark/bin/spark-class org.apache.spark.deploy.history.HistoryServer"
}


# Check if at least one argument is passed
if [ $# -ne 1 ]; then
    usage
fi


# Check the input argument and run the corresponding block of code
case "$1" in
    profile) run_profile ;;
    access) run_access_key_and_secret ;;
    temporary) run_temp_creds ;;
    *)
      echo -e "Error: Invalid option '$1'."
      usage ;;
esac

echo "Spark History Server is now running. You can access it at http://localhost:18080"
