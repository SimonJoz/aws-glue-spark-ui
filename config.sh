#!/bin/bash

# ---------------------------------------------------------------
# Configuration File for Spark History Server Docker Deployment
# ---------------------------------------------------------------
# This file contains configuration variables that you need to update
# before running the Spark History Server Docker container.
# You can choose between using an AWS named profile, static AWS
# credentials (access key and secret key), or temporary credentials.
#
# Ensure that you update the variables below with the appropriate values
# based on your AWS credentials and S3 log directory.
# ---------------------------------------------------------------

# AWS Credentials Configuration

# Set the AWS CLI profile name if you're using a named profile for AWS CLI
# Default profile is "default", but you can specify any profile configured in your AWS CLI configuration file (~/.aws/credentials)
# Example: AWS_PROFILE_NAME="my-profile"
AWS_PROFILE_NAME="default" # Set your AWS CLI profile name here

# Set the AWS Access Key ID and Secret Access Key if you're using static AWS credentials (access keys)
# These are typically obtained from IAM users in your AWS account.
# If you use temporary credentials, you can leave these blank and provide a session token instead.
AWS_ACCESS_KEY_ID=""         # Enter your AWS Access Key ID here
AWS_SECRET_ACCESS_KEY=""     # Enter your AWS Secret Access Key here

# Set the AWS Session Token if you're using temporary credentials (e.g., from AWS STS)
# Temporary credentials are generally valid for a limited period.
# If using static credentials, you can leave this blank.
AWS_SESSION_TOKEN=""

# ---------------------------------------------------------------
# S3 Log Directory Configuration

# Set the S3 log directory where Spark event logs are stored
# This should be the S3 path to the logs for your AWS Glue Spark jobs
# Example: AWS_S3_LOG_BUCKET="s3a://my-spark-logs-bucket/spark-logs/"
AWS_S3_LOG_BUCKET="s3a://<your-spark-logs-bucket>"  # Replace with your S3 bucket URL

# ---------------------------------------------------------------
# Spark History Server Options Configuration

# Set additional Spark History options here.
# The `spark.history.fs.logDirectory` points to the location of Spark event logs.
# If you want to configure other Spark options, add them to this variable.
SPARK_HISTORY_OPTS="-Dspark.history.fs.logDirectory=$AWS_S3_LOG_BUCKET"



# ---------------------------------------------------------------
# End of configuration
# ---------------------------------------------------------------
