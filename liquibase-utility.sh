setupLiquibase(){
  LV="4.13.0"
  INSTALLED="$(command -v /usr/bin/liquibase/liquibase)"

  if [ -z "$INSTALLED" ]
    then
        echo "Liquibase is not installed! Please install liquibase version $LV to proceed"
    else
        INSTALLED="$(/usr/bin/liquibase/liquibase --version)"
        echo "Liquibase is already installed, ${INSTALLED}"
  fi
}

update(){

    ls -ltra
  echo "Validate - COMMON action has been triggered!"
  /usr/bin/liquibase/liquibase \
         --username=$DB_USER \
         --password=$DB_PASSWORD \
         --url=jdbc:mariadb://$DB_SERVER:$DB_PORT/$DB_NAME?autoReconnect=true \
         --changeLogFile=$CHANGELOG_COMMON\
         --logFile=$VALIDATE_LOG\
         --logLevel=debug validate
  echo "Command Status"$?

  COMMAND_STATUS=$?
  if [[ $COMMAND_STATUS == 0 && $TENANT_TYPE == "MSSP" ]]; then
    echo "Validate - MSSP action has been triggered!"
    /usr/bin/liquibase/liquibase \
           --username=$DB_USER \
           --password=$DB_PASSWORD \
           --url=jdbc:mariadb://$DB_SERVER:$DB_PORT/$DB_NAME?autoReconnect=true \
           --changeLogFile=$CHANGELOG_MSSP\
           --logFile=$VALIDATE_LOG\
           --logLevel=debug validate
    echo "Command Status"$?
  fi
COMMAND_STATUS=$?

  if [ $COMMAND_STATUS == 0 ]; then
       echo "COMMON Update action has been triggered!"
       /usr/bin/liquibase/liquibase \
              --username=$DB_USER \
              --password=$DB_PASSWORD \
              --url=jdbc:mariadb://$DB_SERVER:$DB_PORT/$DB_NAME?autoReconnect=true \
              --changeLogFile=$CHANGELOG_COMMON\
              --logFile=$COMMON_UPDATE_LOG\
              --logLevel=debug update
       echo; echo;
  fi
COMMAND_STATUS=$?

  if [[ $COMMAND_STATUS == 0 && $TENANT_TYPE == "MSSP" ]]; then
       echo "MSSP Update action has been triggered!"
       /usr/bin/liquibase/liquibase \
              --username=$DB_USER \
              --password=$DB_PASSWORD \
              --url=jdbc:mariadb://$DB_SERVER:$DB_PORT/$DB_NAME?autoReconnect=true \
              --changeLogFile=$CHANGELOG_MSSP\
              --logFile=$MSSP_UPDATE_LOG\
              --logLevel=debug update
       echo; echo;
  fi

      /usr/bin/liquibase/liquibase \
           --username=$DB_USER \
            --password=$DB_PASSWORD \
           --url=jdbc:mariadb://$DB_SERVER:$DB_PORT/$DB_NAME?autoReconnect=true \
           --logLevel=info history

}

DB_SERVER=$1
DB_PORT=$2
DB_NAME=$3
DB_USER=$4
DB_PASSWORD=$5
VERSION=$6
TENANT_TYPE=$7
CHANGELOG_COMMON="changelog_${VERSION}.xml"
CHANGELOG_MSSP="changelog_$VERSION""_mssp.xml"
currentDate=`date +"%Y-%m-%d_%H_%M"`
VALIDATE_LOG="liquibase-validate-$DB_NAME-$currentDate.log"
COMMON_UPDATE_LOG="liquibase-update-COMMON-$DB_NAME-$currentDate.log"
MSSP_UPDATE_LOG="liquibase-update-MSSP-$DB_NAME-$currentDate.log"

if [ "$#" -ne  7 ] ; then
  echo; echo; echo;
  echo "Incorrect number of parameters!";
  echo; echo;
  echo "Command usage is as follows:";
  echo "sh liquibase-utility server-name server_port schema-name user-name password version tenant_type";

  echo; echo;
  exit;
fi

setupLiquibase;

LIQUIBASE_COMMAND=''
echo "DB_SERVER="$DB_SERVER
echo "DB_NAME="$DB_NAME
echo "DB_USER="$DB_USER
echo "DB_PASSWORD="$DB_PASSWORD
echo "TENANT_TYPE="$TENANT_TYPE
echo "currentDate="$currentDate
echo "VALIDATE_LOG="$VALIDATE_LOG
update;