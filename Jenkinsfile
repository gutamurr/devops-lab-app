pipeline {
	agent any

	stages {
		stage("Checkout") {
			steps {
				git branch: 'master', url: 'https://github.com/gutamurr/ci-cd-webapp.git'
			}
		}

		stage("Build & Run") {
			steps {
				script {
					sh '''
						docker compose down --remove-orphans || true
						docker compose up -d --build --force-recreate
					'''
					}
				}
			}

		stage("Test") {
			steps {
				script {
					sh '''
						echo "Health response:"
						curl -f http://localhost:8080/health
					'''
				}
			}
		}

	}
}
