pipeline {
    agent any
    environment {
        compose_cfg='docker-compose.yaml'
        container='rpmgr'
        d_containers="${container}"
        d_volumes='rpmgr.database'
        service='rpmgr'
        projopt='-p jenkins'
    }
    options { disableConcurrentBuilds() }
    parameters {
        string(defaultValue: 'True', description: '"True": initial cleanup: remove container and volumes; otherwise leave empty', name: 'start_clean')
        string(defaultValue: '', description: '"True": "Set --nocache for docker build; otherwise leave empty', name: 'nocache')
        string(defaultValue: '', description: '"True": push docker image after build; otherwise leave empty', name: 'pushimage')
        string(defaultValue: '', description: '"True": keep running after test; otherwise leave empty to delete container and volumes', name: 'keep_running')
    }

    stages {
        stage('Config ') {
            steps {
                sh '''#!/bin/bash -e
                    echo "using ${compose_cfg} as docker-compose config file"
                    cp "${compose_cfg}.default" $compose_cfg
                    egrep '( image:| container_name:)' $compose_cfg || echo "missing keys in ${compose_cfg}"
                '''
            }
        }
        stage('Cleanup ') {
            when {
                expression { params.$start_clean?.trim() != '' }
            }
            steps {
                sh '''#!/bin/bash -e
                    source ./jenkins_scripts.sh
                    remove_containers $d_containers && echo '.'
                    remove_volumes $d_volumes && echo '.'
                '''
            }
        }
        stage('Build') {
            steps {
                sh '''#!/bin/bash -e
                    source ./jenkins_scripts.sh
                    remove_container_if_not_running
                    if [[ "$nocache" ]]; then
                         nocacheopt='-c'
                         echo 'build with option nocache'
                    fi
                    docker-compose build $nocacheopt || \
                        (rc=$?; echo "build failed with rc rc?"; exit $rc)
                '''
            }
        }
        stage('Test: setup') {
            steps {
                echo 'Setup unless already setup and running (keeping previously initialized data) '
                sh '''#!/bin/bash -e
                    source ./jenkins_scripts.sh
                    is_running=$(test_if_running $container)
                    if [[ ! "$is_running" ]]; then
                        echo "start server"
                        docker-compose $projop --no-ansi up -d && echo ''
                    elif [[ ! "$start_clean" ]]; then
                        echo 'container already running: restart using the existing volumes'
                        docker-compose $projop down
                        docker-compose $projop --no-ansi up -d && echo ''
                    fi
                '''
            }
        }
        stage('Push ') {
            when {
                expression { params.pushimage?.trim() != '' }
            }
            steps {
                sh '''#!/bin/bash -e
                    default_registry=$(docker info 2> /dev/null |egrep '^Registry' | awk '{print $2}')
                    echo "  Docker default registry: $default_registry"
                    docker-compose push
                '''
            }
        }
    }
    post {
        always {
            sh '''#!/bin/bash -e
                if [[ "$keep_running" ]]; then
                    echo "Keep container running"
                else
                    source ./jenkins_scripts.sh
                    remove_containers $d_containers && echo 'containers removed'
                    remove_volumes $d_volumes && echo 'volumes removed'
                fi
            '''
        }
    }
}