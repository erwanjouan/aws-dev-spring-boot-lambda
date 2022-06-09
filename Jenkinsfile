def projectName = 'aws-dev-spring-boot-lambda'
def projectVersion = '0.0.1-SNAPSHOT'

pipeline {
    agent { label 'aws-cli' }
    environment {
        AWS_ACCESS_KEY_ID = credentials('aws_access_key_id')
        AWS_SECRET_ACCESS_KEY = credentials('aws_secret_access_key')
        AWS_DEFAULT_REGION='eu-west-1'
        GIT_COMMIT_HASH = sh (script: "git log -n 1 --pretty=format:'%H'", returnStdout: true)
    }
    stages{
        stage('Configure CodeBuild') {
            steps{
                sh """
                    aws cloudformation deploy \
                        --capabilities CAPABILITY_NAMED_IAM \
                        --template-file ./pipeline/cloudformation.yml \
                        --stack-name ${projectName}-init \
                        --parameter-overrides \
                            ProjectName=${projectName} \
                            ProjectVersion=${projectVersion} \
                            GitCommitId=${GIT_COMMIT_HASH}
                """
            }
        }
        stage('Build in CodeBuild') {
            steps {
                awsCodeBuild projectName: projectName, credentialsType: 'keys', region: 'eu-west-1', sourceControlType: 'project', sourceVersion: "${GIT_COMMIT_HASH}"
            }
        }
    }
}
