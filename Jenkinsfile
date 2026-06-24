pipeline {
	agent any

	stages {
		stage("Checkout") {
			steps {
				git branch: 'jack', url: 'https://github.com/gutamurr/ci-cd-webapp.git'
			}
		}

		stage("Build & Run") {
			steps {
				script {
					cd "web-app"
					sh "docker compose up -d --build"
				}
			}
		}

		stage("Test") {
			steps {
				script {
					sh "curl -f http://localhost:8080/health"
				}
			}
		}

	}
}