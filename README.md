# Fluentd Librato Output Plugin

This is a [Fluentd](http://www.fluentd.org) plugin to post data to [Librato Metrics](http://librato.com)

## Installing

to be uploaded on Rubygems

## Example config

```
<match librato.**>
  type librato
  email YOUR_EMAIL_FOR_LIBRATO
  apikey YOUR_APIKEY_FOR_LIBRATO
</match>
```

## Parameters

* **email**: (required) The email address associated with Librato.
* **apikey**: (required) The apikey associated with Librato.
* **measurement_key**: (optional) The measurement key field. Defaults to "key"
* **value_key**: (optional) The measurement value field. Defaults to "value"
* **source_key**: (optional) The source key field. Defaults to "source"
* **type_key**: (optional) The field that specified type (gauge or counter). Defaults to "gauge"

## Example Expected Input

```
{
  "source": "web.example.com",
  "key": "memory_usage",
  "value": 12092323,
  "type": "gauge"
}
```
