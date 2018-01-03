<?xml version="1.0" encoding="UTF-8"?>
<sch:schema
  xmlns:sch="http://purl.oclc.org/dsdl/schematron"
  xmlns:gmd="http://www.isotc211.org/2005/gmd"
  xmlns:gmi="http://www.isotc211.org/2005/gmi"
  xmlns:gco="http://www.isotc211.org/2005/gco"
  xmlns:gss="http://www.isotc211.org/2005/gss"
  xmlns:gml="http://www.opengis.net/gml/3.2"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:ism="urn:us:gov:ic:ism"
  xmlns:nas="http://metadata.ces.mil/dse/ns/GSIP/5.0/nas"
  xml:lang="en">
  
  <!-- 
    Excludes XML components that are optional in ISO/TS 19139
      (i.e., the minOccurs facet value is zero) and are excluded by the NMIS.
  -->
  
  <sch:title>NMIS GMD Profile Exclusion Schematron validation</sch:title>
  
  <sch:ns prefix="sch" uri="http://purl.oclc.org/dsdl/schematron"/>
  <sch:ns prefix="gmd" uri="http://www.isotc211.org/2005/gmd"/>
  <sch:ns prefix="gmi" uri="http://www.isotc211.org/2005/gmi"/>
  <sch:ns prefix="gco" uri="http://www.isotc211.org/2005/gco"/>
  <sch:ns prefix="gss" uri="http://www.isotc211.org/2005/gss"/>
  <sch:ns prefix="gml" uri="http://www.opengis.net/gml/3.2"/>
  <sch:ns prefix="xlink" uri="http://www.w3.org/1999/xlink"/>
  <sch:ns prefix="ism" uri="urn:us:gov:ic:ism"/>
  <sch:ns prefix="nas" uri="http://metadata.ces.mil/dse/ns/GSIP/5.0/nas"/>




