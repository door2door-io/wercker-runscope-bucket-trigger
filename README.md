# Runscope Bucket Trigger

[![wercker status](https://app.wercker.com/status/2a5b74379a6ccd7d619b51bd81b9cd1d/s "wercker status")](https://app.wercker.com/project/bykey/2a5b74379a6ccd7d619b51bd81b9cd1d)

This step will trigger all tests defined in a Runscope bucket and wait
until all tests have been executed.

The step will fail if any test is not passing.

## Required variables

You must provide the following values:

* `runscope-access-token`: This step will make calls to the Runscope API and
requires an authorization token to do so. Read the [Runscope documentation](https://www.runscope.com/docs/api/authentication)
for further information.

 _Note_: This variable is required when `skip-monitoring` is set to `false`

* `runscope-trigger-token`: This token/id will be used to start a test in a
bucket.

 To obtain this token, please proceed to the [Runscope documentation](https://www.runscope.com/docs/api-testing/integrations).

## Optional variables

The following variable is optional:

* `runscope-environment-uuid`: The environment in which the tests will be executed.
This will fall back to the default environment defined in your bucket if it is omitted.
* `skip-monitoring` (Default: `false`): When this flag is enabled, the script will
not attempt to do any further calls to Runscope to monitor the execution of the tests.
Thus the `runscope-access-token` is only required, when this variable is set to
`true`.
* `skip` (Default: `false`): Skip this test entirely. This variable
should be set if you want to skip the exection in one pipeline.

## Example

```
deploy:
    after-steps:
      - ally/runscope-bucket-trigger:
          access-token: $RUNSCOPE_ACCESS_TOKEN
          trigger-token: $RUNSCOPE_TRIGGER_TOKEN
          environment-uuid: $RUNSCOPE_ENVIRONMENT_UUID
          skip-monitoring: $RUNSCOPE_SKIP_MONITORING
          skip: $RUNSCOPE_SKIP_TRIGGER
```