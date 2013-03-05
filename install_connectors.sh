#!/bin/sh

# !!! Modify this values according to your environment !!! #
CONNECTORS_PACKAGES=(bonita-connector-email bonita-connector-database bonita-connector-scripting bonita-connector-webservice bonita-connector-salesforce)
TMPDIR=/home/user/tmp/test_connectors
CONNECTORS_SRC=/home/user/src/trunk/bonita-connectors-6
STUDIOVERSION=6.x_TYCHO
TRUNKVERSION="6.0.0-Beta-001-SNAPSHOT"
#STUDIO_NAME="BOS-6.0-SNAPSHOT-All-in-one"
STUDIO_NAME="BOS-SP-6.0-SNAPSHOT-All-in-one"
#BOS_URL="http://192.168.1.221:8080/view/Studio/job/BOS-Studio-Packaging-6.x/lastSuccessfulBuild/artifact/target/${STUDIO_NAME}.zip"
BOS_URL="http://192.168.1.221:8080/view/Studio/job/BOS-SP-Studio-Packaging-6.x/lastSuccessfulBuild/artifact/target/${STUDIO_NAME}.zip"
CONNECTORS=${CONNECTORS_SRC}/bonita-connectors-package/target/bonita-connectors-package-${TRUNKVERSION}-package.zip
ORIGINALDIR=`pwd`
PLUGINS_DIR=${TMPDIR}/${STUDIO_NAME}/plugins
CONNECTORS_PLUGIN=
CONNECTORS_DIR=


function clean() {
	if [ ! -d "${TMPDIR}" ]; then
		mkdir -p ${TMPDIR}
	fi
	cd ${TMPDIR}
	rm -rf connectors
	rm -rf $STUDIO_NAME
}

function build_connectors() {
	cd ${CONNECTORS_SRC}
	cd bonita-connectors
	mvn clean install -DskipTests=true
	cd ..
	cd connectors
	for folder in ${CONNECTORS_PACKAGES}
	do
		cd "$folder"
		mvn clean install -DskipTests=true
		cd ..
	done
	cd ..
	cd bonita-connectors-package
	mvn clean install -DskipTests=true
	cd ${TMPDIR}
}

function download_studio() {
	if [ ! -f ${STUDIO_NAME}.zip ]
	then
		wget -c ${BOS_URL}
	fi
	cd ${TMPDIR}
}

function extract_studio() {
	if [ ! -d ${STUDIO_NAME} ]; then
		unzip ${STUDIO_NAME}.zip
	fi
	cd ${TMPDIR}
}

function reset_studio_connectors() {
	STUDIO_PLUGINS=${STUDIO_NAME}/plugins
	cd ${TMPDIR}/${STUDIO_PLUGINS}
	JAR_FILE=$(ls org.bonitasoft.studio.connectors_*.jar)
	CONNECTORS_PLUGIN=${JAR_FILE%%.jar}
	mkdir ${CONNECTORS_PLUGIN}
	cd ${CONNECTORS_PLUGIN}
	CONNECTORS_DIR=${PLUGINS_DIR}/${CONNECTORS_PLUGIN}
	unzip ../${JAR_FILE}
	rm connectors-def/*
	rm connectors-impl/*
	rm dependencies/*
	cd ${TMPDIR}
}

function install_connectors() {
	mkdir connectors
	cd connectors
	unzip ${CONNECTORS}
	for connector_zip in $(ls *.zip)
	do
		mkdir ${connector_zip%%.zip}
		cd ${connector_zip%%.zip}
		unzip ../${connector_zip}
		mv classpath/* ${CONNECTORS_DIR}/dependencies
		rmdir classpath
		mv *.impl ${CONNECTORS_DIR}/connectors-impl
		mv * ${CONNECTORS_DIR}/connectors-def
		cd ..
	done
	cd ${PLUGINS_DIR}
	rm ${CONNECTORS_PLUGIN}.jar
	cd ${CONNECTORS_DIR}
	echo Creating jar file : ${CONNECTORS_PLUGIN}.jar
	jar cvmf META-INF/MANIFEST.MF ${CONNECTORS_PLUGIN}.jar *
	mv ${CONNECTORS_PLUGIN}.jar ..
	cd ..
	rm -R ${CONNECTORS_DIR}
	cd ${TMPDIR}
}

cd ${TMPDIR}
clean
download_studio
extract_studio
if [ $# -ne 1 ] 
then
	build_connectors
fi
reset_studio_connectors
install_connectors
