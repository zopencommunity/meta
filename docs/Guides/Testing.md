# Testing

## Getting Started

### Environment

The [zopen community CI/CD](https://cicd.zopen.community) pipeline leverages Wazi as a Service instances to be able to build, test, and deploy ported packages to Github Releases.

### zopen community Github Actions

zopen community ports take advantage of Github Actions to be able to build and test project changes directly on our CI/CD z/OS machines. The [build and test](https://github.com/zopencommunity/meta/blob/main/.github/workflows/build_and_test.yml) job triggers a build on Jenkins and reports the status and test results back. If the Github Action is triggered on a Pull Request, then a status check is created to represent the status of the build and test job. Is is strong recommended that you wait for a green status before merging in your approved Pull Request.

Additionally, each port has its own github workflow in place, which calls the build and test job. For example, metaport has the following [workflow](https://github.com/zopencommunity/metaport/blob/main/.github/workflows/build_and_test.yml), which triggers the build and test job to be executed on specific events, including on opened or updated pull requests and on the comment '/run tests'. It also speficies which files to ignore.

#### What to do when there are issues

The build and test job can sometimes fail due to environment or Jenkins related issues. For example, this issue is quite common:
```
  ..........................................................Console output: 

  
  <!DOCTYPE html><html><head resURL="/static/475dfc94" data-rooturl="" data-resurl="/static/475dfc94" data-extensions-available="true" data-unit-test="false" data-imagesurl="/static/475dfc94/images" data-crumb-header="Jenkins-Crumb" data-crumb-value="82483c0595e9cee14b8c260fbf3804f9ae5fc8be2543d7ffdf71e5ec968afc98">

  ...
```

This usually occurs when the Jenkins system is overloaded.


If this is case, simply add the comment `/run tests` to your PR to trigger another build. 


### zopen community Jenkins CI/CD Pipeline

Access to the Jenkins CI/CD Pipeline is currently restricted.  To be able to view/launch Jenkins CI/CD jobs, you must first log-in with your w3id (currently IBM Internal)

### Overview of Jenkins CI/CD jobs

The zopen community CI/CD pipeline defines three generic Jenkins CI/CD jobs: `Port-Pipeline`, `Port-Build` and `Port-Publish`. The _framework_ jobs are viewable at https://cicd.zopen.community/view/Framework/.

* Port-Pipeline: This Jenkins pipeline drives the entire build, test, and deploy pipeline.  It can be used by any port that leverages the [zopen framework](https://github.com/zopencommunity/meta). It calls the following two Jenkins Jobs as part of its pipeline:
	* Port-Build: This Jenkins job builds, tests, and packages the port.  It runs `build.sh` from the meta framework and produces a pax.Z artifact.  If any of the build, test, or package scripts fail, then the Jenkins job will result in failure.
	* Port-Publish: This Jenkins job consumes an artifact from _Port-Build_ and publishes it into the respective repository's Github Releases page.

The implementation of these jobs is stored under the [Meta repo](https://github.com/zopencommunity/meta/tree/main/cicd).

### Setting up a Jenkins CI/CD job for your Port

* To set up a Jenkins CI/CD Job for your port, create a `cicd.groovy` script as follows under your zopen community repository:
```groovy
node('linux')
{
        stage('Build') {
                build job: 'Port-Pipeline', parameters: [string(name: 'PORT_GITHUB_REPO', value: 'https://github.com/zopencommunity/myport.git'), string(name: 'PORT_DESCRIPTION', value: 'This is a description of my port' )]
        }
}
```

Once you have checked in the `cicd.groovy` script, inform Igor Todorovski at itodorov@ca.ibm.com and he will create the pipeline job corresponding to your project.

### Launch a Jenkins CI/CD build for your project
If you have sufficient access, then you can launch a build of your z/OS Open Source port via Jenkins. Alternatively, you can initiate a build automatically via a commit to the corresponding repository.

If you have access, to start a build, locate your port from the _Port_ view: [https://cicd.zopen.community](https://cicd.zopen.community).

Click on the arrow pointing downwards and select *Build Now*. This will launch a build of your port.

