@Library('epidata.pipeline') _

env.FPC_VERSION='3.2.0'
env.ENTRYCLIENT_VERSION='4.6.0'

node {
    stage("Source Checkout") {
        checkout scm
    }

    stage("Linux-64") {
        epidocker.run "mvn compile -Plinux64 -U"
    }

    stage("Win-64") {
        epidocker.run "mvn compile -Pwin64 -U"
    }

    stage("Mac-64") {
        epidocker.run "mvn compile -Pdarwin64 -U"
    }

    stage("Package & Deploy") {
        sh "mvn versions:set -DnewVersion=${ENTRYCLIENT_VERSION}.${BUILD_ID} -f deploy.pom.xml"
        sh "mvn deploy -f deploy.pom.xml"
        sh "mvn clean"
        sh "svn revert -R *"
    }

    properties([
        pipelineTriggers([
            upstream(
                upstreamProjects: 'EpiData Core/branches%2Fjenkins',
                threshold: hudson.model.Result.SUCCESS
            )
        ])
    ])
}