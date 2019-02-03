#!/usr/bin/env bash
set +e

echo "==============================================================="
echo "Deploy called listing all variables"
echo "api: " ${api}
echo "username: "${username}
echo "password: "${password}
echo "org: "${organization}
echo "space: "${space}
echo "appname: "${app_name}
echo "apphost: "${app_host}
echo "domain: "${domain}

echo "===============================================" 


cf api ${api} --skip-ssl-validation
cf login -u ${username} -p ${password} -o ${organization} -s ${space}

cf apps | grep blue-${app_name}

if [ $? -eq 0 ]
then
  echo "blue Available deploying green"

  cf push green-${app_name} -p ../../target/articulate-1.0.0.jar -m 800m -n green-${app_name}
  cf map-route green-${app_name} -${domain} --hostname ${app_host}
  cf unmap-route green-ut-articulate ${domain} --hostname green-${app_host}

  cf delete blue-${app_name} -f
  cf delete-route ${domain} --hostname blue-${app_name} -f
  cf delete-route ${domain} --hostname green-${app_name} -f
else
  echo "blue not available deploying blue"

  cf push blue-${app_name} -p ../../target/articulate-1.0.0.jar -m 800m -n blue-${app_name}
  cf map-route blue-${app_name} ${domain} --hostname ${app_host}
  cf unmap-route blue-${app_name} ${domain} --hostname blue-${app_host}
  
  cf delete green-${app_name} -f
  cf delete-route ${domain} --hostname green-${app_host} -f
  cf delete-route ${domain} --hostname blue-${app_host} -f
fi