<!-- ************************************************************************ -->
  <!-- ******** ISO 19115 Clause A.2.1 Metadata entity set information ******** -->
  <!-- ************************************************************************ -->
  
  <!-- This ISO 19115 rule is over-ridden based on the NMIS-specified extension of MD_Metadata. -->
  <sch:pattern id="Metadata_must_not_have_ExcludedContent">
    <sch:rule context="nas:MD_Metadata">
      <sch:assert test="not(gmd:language)">
        The metadata language element must not be used.</sch:assert>
      <sch:assert test="not(gmd:characterSet)">
        The metadata character set element must not be used.</sch:assert>

  <!-- Assertion no longer applicable in NMIS 2.1; now [0..1]
      <sch:assert test="not(gmd:parentIdentifier)">
        The metadata parent identifier element must not be used.</sch:assert>
    -->

  <!-- Assertion no longer applicable in NMIS 2.1; now [0..1]
      <sch:assert test="not(gmd:dataSetURI)">
        The metadata data set URI element must not be used.</sch:assert>
    -->
 
  <!-- Assertion no longer applicable in NMIS 2.1; now [0..*]
      <sch:assert test="not(gmd:contentInfo)">
        The metadata content information association/element must not be used.</sch:assert>
    -->

  <!-- Assertion no longer applicable in NMIS 2.1; now [0..1]
      <sch:assert test="not(gmd:distributionInfo)">
        The metadata distribution information association/element must not be used.</sch:assert>
    -->

  <!-- Assertion no longer applicable in NMIS 2.1; now [0..1]
      <sch:assert test="not(gmd:metadataMaintenanceInfo)">
        The metadata metadata maintenance information association/element must not be used.</sch:assert>
    -->

  <!-- Assertion no longer applicable in NMIS 2.1; now [0..*]
      <sch:assert test="not(gmd:spatialRepresentationInfo)">
        The metadata spatial representation information association/element must not be used.</sch:assert>
    -->
 
     <!-- MD_Metadata associations -->
     <sch:assert test="not(gmd:portrayalCatalogueInfo)">
        The metadata portrayal catalogue information association/element must not be used.</sch:assert>
      <sch:assert test="not(gmd:metadataExtensionInfo)">
        The metadata metadata extension information association/element must not be used.</sch:assert>

   </sch:rule>
  </sch:pattern>
  
  <!-- ******************************************************************* -->
  <!-- ******** ISO 19115 Clause A.2.2 Identification information ******** -->
  <!-- ******************************************************************* -->

  <!-- Over-ride ISO 19115 rule based on the NMIS-specified extension of MD_Identification. -->
  <sch:pattern id="DataIdentification_must_not_have_ExcludedContent">
    <sch:rule context="nas:MD_DataIdentification">
      <sch:assert test="not(gmd:purpose)">
        The data identification purpose element must not be used.</sch:assert>
      <sch:assert test="not(gmd:credit)">
        The data identification credit element must not be used.</sch:assert>
      <sch:assert test="not(gmd:status)">
        The data identification status element must not be used.</sch:assert>
      <!-- {abstract} MD_DataIdentification  --> 
      <sch:assert test="not(gmd:environmentDescription)">
        The data identification environment description element must not be used.</sch:assert>
      <sch:assert test="not(gmd:supplementalInformation)">
        The data identification supplemental information element must not be used.</sch:assert>
      <!-- {abstract} MD_Identification associations --> 
      <sch:assert test="not(gmd:graphicOverview)">
        The data identification graphic overview association/element must not be used.</sch:assert>

      <!-- Assertion no longer applicable in NMIS 2.1; now [0..*]
      <sch:assert test="not(gmd:resourceMaintenance)">
        The data identification resource maintenance association/element must not be used.</sch:assert>
        -->

      <sch:assert test="not(gmd:resourceSpecificUsage)">
        The data identification resource specific usage association/element must not be used.</sch:assert>      

      <!-- Assertion no longer applicable in NMIS 2.1; now [0..*]
      <sch:assert test="not(gmd:resourceFormat)">
        The data identification resource specific usage association/element must not be used.</sch:assert>
        -->

      </sch:rule>
  </sch:pattern>

  <sch:pattern id="AggregateInformation_must_not_have_ExcludedContent">
    <sch:rule context="gmd:MD_AggregateInformation">
      <sch:assert test="not(gmd:initiativeType)">
        The aggregate information initiative type element must not be used.</sch:assert>
    </sch:rule>
  </sch:pattern> 
  
  <!-- *************************************************************** -->
  <!-- ******** ISO 19115 Clause A.2.3 Constraint information ******** -->
  <!-- *************************************************************** -->
  
  <sch:pattern id="Constraints_must_not_have_ExcludedContent">
    <sch:rule context="gmd:MD_Constraints">
      <sch:assert test="not(gmd:useLimitation)">
        The use limitation constraint element must not be used.</sch:assert>
    </sch:rule>
  </sch:pattern>
  
  <sch:pattern id="SecurityConstraints_must_not_have_ExcludedContent">
    <sch:rule context="gmd:MD_SecurityConstraints">
      <sch:assert test="not(gmd:useLimitation)">
        The security constraints use limitation  element must not be used.</sch:assert>
      <sch:assert test="not(gmd:userNote)">
        The security constraints user note  element must not be used.</sch:assert>
      <sch:assert test="not(gmd:handlingDescription)">
        The security constraints handling description element must not be used.</sch:assert>
    </sch:rule>
  </sch:pattern>
  
  <sch:pattern id="LegalConstraints_must_not_have_ExcludedContent">
    <sch:rule context="gmd:MD_LegalConstraints">
      <sch:assert test="not(gmd:useLimitation)">
        The security constraints use limitation  element must not be used.</sch:assert>
      <sch:assert test="not(gmd:otherConstraints)">
        The legal constraints other constraints element must not be used.</sch:assert>
    </sch:rule>
  </sch:pattern>
  
  <!-- ***************************************************************** -->
  <!-- ******** ISO 19115 Clause A.2.4 Data quality information ******** -->
  <!-- ***************************************************************** -->
  
  <sch:pattern id="ScopeDescription_must_not_have_ExcludedContent">
    <sch:rule context="gmd:MD_ScopeDescription">
      <sch:assert test="not(attributes)">
        The scope description attributes elment must not be used.</sch:assert>
      <sch:assert test="not(features)">
        The scope description  features element must not be used.</sch:assert>
      <sch:assert test="not(featureInstances)">
        The scope description feature instances element must not be used.</sch:assert>
      <sch:assert test="not(attributeInstances)">
        The scope description attribute instances element must not be used.</sch:assert>
      <sch:assert test="not(dataset)">
        The scope description dataset element must not be used.</sch:assert>
    </sch:rule>
  </sch:pattern>
  
  <!-- NMIS 2.2 - rule removed to allow support for NMF Part 2
  <sch:pattern id="Scope_must_not_have_ExcludedContent">
    <sch:rule context="gmd:DQ_Scope">
      <sch:assert test="not(gmd:extent)">
        The scope extent element must not be used.</sch:assert>
    </sch:rule>
  </sch:pattern>-->

  <!-- NMIS 2.2 - rules removed to allow support for NMF Part 2  
  <sch:pattern id="DataQuality_must_not_have_ExcludedContent">
    <sch:rule context="gmd:DQ_DataQuality">
      <sch:assert test="not(gmd:report)">
        The data quality report association/element must not be used.</sch:assert>
    </sch:rule>
  </sch:pattern> 
  
  <sch:pattern id="Lineage_must_not_have_ExcludedContent">
    <sch:rule context="gmd:LI_Lineage">
      <sch:assert test="not(gmd:source)">
        The lineage source association/element must not be used.</sch:assert>
      <sch:assert test="not(gmd:processStep)">
        The lineage process step association/element must not be used.</sch:assert>
    </sch:rule>
  </sch:pattern> -->
  
  <!-- **************************************************************** -->
  <!-- ******** ISO 19115 Clause A.2.5 Maintenance information ******** -->
  <!-- **************************************************************** -->

  <sch:pattern id="MaintenanceInformation_must_not_have_ExcludedContent">
    <sch:rule context="gmd:MD_MaintenanceInformation">
      <sch:assert test="not(gmd:userDefinedMaintenanceFrequency)">
        The user defined maintenance frequency element must not be used.</sch:assert>
      <sch:assert test="not(gmd:updateScope)">
        The update scope element must not be used.</sch:assert>
      <sch:assert test="not(gmd:updateScopeDescription)">
        The update scope description element must not be used.</sch:assert>
      <sch:assert test="not(gmd:maintenanceNote)">
        The maintenance note element must not be used.</sch:assert>
    </sch:rule>
  </sch:pattern>

  <!-- *************************************************************************** -->
  <!-- ******** ISO 19115 Clause A.2.6 Spatial representation information ******** -->
  <!-- *************************************************************************** -->

  <sch:pattern id="VectorSpatialRepresentation_must_not_have_ExcludedContent">
    <sch:rule context="gmd:MD_VectorSpatialRepresentation">
      <sch:assert test="not(gmd:geometricObjects)">
        The geometric objects element must not be used.</sch:assert>
    </sch:rule>
  </sch:pattern>
  
  <!-- ********************************************************************* -->
  <!-- ******** ISO 19115 Clause A.2.7 Reference system information ******** -->
  <!-- ********************************************************************* -->
      <!-- Assertion no longer applicable in NMIS 2.1
	      - authority is now [0..1] (optional)
	      - version is now [0..1] (optional)
  <sch:pattern id="RsIdentifier_must_not_have_ExcludedContent">
    <sch:rule context="gmd:RS_Identifier">
      <sch:assert test="not(gmd:authority)">
        The reference system identifier authority element must not be used.</sch:assert>
      <sch:assert test="not(gmd:version)">
        The reference system identifier version element must not be used.</sch:assert>
    </sch:rule>
  </sch:pattern>
  -->

  <!-- ************************************************************ -->
  <!-- ******** ISO 19115 Clause A.2.8 Content information ******** -->
  <!-- ************************************************************ -->
   
 <sch:pattern id="FeatureCatalogueDiscription_must_not_have_ExcludedContent">
    <sch:rule context="gmd:MD_FeatureCatalogueDescription">
      <sch:assert test="not(gmd:complianceCode)">
        The compliance code element must not be used.</sch:assert>
      <sch:assert test="not(gmd:language)">
        The language element must not be used.</sch:assert>
      <sch:assert test="not(gmd:featureTypes)">
        The featur types element must not be used.</sch:assert>
    </sch:rule>
  </sch:pattern>

  <!-- ************************************************************************ -->
  <!-- ******** ISO 19115 Clause A.2.9 Portrayal catalogue information ******** -->
  <!-- ************************************************************************ -->
  <!-- To match NMF Profile, assert to disallow gmd:portrayalCatalogueInfo 
           occurs in A.2.1 --> 

  <!-- ****************************************************************** -->
  <!-- ******** ISO 19115 Clause A.2.10 Distribution information ******** -->
  <!-- ****************************************************************** -->
  
  <sch:pattern id="Format_must_not_have_ExcludedContent">
    <sch:rule context="gmd:MD_Format">
      <sch:assert test="not(gmd:amendmentNumber)">
        The format amendment number element must not be used.</sch:assert>
      <sch:assert test="not(gmd:specification)">
        The format specification element must not be used.</sch:assert>
      <sch:assert test="not(gmd:fileDecompressionTechnique)">
        The format file decompression technique element must not be used.</sch:assert>
    </sch:rule>
  </sch:pattern>
  
  <sch:pattern id="Distributor_must_not_have_ExcludedContent">
    <sch:rule context="gmd:MD_Distributor">
      <sch:assert test="not(gmd:distributionOrderProcess)">
        The distributor distribution order process association/element must not be used.</sch:assert>
    </sch:rule>
  </sch:pattern>
  
  <sch:pattern id="DigitalTransferOptions_must_be_validly_specified">
    <sch:rule context="//*">
      <sch:assert test="not(gmd:MD_DigitalTransferOptions)">
        Instantiations of Digital Transfer Options must use nas:NMF_DigitalTransferOptions.</sch:assert>
    </sch:rule>
  </sch:pattern>
  
  <!--<sch:pattern id="DigitalTransferOptions_must_not_have_ExcludedContent">
    <sch:rule context="gmd:MD_DigitalTransferOptions">
      <sch:assert test="not(gmd:unitsOfDistribution)">
        The digital transfer options units of distribution element must not be used.</sch:assert>
      <sch:assert test="not(gmd:offLine)">
        The digital transfer options off-line element must not be used.</sch:assert>
    </sch:rule>
  </sch:pattern>-->
  
  <sch:pattern id="NMF_DigitalTransferOptions_must_not_have_ExcludedContent">
    <sch:rule context="nas:NMF_DigitalTransferOptions">
      <sch:assert test="not(gmd:unitsOfDistribution)">
        The digital transfer options units of distribution element must not be used.</sch:assert>
      <sch:assert test="not(gmd:offLine)">
        The digital transfer options off-line element must not be used.</sch:assert>
    </sch:rule>
  </sch:pattern>
  
  <!-- ************************************************************************ -->
  <!-- ******** ISO 19115 Clause A.2.11 Metadata extension information ******** -->
  <!-- ************************************************************************ -->
      <!-- To match NMF Profile, assert to disallow gmd:metadataExtensionInfo 
           occurs in A.2.1 --> 
  
  <!-- ************************************************************************ -->
  <!-- ******** ISO 19115 Clause A.2.12 Application Schema information ******** -->
  <!-- ************************************************************************ -->
  
  <sch:pattern id="ApplicationSchemaInformation_must_not_have_ExcludedContent">
    <sch:rule context="gmd:MD_ApplicationSchemaInformation">
      <sch:assert test="not(gmd:schemaAscii)">
        The application schema information specification schema ASCII element must not be used.</sch:assert>
      <sch:assert test="not(gmd:graphicsFile)">
        The application schema information specification graphics file element must not be used.</sch:assert>
      <sch:assert test="not(gmd:softwareDevelopmentFile)">
        The application schema information specification software development file element must not be used.</sch:assert>
      <sch:assert test="not(gmd:softwareDevelopmentFileFormat)">
        The application schema information specification software development file format element must not be used.</sch:assert>
    </sch:rule>
  </sch:pattern>
  
  <!-- *********************************************************** -->
  <!-- ******** ISO 19115 Clause A.3.1 Extent information ******** -->
  <!-- *********************************************************** -->
  
  <sch:pattern id="Extent_must_not_have_ExcludedContent">
    <sch:rule context="gmd:EX_Extent">
      <sch:assert test="not(gmd:description)">
        The extent description element must not be used.</sch:assert>
    </sch:rule>
  </sch:pattern>
  
  <sch:pattern id="BoundingPoint_must_not_have_ExcludedContent">
    <!-- NMIS - Part 2, Table 5: ISO/TS 19139 Elements Extended for the NMIS (additional substitutable type) -->
    <sch:rule context="nas:BoundingPoint">
      <sch:assert test="not(gmd:extentTypeCode)">
        The bounding point extent type code element must not be used.</sch:assert>
    </sch:rule>
  </sch:pattern>
  
  <sch:pattern id="GeographicBoundingBox_must_not_have_ExcludedContent">
    <sch:rule context="gmd:EX_GeographicBoundingBox">
      <sch:assert test="not(gmd:extentTypeCode)">
        The geographic bounding box extent type code element must not be used.</sch:assert>
    </sch:rule>
  </sch:pattern>
  
  <sch:pattern id="BoundingPolygon_must_not_have_ExcludedContent">
    <sch:rule context="gmd:EX_BoundingPolygon">
      <sch:assert test="not(gmd:extentTypeCode)">
        The bounding polygon extent type code element must not be used.</sch:assert>
    </sch:rule>
  </sch:pattern>
  
  <sch:pattern id="GeographicDescription_must_not_have_ExcludedContent">
    <sch:rule context="gmd:EX_GeographicDescription">
      <sch:assert test="not(gmd:extentTypeCode)">
        The geographic description extent type code element must not be used.</sch:assert>
    </sch:rule>
  </sch:pattern>

  <sch:pattern id="TimePosition_must_not_have_ExcludedContent">
    <sch:rule context="gml:timePosition">
      <sch:assert test="not(@frame) or (@frame='#ISO-8601')">
        The time position frame attribute must not be used.</sch:assert>
      <sch:assert test="not(@calendarEraName)">
        The time position calendar era name attribute must not be used.</sch:assert>
    </sch:rule>
  </sch:pattern>
  
  <!-- *********************************************************************************** -->
  <!-- ******** ISO 19115 Clause A.3.2 Citation and responsible party information ******** -->
  <!-- *********************************************************************************** -->
  
  <sch:pattern id="Citation_must_not_have_ExcludedContent">
    <sch:rule context="gmd:CI_Citation">
  <!-- NMIS 2.2 - Remove assertion forbidding the use of alternateTitle  -->
      <!--<sch:assert test="not(gmd:alternateTitle)">
        The citation date alternate title element must not be used.</sch:assert>-->
      <sch:assert test="not(gmd:edition)">
        The citation date edition element must not be used.</sch:assert>
      <sch:assert test="not(gmd:editionDate)">
        The citation date edition date element must not be used.</sch:assert>
      <sch:assert test="not(gmd:presentationForm)">
        The citation date presentation form element must not be used.</sch:assert>
      <sch:assert test="not(gmd:otherCitationDetails)">
        The citation date other citation details element must not be used.</sch:assert>
      <sch:assert test="not(gmd:collectiveTitle)">
        The citation date collective title element must not be used.</sch:assert>
      <sch:assert test="not(gmd:ISBN)">
        The citation date ISBN element must not be used.</sch:assert>
      <sch:assert test="not(gmd:ISSN)">
        The citation date ISSN element must not be used.</sch:assert>
    </sch:rule>
  </sch:pattern>

  <sch:pattern id="Series_must_not_have_ExcludedContent">
    <sch:rule context="gmd:CI_Series">
      <sch:assert test="not(gmd:issueIdentification)">
        The series issue identification element must not be used.</sch:assert>
      <sch:assert test="not(gmd:page)">
        The series page element must not be used.</sch:assert>
    </sch:rule>
  </sch:pattern>
  
  <sch:pattern id="OnlineResource_not_have_ExcludedContent">
    <sch:rule context="gmd:CI_OnlineResource">
      <sch:assert test="not(gmd:applicationProfile)">
        The online resource application profile element must not be used.</sch:assert>
      <sch:assert test="not(gmd:description)">
        The online resource description element must not be used.</sch:assert>
      <sch:assert test="not(gmd:function)">
        The online resource function element must not be used.</sch:assert>
    </sch:rule>
  </sch:pattern>  
  
</sch:schema>
