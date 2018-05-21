<b>Logz.io ECS Log Shipping Reference Architecture</b>

The recommended approach for shipping logs from ECS is to utilize the Docker JSON File logging driver (default) and FluentD. 

Included are the FluentD plugins 
- fluent-plugin-ecs-metadata-filter (https://github.com/michaelgruber/fluent-plugin-ecs-metadata-filter) which enriches the records with ECS metadata for context and routing.
- fluent-plugin-detect-exceptions (https://github.com/GoogleCloudPlatform/fluent-plugin-detect-exceptions) which is an output plugin for fluentd which scans a log stream text messages or JSON records for multi-line exception stack traces.

<b>Requirements

FluentD >= v0.14.0 <br />
Ruby >= 2.1 <br />
Docker (Tested on 17.09.1, but likely backward compatible)

Getting Started<br /></b>
1 - Make sure the JSON-file logging driver is enabled (this is the default Docker logging driver):
https://docs.docker.com/config/containers/logging/json-file/<br />

2 - Docker build to build the package:
``` shell
docker build -t fluentd_logzio_docker:1.0 https://github.com/Benjamin-Connelly/logzioEcsFluentd.git
```

3 - Use your favorite secrets manager for `${LogzioToken}``

For AWS SSM and CloudFormation:
``` shell 
    LogzioToken:
    Type: 'AWS::SSM::Parameter::Value<String>'
    Default: 'LogzioToken'
    Description: Datadog API Key
```

4 - Docker run with a volume mount to the container log directory to read the container logs, a volume mount to /tmp to write the pos_file to the host, environment variables for Logz.io tokens to accounts and sub-accounts and map the network to the localhost in order to access the ECS agent for metadata. Example:<br />
```shell 
docker run --name logzio -v /var/lib/docker/containers:/var/lib/docker/containers -v /tmp:/tmp -e "LOGZ_IO_URL_1=https://listener.logz.io:8071?token=${LogzioToken}" -d --net="host" fluentd_logzio_docker:1.0
```

You can use the `fluend.conf` to send to multiple Logzio `sub-accounts` if you would like to seperate environments or have a multi-tenant ECS Instance. 
``` shell
docker run -v /var/lib/docker/containers:/var/lib/docker/containers -v /tmp:/tmp -e "LOGZ_IO_URL_1=https://listener.logz.io:8071?token=xxxxxxxxxxxxxxxxxxxxx" -e "LOGZ_IO_URL_2=https://listener.logz.io:8071?token=xxxxxxxxxxxxxxxxxxxxx" -e "LOGZ_IO_URL_3=https://listener.logz.io:8071?token=xxxxxxxxxxxxxxxxxxxxx" -d --net="host" fluentd_logzio_docker:1.0
```

<b>Configuration<br /></b>
The fluent.conf file contains configuration and comments which accomplish the following:<br />
1 - Source to pull the logs from the docker container logs directory
2 - The ECS plugin which enriches with metadata
3 - The Google plugin which detects multiline Stacktraces and Exceptions
4 - A match to update the FluentD tag with the ECS metadata
4 - FluentD tag pattern matching to route data to Logzio as well as a catch-all account. 
