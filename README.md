# Runscope Bucket Trigger

[![wercker status](https://app.wercker.com/status/34a92c184740e9422f15281f92288d07/s/master "wercker status")](https://app.wercker.com/project/bykey/34a92c184740e9422f15281f92288d07)

This step will trigger all tests defined in a Runscope bucket and wait
until all tests have been executed.

The step will fail if any test is not passing.

## Required variables

You must provide the following values:

* `runscope_access_token`: This step will make calls to the Runscope API and
requires an authorization token to do so. Read the [Runscope documentation](https://www.runscope.com/docs/api/authentication)
for further information.
* `runscope_trigger_token`: This token/id will be used to start a test in a
bucket. To obtain this token, please proceed to the [Runscope documentation](https://www.runscope.com/docs/api-testing/integrations).

## Optional variables

The following variable is optional:

* `runscope_environment_uuid`: The environment in which the tests will be executed.
This will fall back to the default environment defined in your bucket if it is omitted.

## Example

```
deploy:
    after-steps:
      - ally/runscope-bucket-trigger:
          access-token: $RUNSCOPE_ACCESS_TOKEN
          trigger-token: $RUNSCOPE_TRIGGER_TOKEN
          environment-uuid: $RUNSCOPE_ENVIRONMENT_UUID
```