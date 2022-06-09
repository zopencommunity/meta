# CI/CD Pipeline

## Getting Started

### Environment

The z/OS Open Tools CI/CD pipeline leverages z/OS Virtual Server Instances (zVSI) to be able to build, test, and deploy ported packages to Github Releases.

There is currently one zVSI Jenkins node set up under the ip address `128.168.136.67`.

### zVSI Directory Structure
* TBD

### z/OS Open Tools Jenkins CI/CD Pipeline

Access the Jenkins CI/CD Pipeline at https://128.168.139.253:8443.  To be able to view the Jenkins CI/CD jobs, you must first log-in with your w3id.

### Overview of Jenkins CI/CD jobs

The z/OS Open Tools CI/CD pipeline defines three generic Jenkins CI/CD jobs: `Port-Pipeline`, `Port-Build` and `Port-Publish`

* Port-Pipeline: This Jenkins pipeline drives the entire build, test, and deploy pipeline.  It can be used by any port that leverages the [utils framework](https://github.com/ZOSOpenTools/utils). It calls the following two Jenkins Jobs as part of its pipeline:
	* Port-Build: This Jenkins job builds, tests, and packages the port.  It runs `build.sh` from the utils framework and produces a pax.Z artifact.  If any of the build, test, or package scripts fail, then the Jenkins job will result in failure.
	* Port-Publish: This Jenkins job consumes an artifact from _Port-Build_ and publishes it into the respective repository's Github Releases page.

### Setting up a Jenkins CI/CD job for your Port

* To set up a Jenkins CI/CD Job for your port, simply create a [newJob](https://128.168.139.253:8443/newJob), then type in the name of your port, click on Pipeline, and then select `OK`.
* Using `https://128.168.139.253:8443/view/xzport/job/xzport/configure` as an example, define two String parameters, `NAME` and `DESCRIPTION`
* Then in the pipeline script, enter the following:
```
node('linux') 
{
        stage('Build') {
                build job: 'Port-Pipeline', parameters: [string(name: 'REPO_NAME', value: params.get("NAME")), string(name: 'DESCRIPTION', value: params.get("DESCRIPTION") )]
        }
}
```
The above script leverages and call the Port-Pipeline job with the NAME and DESCRIPTION parameters.
* Now click save and then click on `Build with Parameters`
* Your job is now ready to go
