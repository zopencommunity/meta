
node('linux')
{
  stage ('Poll') {
               // Poll from upstream:
               checkout([
                       : 'GitSCM',
                       branches: [[name: '*/...']],
                       doGenerateSubmoduleConfigurations: false,
                       extensions: [],
                       userRemoteConfigs: [[url: 'https://...']]])

                // Poll for local changes
                checkout([


                        doGenerateSubmoduleConfigurations: false,
                        extensions: [],

  }

  stage('Build') {


  string(name: 'BUILD_LINE', value: 'DEV')]
  }
}

