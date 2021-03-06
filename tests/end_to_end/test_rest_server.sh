#!/usr/bin/env bats

# Copyright (c) Microsoft Corporation
# All rights reserved.
#
# MIT License
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
# documentation files (the "Software"), to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and
# to permit persons to whom the Software is furnished to do so, subject to the following conditions:
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED *AS IS*, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING
# BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
# DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


. utils.sh

eval $(parse_yaml $cluster_config "pai_")
hdfs_uri=$pai_clusterinfo_restserverinfo_hdfs_uri
rest_server_uri=$pai_clusterinfo_webportalinfo_rest_server_uri


@test "check rest server health check" {
  result="$(curl $rest_server_uri)"
  [[ $result == *API* ]]
}

@test "submit cntk test job" {
  job_name="cntk-test-$RANDOM-$RANDOM"
  token="$(cat ./etc/token.config)"
  result="$(cat ./etc/cntk.json | sed -e "s@CNTK_TEST@$job_name@g" -e "s@HDFS_URI@$hdfs_uri@g" | curl -H "Content-Type: application/json" -H "Authorization: Bearer $token" -X PUT -d @- $rest_server_uri/api/v1/jobs/$job_name)"
  [[ ! $result == *Error* ]]
}