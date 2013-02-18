STUDIO_URL="http://192.168.1.221:8080/view/Studio/job/BOS-Studio-Packaging-6.x/lastSuccessfulBuild/artifact/target/BOS-6.0-SNAPSHOT-All-in-one.zip"
WORK_DIR="/home/user/test_sessions/connectors"
STUDIO_ZIP="BOS-6.0-SNAPSHOT-All-in-one.zip"

cd ${WORK_DIR}
if [ -f ${STUDIO_ZIP} ] 
then
	rm -R ${WORK_DIR}/*
fi
wget $STUDIO_URL
unzip ${STUDIO_ZIP}
