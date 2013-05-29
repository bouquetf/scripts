#!/usr/bin/env groovy

import groovy.util.slurpersupport.GPathResult

/**
 * Test a connector definition and associated property files
 */

for (String connector_definition : args) {
    verify_definition(connector_definition)
}

/**
 * Check if definition is well formed
 * @param definition_name the path to the definition to check
 */
def verify_definition(String definition_name) {
    File resources = new File('./'+definition_name+'/src/main/resources')
    def files = resources.listFiles()
    def definitionFile = files.findAll() {it.name.endsWith('.def')}.get(0)
    def propertiesFiles = files.findAll {it.name.endsWith('.properties')}

    def xmlDef = new XmlSlurper().parse(definitionFile)
    for (def propertiesFile : propertiesFiles) {
        verify_properties(propertiesFile, xmlDef)
    }
}

/**
 * Check the property file
 * @param definition_name the path to the definition to check
 */
def verify_properties(File propertiesFile, GPathResult xmlDef) {
    PropertiesChecker propertiesChecker = new PropertiesChecker(propertiesFile)

    propertiesChecker.checkProperty('ERROR', 'Category', xmlDef.category.@id.text() + '.category')
    propertiesChecker.checkProperty('ERROR', 'Connector label (connectorDefinitionLabel)', 'connectorDefinitionLabel')
    propertiesChecker.checkProperty('ERROR', 'Connector description (connectorDefinitionDescription)', 'connectorDefinitionDescription')
}


class PropertiesChecker {
    File propertiesFile
    Properties properties

    PropertiesChecker(File propertiesFile) {
        this.propertiesFile = propertiesFile
        this.properties = new Properties()
        properties.load(new FileInputStream(propertiesFile))
    }

    public void checkProperty(String level, String propertyName, String property) {
        if (properties.getProperty(property) == null) {
            println("$level $propertyName is not set for ${propertiesFile.getName()}")
        }
    }
}
