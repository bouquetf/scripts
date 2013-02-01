#!/bin/sh

# !!! Modify this values according to your environment !!! #
TMPDIR=/home/user/tmp/test_connectors
CONNECTORS_SRC=/home/user/src/trunk/bonita-connectors
STUDIOVERSION=6.x_TYCHO
TRUNKVERSION=6.0.Beta.4-SNAPSHOT
STUDIO_NAME=org.bonitasoft.studio.product-linux.gtk.x86_64
BOS_URL="http://192.168.1.221:8080/view/Studio/job/BOS-Studio-6.x_TYCHO/lastSuccessfulBuild/artifact/releng/studio-repository/target/products/${STUDIO_NAME}.tar.gz"

CONNECTORS=${CONNECTORS_SRC}/bonita-connectors-package/target/bonita-connectors-package-${TRUNKVERSION}-package.zip
ORIGINALDIR=`pwd`
PLUGINS_DIR=${TMPDIR}/${STUDIO_NAME}/plugins
CONNECTORS_PLUGIN=org.bonitasoft.studio.connectors_1.0.0.201301311102
CONNECTORS_DIR=${PLUGINS_DIR}/${CONNECTORS_PLUGIN}


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
	mvn clean install -Palpha -DskipTests=true
	cd ${TMPDIR}
}

function download_studio() {
	if [ ! -f "org.bonitasoft.studio.product-linux.gtk.x86_64.tar.gz" ]
	then
		wget -c ${BOS_URL}
	fi
	cd ${TMPDIR}
}

function extract_studio() {
	if [ ! -d ${STUDIO_NAME} ]; then
		mkdir ${STUDIO_NAME}
		cd ${STUDIO_NAME}
		tar -xvzf ../${STUDIO_NAME}.tar.gz
	fi
	cd ${TMPDIR}
}

function reset_studio_connectors() {
	STUDIO_PLUGINS=${STUDIO_NAME}/plugins
	cd ${TMPDIR}/${STUDIO_PLUGINS}
	JARFILE=$(ls org.bonitasoft.studio.connectors_*.jar)
	PLUGINDIR=${JARFILE%%.jar}
	mkdir ${PLUGINDIR}
	cd ${PLUGINDIR}
	unzip ../${JARFILE}
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
