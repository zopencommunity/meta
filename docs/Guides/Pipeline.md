# CI/CD Pipeline

## Getting Started

### Environment

The z/OS Open Tools CI/CD pipeline leverages Wazi as a Service instances to be able to build, test, and deploy ported packages to Github Releases.

There is currently one z/OS node set up under the ip address `128.168.143.139`. 

### z/OS Open Tools Jenkins CI/CD Pipeline

Access the Jenkins CI/CD Pipeline at https://163.74.88.212:8443.  To be able to view/launch Jenkins CI/CD jobs, you must first log-in with your w3id (currently IBM Internal)

### Overview of Jenkins CI/CD jobs

The z/OS Open Tools CI/CD pipeline defines three generic Jenkins CI/CD jobs: `Port-Pipeline`, `Port-Build` and `Port-Publish`. The _framework_ jobs are viewable at https://163.74.88.212:8443/view/Framework/.

* Port-Pipeline: This Jenkins pipeline drives the entire build, test, and deploy pipeline.  It can be used by any port that leverages the [zopen framework](https://github.com/ZOSOpenTools/meta). It calls the following two Jenkins Jobs as part of its pipeline:
	* Port-Build: This Jenkins job builds, tests, and packages the port.  It runs `build.sh` from the meta framework and produces a pax.Z artifact.  If any of the build, test, or package scripts fail, then the Jenkins job will result in failure.
	* Port-Publish: This Jenkins job consumes an artifact from _Port-Build_ and publishes it into the respective repository's Github Releases page.

The implementation of these jobs is stored under the [Meta repo](https://github.com/ZOSOpenTools/meta/tree/main/cicd).

### Setting up a Jenkins CI/CD job for your Port

* To set up a Jenkins CI/CD Job for your port, create a `cicd.groovy` script as follows under your z/OS Open Tools repository:
```groovy
node('linux')
{
        stage('Build') {
                build job: 'Port-Pipeline', parameters: [string(name: 'PORT_GITHUB_REPO', value: 'https://github.com/ZOSOpenTools/myport.git'), string(name: 'PORT_DESCRIPTION', value: 'This is a description of my port' )]
        }
}
```

Once you have checked in the `cicd.groovy` script, inform Igor Todorovski at itodorov@ca.ibm.com and he will create the pipeline job corresponding to your project.

### Launch a Jenkins CI/CD build for your project
If you have sufficient access, then you can launch a build of your z/OS Open Source port via Jenkins. Alternatively, you can initiate a build automatically via a commit to the corresponding repository.

To manually start a build, locate your port from the _Port_ view: `https://163.74.88.212:8443/view/Ports/`

Click on the arrow pointing downwards and select *Build Now*. This will launch a build of your port.


### Slack Build Status Notifications
A slack notification is currently set up to post build status on the [#zos-opentools-builds](https://ibm-systems-z.slack.com/archives/C03QBPC863E) slack channel.

