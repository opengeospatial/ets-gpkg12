<?xml version="1.0" encoding="UTF-8"?>
<sch:schema
  xmlns:sch="http://purl.oclc.org/dsdl/schematron"
  xmlns:gmd="http://www.isotc211.org/2005/gmd"
  xmlns:gco="http://www.isotc211.org/2005/gco"
  xmlns:gss="http://www.isotc211.org/2005/gss"
  xmlns:gmi="http://www.isotc211.org/2005/gmi"
  xmlns:gml="http://www.opengis.net/gml/3.2"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:ism="urn:us:gov:ic:ism"
  xmlns:nas="http://metadata.ces.mil/dse/ns/GSIP/5.0/nas"
  xml:lang="en">
  
  <!-- ************************************************************************* -->
  <!-- ******** Only intended for use with NMIS - Part 2, Version 2.1.0 ******** -->
  <!-- ************************************************************************* -->
  
  <!-- 
    Restricts code lists to those defined by DSE-based authoritative namespaces
      as specified in NMIS - Part 2, Table 10 and Annex B.3.4.
    Restricts some uses of the CharacterString data type to those specified in
      NMIS - Part 2, Table 6 and Table 7.
    Restricts content based on constraints that cannot be enforced using XSD.
  -->
  
  <sch:title>NMIS Schematron validation</sch:title>
  
  <sch:ns prefix="sch" uri="http://purl.oclc.org/dsdl/schematron"/>
  <sch:ns prefix="gmd" uri="http://www.isotc211.org/2005/gmd"/>
  <sch:ns prefix="gco" uri="http://www.isotc211.org/2005/gco"/>
  <sch:ns prefix="gss" uri="http://www.isotc211.org/2005/gss"/>
  <sch:ns prefix="gml" uri="http://www.opengis.net/gml/3.2"/>
  <sch:ns prefix="genc" uri="http://api.nsgreg.nga.mil/schema/genc/2.0"/>
  <sch:ns prefix="genc-cmn" uri="http://api.nsgreg.nga.mil/schema/genc/2.0/genc-cmn"/>
  <sch:ns prefix="xlink" uri="http://www.w3.org/1999/xlink"/>
  <sch:ns prefix="ism" uri="urn:us:gov:ic:ism"/>
  <sch:ns prefix="nas" uri="http://metadata.ces.mil/dse/ns/GSIP/5.0/nas"/>
  <sch:ns prefix="gmi" uri="http://www.isotc211.org/2005/gmi"/>
  <sch:ns prefix="reg" uri="http://api.nsgreg.nga.mil/schema/register/1.0"/>
  
  <!--
    Note that the paths in the following are for referencing
    codelists and therefore continue to use the 'mdr' path-component
    since that's how these resources are currently specified in the MDR.
    This will change in the next NMIS release to instead use the NSG Standards
    Registry component: Information Resources (IR) Registry.
  -->
  <sch:let name="GSIP" value="'http://metadata.ces.mil/mdr/ns/GSIP'"/>
  <sch:let name="NSGREG" value="'http://api.nsgreg.nga.mil'"/>
  
  <sch:let name="scope_content" value="(//gmd:DQ_DataQuality/gmd:scope/gmd:DQ_Scope/gmd:level/gmd:MD_ScopeCode/@codeListValue='dataset') or (//gmd:DQ_DataQuality/gmd:scope/gmd:DQ_Scope/gmd:level/gmd:MD_ScopeCode/@codeListValue='series')"/>
  <sch:let name="NMF_part2_profile" value="(//gmd:DQ_DataQuality/gmd:report) or (//gmd:DQ_DataQuality/gmd:lineage/gmd:LI_Lineage/gmd:processStep) or (//gmd:DQ_DataQuality/gmd:lineage/LI_Lineage/gmd:source)"/>
  <sch:let name="NMF_part3_profile" value="(//gmi:MI_Georectified) or (//gmi:MI_Georeferenceable) or (//gmd:MD_CoverageDescription) or (//gmi:MI_ImageDescription) or (//gmi:MI_AcquisitionInformation)"/>
  
  <!-- Verify that this is version 2.2  -->
  <sch:pattern id="VersionCheck">
    <sch:rule context="nas:MD_Metadata">
      <sch:assert test="(gmd:metadataStandardVersion/*) and 
                        contains(gmd:metadataStandardVersion, '2.2')">
      NMIS version must be 2.2 </sch:assert>
    </sch:rule>
  </sch:pattern>
  
  <!-- ************************************************************************ -->
  <!-- ******** ISO 19115 Clause A.2.1 Metadata entity set information ******** -->
  <!-- ************************************************************************ -->

  <sch:pattern id="Metadata_must_have_Content">
    <!-- Over-ride ISO 19115 rule based on the NMIS-specified extension of MD_Metadata. -->
    <sch:rule context="nas:MD_Metadata">
      <sch:assert test="not(gmd:fileIdentifier) or ((gmd:fileIdentifier/gco:CharacterString) and (string-length(normalize-space(gmd:fileIdentifier/gco:CharacterString)) &gt; 0))">
        The metadata file identifier, if present, must have non-empty string content.</sch:assert>
      <sch:assert test="not(gmd:hierarchyLevel) or (gmd:hierarchyLevel/*)">
        The metadata hierarchy level, if present, must have content.</sch:assert>
      <sch:assert test="not(gmd:hierarchyLevelName) or (gmd:hierarchyLevelName/*)">
        The metadata hierarchy level name, if present, must have content.</sch:assert>
      <sch:assert test="(gmd:contact/@xlink:href) or (gmd:contact/*)">
        The metadata contact must have content.</sch:assert>
      <sch:assert test="gmd:dateStamp/*">
        The metadata date stamp must have content.</sch:assert>
      <sch:assert test="not(gmd:metadataStandardName) or (gmd:metadataStandardName/*)">
        The metadata metadata standard name, if present, must have content.</sch:assert>
      <sch:assert test="not(gmd:metadataStandardVersion) or ((gmd:metadataStandardVersion/nas:MetadataStandardVersion) and (string-length(normalize-space(gmd:metadataStandardVersion/nas:MetadataStandardVersion)) &gt; 0))">
        The metadata metadata standard version, if present, must have non-empty string content.</sch:assert>
      <sch:assert test="not(gmd:locale) or (gmd:locale/*)">
        The metadata locale, if present, must have content.</sch:assert>
      <!-- MD_Metadata associations -->
      <sch:assert test="not(gmd:applicationSchemaInfo) or (gmd:applicationSchemaInfo/*)">
        The metadata application schema information association/element, if present, must have content.</sch:assert>
      <sch:assert test="not(gmd:dataQualityInfo) or (gmd:dataQualityInfo/*)">
        The metadata data quality information association/element, if present, must have content.</sch:assert>
      <sch:assert test="gmd:identificationInfo/*">
        The metadata identification information association/element must have content.</sch:assert>
      <sch:assert test="not(gmd:metadataConstraints) or (gmd:metadataConstraints/*)">
        The metadata constraints association/element, if present, must have content.</sch:assert>
      <sch:assert test="not(gmd:referenceSystemInfo) or (gmd:referenceSystemInfo/*)">
        The metadata reference system information association/element, if present, must have content.</sch:assert>
    </sch:rule>
  </sch:pattern>
  
  <sch:pattern id="NasMetadata_has_correct_element_multiplicities">
    <!-- ******** ISO 19115 Multiplicity Over-rides for NAS-specific elements ******** -->
    <sch:rule context="nas:MD_Metadata">
		<sch:assert test="(gmd:hierarchyLevel/* and (count(gmd:hierarchyLevel) = 1)) and (gmd:hierarchyLevelName/* and (count(gmd:hierarchyLevelName) = 1))">
			The resource metadata must include exactly one hierarchy level and hierarchy level name, with content.</sch:assert>
		<sch:assert test="gmd:metadataStandardName/* and gmd:metadataStandardVersion/*">
			The resource metadata must include a metadata standard name and version, with content.</sch:assert>
	<!--  NMIS 2.2 Remove assertion making locale mandatory -->
		<!--<sch:assert test="gmd:locale/* and (count(gmd:locale) = 1)">
			The resource metadata must include exactly one locale, with content.</sch:assert>-->
		<sch:assert test="not(gmd:applicationSchemaInfo) or gmd:applicationSchemaInfo/*">
			The application schema information association/element, if present, must have content.</sch:assert>
		<sch:assert test="gmd:metadataConstraints/* and (count(gmd:metadataConstraints) &lt;= 2)">
			The resource metadata must include either 1 or 2 resource constraints, with content.</sch:assert>
		<sch:assert test="gmd:identificationInfo/*">
			The identification information association/element must have content.</sch:assert>
		<sch:assert test="not(gmd:referenceSystemInfo) or gmd:referenceSystemInfo/*">
			The reference system information association/element, if present, must have content.</sch:assert>
		<sch:assert test="not(gmd:dataQualityInfo) or gmd:dataQualityInfo/*">
			The data quality information association/element, if present, must have content.</sch:assert>
    <!-- ******** ISO 19115 Multiplicity Over-rides for NAS-specific elements added for NMF Part 2 and 3 profiles ******** -->
		<sch:assert test="not(gmd:parentIdentifier) or ((gmd:parentIdentifier/gco:CharacterString) and (string-length(normalize-space(gmd:parentIdentifier/gco:CharacterString)) &gt; 0))">
			The metadata parent identifier, if present, must have non-empty string content.</sch:assert>
		<sch:assert test="not(gmd:dataSetURI) or ((gmd:dataSetURI/gco:CharacterString) and (string-length(normalize-space(gmd:dataSetURI/gco:CharacterString)) &gt; 0))">
			The metadata data set URI, if present, must have non-empty string content.</sch:assert>
		<sch:assert test="not(gmd:spatialRepresentationInfo) or (gmd:spatialRepresentationInfo/*)">
			The metadata spatial representation information, if present, must have content.</sch:assert>
		<sch:assert test="not(gmd:contentInfo) or (gmd:contentInfo/*)">
			The metadata content information, if present, must have content.</sch:assert>
		<sch:assert test="not(gmd:distributionInfo) or (gmd:distributionInfo/*)">
			The metadata distribution information, if present, must have content.</sch:assert>
		<sch:assert test="not(gmd:metadataMaintenance) or (gmd:metadataMaintenance/*)">
			The metadata maintenance, if present, must have content.</sch:assert>
		<sch:assert test="not(gmi:acquisitionInformation) or (gmi:acquisitionInformation/*)">
			The metadata acquisition information, if present, must have content.</sch:assert>
    </sch:rule>
  </sch:pattern>

  <sch:pattern id="Metadata_must_not_have_ExcludedContent">
    <!-- Over-ride ISO 19115 rule based on the NMIS-specified extension of MD_Metadata. -->
    <sch:rule context="nas:MD_Metadata">
      <sch:assert test="not(gmd:language)">
        The metadata language element must not be used.</sch:assert>
      <sch:assert test="not(gmd:characterSet)">
        The metadata character set element must not be used.</sch:assert>
<!-- NMIS 2.1 Remove assertions prohibiting parent identifier and dataSetURI 
        <sch:assert test="not(gmd:parentIdentifier)">
        The metadata parent identifier element must not be used.</sch:assert>
      <sch:assert test="not(gmd:dataSetURI)">
        The metadata data set URI element must not be used.</sch:assert>
        -->
      <!-- MD_Metadata associations -->
<!-- NMIS 2.1  Remove assertion prohibiting content information
        <sch:assert test="not(gmd:contentInfo)">
        The metadata content information association/element must not be used.</sch:assert>
-->
<!-- NMIS 2.1  Remove assertion prohibiting distribution information
        <sch:assert test="not(gmd:distributionInfo)">
        The metadata distribution information association/element must not be used.</sch:assert>
-->
<sch:assert test="not(gmd:portrayalCatalogueInfo)">
        The metadata portrayal catalogue information association/element must not be used.</sch:assert>
      <sch:assert test="not(gmd:metadataExtensionInfo)">
        The metadata metadata extension information association/element must not be used.</sch:assert>
 <!--  NMIS 2.1 Remove assertion prohibiting metadata maintenance information
   <sch:assert test="not(gmd:metadataMaintenanceInfo)">
        The metadata metadata naintenance information association/element must not be used.</sch:assert>
-->
<!--  NMIS 2.1 Remove assertion prohibiting spatial representation information
<sch:assert test="not(gmd:spatialRepresentationInfo)">
        The metadata spatial representation information association/element must not be used.</sch:assert>
-->
    </sch:rule>
  </sch:pattern>

  <sch:pattern id="HierarchyLevel_dataset_implies_TopicCategory">
    <!-- Over-ride ISO 19115 rule based on the NMIS-specified extension of MD_DataIdentification -->
    <sch:rule context="nas:MD_Metadata">
      <sch:assert test="not(gmd:hierarchyLevel/gmd:MD_ScopeCode/@codeListValue='dataset') or ((gmd:hierarchyLevel/gmd:MD_ScopeCode/@codeListValue='dataset') and (gmd:identificationInfo/nas:MD_DataIdentification/gmd:topicCategory/*))">
        The metadata hierarchy level is 'dataset' therefore topic categories must be specified.</sch:assert>
    </sch:rule>
  </sch:pattern>

  <sch:pattern id="HierarchyLevel_dataset_implies_Extent">
    <sch:rule context="nas:MD_Metadata">
      <!-- If the hierarchyLevel element value is "dataset" then at least either the bounding box or point shall be populated. -->
      <!-- Note: ISO 19115 states that this "shall" is contingent on the dataset being spatially referenced. -->
      <sch:assert test="not((gmd:hierarchyLevel/gmd:MD_ScopeCode/@codeListValue='dataset') and (gmd:referenceSystemInfo/*)) or 
        (((gmd:hierarchyLevel/gmd:MD_ScopeCode/@codeListValue='dataset') and (gmd:referenceSystemInfo/*))
        and (gmd:identificationInfo/nas:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:geographicElement/gmd:EX_GeographicBoundingBox or
        gmd:identificationInfo/nas:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:geographicElement/nas:BoundingPoint))">
        The metadata hierarchy level is 'dataset' and there is a spatial reference system therefore the extent must be specified at least as either a bounding box or a point.</sch:assert>
      <!-- If the hierarchyLevel element value is "series" then at least either the bounding box or polygon shall be populated. -->
      <sch:assert test="not((gmd:hierarchyLevel/gmd:MD_ScopeCode/@codeListValue='series') and (gmd:referenceSystemInfo/*)) or 
        (((gmd:hierarchyLevel/gmd:MD_ScopeCode/@codeListValue='series') and (gmd:referenceSystemInfo/*))
        and (gmd:identificationInfo/nas:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:geographicElement/gmd:EX_GeographicBoundingBox or
        gmd:identificationInfo/nas:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:geographicElement/gmd:EX_BoundingPolygon))">
        The metadata hierarchy level is 'series' and there is a spatial reference system therefore the extent must be specified at least as either a bounding box or a polygon.</sch:assert>
    </sch:rule>
  </sch:pattern>
  
  <sch:pattern id="MD_Metadata_contact_must_adhere_to_business_rule">
    <sch:rule context="nas:MD_Metadata">
      <sch:assert test="(count(gmd:contact) &lt;2) or (gmd:contact[position()=1]/gmd:CI_ResponsibleParty/gmd:role/gmd:CI_RoleCode/@codeListValue = 'pointOfContact')">
        When multiple contact elements are present, the first element shall use the role code &quot;pointOfcontact&quot;</sch:assert>
    </sch:rule>
  </sch:pattern>
 
  <sch:pattern id="HierarchyLevelName_uses_ScopeAmplificationCode">
    <!-- NMIS - Part 2, Table 7: ISO/TS 19139 Character String Properties instantiated using a Code List -->
    <sch:rule context="gmd:hierarchyLevelName">
      <sch:assert test="nas:ScopeAmplificationCode">
        All hierarchy level names shall have a scope amplification code as their content.</sch:assert>
    </sch:rule>
  </sch:pattern>
  
  <sch:pattern id="MetadataStandardName_uses_MetadataStandardNameCode">
    <!-- NMIS - Part 2, Table 7: ISO/TS 19139 Character String Properties instantiated using a Code List -->
    <sch:rule context="gmd:metadataStandardName">
      <sch:assert test="nas:MetadataStandardNameCode">
        All metadata standard names shall have a metadata standard name code as their content.</sch:assert>
    </sch:rule>
  </sch:pattern>
  
  <sch:pattern id="MetadataStandardVersion_follows_Pattern">
    <!-- NMIS - Part 2, Table 6: ISO/TS 19139 Character String Properties instantiated using a Pattern-restriction -->
    <sch:rule context="gmd:metadataStandardVersion">
      <sch:assert test="nas:MetadataStandardVersion">
        All metadata standard version content shall be constrained to the Major.Minor.Corrigendum pattern.</sch:assert>
    </sch:rule>
  </sch:pattern>
  
  <!-- ******************************************************************* -->
  <!-- ******** ISO 19115 Clause A.2.2 Identification information ******** -->
  <!-- ******************************************************************* -->
  
  <sch:pattern id="DataIdentification_must_have_Content">
    <!-- Over-ride ISO 19115 rule based on the NMIS-specified extension of MD_DataIdentification. -->
    <sch:rule context="nas:MD_DataIdentification">
      <sch:assert test="gmd:citation/*">
        The data identification citation must have content.</sch:assert>
      <sch:assert test="gmd:abstract/gco:CharacterString and (string-length(normalize-space(gmd:abstract/gco:CharacterString)) &gt; 0)">
        The data identification abstract must have non-empty string content.</sch:assert>
      <sch:assert test="gmd:pointOfContact/*">
        The data identification point of contact must have content.</sch:assert>
      <sch:assert test="not(gmd:spatialRepresentationType) or (gmd:spatialRepresentationType/*)">
        The data identification spatial representation type, if present, must have content.</sch:assert>
      <sch:assert test="not(gmd:spatialResolution) or (gmd:spatialResolution/*)">
        The data identification spatial resolution, if present, must have content.</sch:assert>
      <sch:assert test="gmd:language/*">
        The data identification language must have content.</sch:assert>
      <sch:assert test="gmd:characterSet/*">
        The data identification character set must have content.</sch:assert>
      <sch:assert test="not(gmd:topicCategory) or (gmd:topicCategory/*)">
        The data identification topic category, if present, must have content.</sch:assert>
      <sch:assert test="not(gmd:extent) or (gmd:extent/*)">
        The data identification extent must have content.</sch:assert>
      <!-- {abstract} MD_Identification associations -->
      <sch:assert test="not(gmd:aggregationInfo) or (gmd:aggregationInfo/*)">
        The data identification aggregation information association/element, if present, must have content.</sch:assert>
      <sch:assert test="not(gmd:descriptiveKeywords) or (gmd:descriptiveKeywords/*)">
        The data identification descriptive keywords association/element, if present, must have content.</sch:assert>
      <sch:assert test="not(gmd:resourceConstraints) or (gmd:resourceConstraints/*)">
        The data identification resource constraints association/element, if present, must have content.</sch:assert>
      <sch:assert test="not(gmd:resourceFormat) or (gmd:resourceFormat/*)">
        The data identification resource format association/element, if present, must have content.</sch:assert>
    </sch:rule>
  </sch:pattern>
  
  <sch:pattern id="NasDataIdentification_has_correct_element_multiplicities">
    <!-- ******** ISO 19115 Multiplicity Over-rides for NAS-specific elements ******** -->
    <sch:rule context="nas:MD_DataIdentification">
      <sch:assert test="gmd:pointOfContact/* and gmd:descriptiveKeywords/*">
        The data identification must include a point of contact and descriptive keywords, with content.</sch:assert>
      <sch:assert test="gmd:resourceConstraints/* and (count(gmd:resourceConstraints) &lt;= 2)">
        The data identification must include either 1 or 2 resource constraints, with content.</sch:assert>
      <sch:assert test="gmd:characterSet/*">
        The data identification must include at least one character set, with content.</sch:assert>
      <!-- NMIS - Part 2, Table 5: ISO/TS 19139 Elements Extended for the NMIS (added element) -->
      <sch:assert test="nas:languageCountry/*">
        The data identification must include at least one language country, with content.</sch:assert>
    </sch:rule>
  </sch:pattern>
  
  <sch:pattern id="NasDataIdentification_must_have_Consistent_LocaleElement_Counts">
    <!-- ******** ISO 19115 Multiplicity Over-rides for NAS-specific elements ******** -->
    <sch:rule context="nas:MD_DataIdentification">
      <sch:assert test="count(gmd:language) = count(gmd:characterSet)">
        The sets of language codes and character encodings must have the same number of elements.</sch:assert>
      <sch:assert test="count(gmd:language) = count(nas:languageCountry)">
        The sets of language codes and countries must have the same number of elements.</sch:assert>
    </sch:rule>
  </sch:pattern> 
  
  <sch:pattern id="MD_DataIdentificationLanguage_uses_LanguageCode">
	  <sch:rule context="nas:MD_DataIdentification/gmd:language">
		  <sch:assert test="gmd:LanguageCode">
			  All MD_DataIdentification language descriptions shall have a language code as their content</sch:assert>
	  </sch:rule>
  </sch:pattern>
  
  <sch:pattern id="DataIdentification_must_not_have_ExcludedContent">
    <!-- Over-ride ISO 19115 rule based on the NMIS-specified extension of MD_DataIdentification. -->
    <sch:rule context="nas:MD_DataIdentification">
      <sch:assert test="not(gmd:purpose)">
        The data identification purpose element must not be used.</sch:assert>
      <sch:assert test="not(gmd:credit)">
        The data identification credit element must not be used.</sch:assert>
      <sch:assert test="not(gmd:status)">
        The data identification status element must not be used.</sch:assert>
      <sch:assert test="not(gmd:environmentDescription)">
        The data identification environment description element must not be used.</sch:assert>
      <sch:assert test="not(gmd:supplementalInformation)">
        The data identification supplemental information element must not be used.</sch:assert>
      <!-- {abstract} MD_Identification associations -->
      <sch:assert test="not(gmd:graphicOverview)">
        The data identification graphic overview association/element must not be used.</sch:assert>

<!--   NMIS 2.1 Remove assertion prohibiting resourceMaintenance
      <sch:assert test="not(gmd:resourceMaintenance)">
        The data identification resource maintenance association/element must not be used.</sch:assert>
-->
      <sch:assert test="not(gmd:resourceSpecificUsage)">
        The data identification resource specific usage association/element must not be used.</sch:assert>
    </sch:rule>
  </sch:pattern>
    
    <sch:pattern id="ResourceConstraints_MD_Constraints_subclass_multiplicity">
		<sch:rule context="nas:MD_DataIdentification">
			<sch:assert test="not(gmd:resourceConstraints/gmd:MD_LegalConstraints/* or gmd:resourceConstraints/nas:MD_SecurityConstraints/*) or ((gmd:resourceConstraints/gmd:MD_LegalConstraints/* or gmd:resourceConstraints/nas:MD_SecurityConstraints/*) and (count(gmd:resourceConstraints/gmd:MD_LegalConstraints) &lt; 2) and (count(gmd:resourceConstraints/nas:MD_SecurityConstraints) &lt; 2))">
				Sub-classes of MD_Constraints can each only have one instance.</sch:assert>
		</sch:rule>
    </sch:pattern>
  
  <!-- *************************************************************** -->
  <!-- ******** ISO 19115 Clause A.2.3 Constraint information ******** -->
  <!-- *************************************************************** -->
  
  <sch:pattern id="ResourceCapcoMarking_corresponds">
    <!-- NMIS - Part 2, Table 5: ISO/TS 19139 Elements Extended for the NMIS (security constraints) --> 
    <sch:rule context="nas:MD_Metadata">
      <sch:assert test="@ism:createDate = gmd:dateStamp/gco:Date">
        The metadata root must be ism-marked with the same creation date as that specified in the metadata date stamp.</sch:assert>
      <sch:assert test="@ism:classification = gmd:metadataConstraints/nas:MD_SecurityConstraints/nas:capcoMarking/@ism:classification">
        The metadata root must be ism-marked with the same classification as that specified in the metadata constraints.</sch:assert>
      <sch:assert test="@ism:ownerProducer = gmd:metadataConstraints/nas:MD_SecurityConstraints/nas:capcoMarking/@ism:ownerProducer">
        The metadata root must be ism-marked with the same owner/producer as that specified in the metadata constraints.</sch:assert>
    </sch:rule>
  </sch:pattern>
  
  <sch:pattern id="SecurityConstraints_must_not_have_ExcludedContent">
    <sch:rule context="nas:MD_SecurityConstraints">
      <sch:assert test="not(gmd:useLimitation)">
        The security constraints use limitation  element must not be used.</sch:assert>
      <sch:assert test="not(gmd:userNote)">
        The security constraints user note  element must not be used.</sch:assert>
      <sch:assert test="not(gmd:handlingDescription)">
        The security constraints handling description element must not be used.</sch:assert>
    </sch:rule>
  </sch:pattern>
  
  <sch:pattern id="SecurityConstraintsClassificationCode_corresponds">
    <!-- NMIS - Part 2, Table 5: ISO/TS 19139 Elements Extended for the NMIS (security constraints) --> 
    <sch:rule context="nas:MD_SecurityConstraints">
      <sch:assert test="(not(nas:capcoMarking/@ism:classification = 'U')) or ((nas:capcoMarking/@ism:classification = 'U') and (gmd:classification/gmd:MD_ClassificationCode/@codeListValue = 'unclassified'))">
        The ISO 19115 security constraints classification must match the ism:classification, respectively 'unclassified' and 'U'.</sch:assert>
      <sch:assert test="(nas:capcoMarking/@ism:classification = 'U') or (not(nas:capcoMarking/@ism:classification = 'U') and (gmd:classification/gmd:MD_ClassificationCode/@codeListValue = 'classified'))">
        The ISO 19115 security constraints classification must match the ism:classification, respectively 'classified' and other than 'U'.</sch:assert>
    </sch:rule>
  </sch:pattern>
  
  <sch:pattern id="SecurityConstraintsClassificationSystem_is_US_CAPCO">
    <!-- NMIS - Part 2, Table 6: ISO/TS 19139 Character String Properties instantiated using a Pattern-restriction -->
    <sch:rule context="nas:MD_SecurityConstraints/gmd:classificationSystem">
      <sch:assert test="nas:ClassificationSystem">
        The security constraints classification system content shall be constrained to the restricted-value 'US CAPCO' pattern.</sch:assert>
    </sch:rule>
  </sch:pattern>
    
    <sch:pattern id="MetadataConstraints_MD_Constraints_subclass_multiplicity">
		<sch:rule context="gmd:metadataConstraints">
			<sch:assert test="not(gmd:MD_LegalConstraints/* or nas:MD_SecurityConstraints/*) or ((gmd:MD_LegalConstraints/* or nas:MD_SecurityConstraints/*) and (count(gmd:MD_LegalConstraints) &lt; 2) and (count(nas:MD_SecurityConstraints) &lt; 2))">
				Sub-classes of MD_Constraints can each only have one instance.</sch:assert>
		</sch:rule>
    </sch:pattern>
  
  <!-- ***************************************************************** -->
  <!-- ******** ISO 19115 Clause A.2.4 Data quality information ******** -->
  <!-- ***************************************************************** -->

  <sch:pattern id="DataQualityLineage_must_be_validly_specified">
    <!-- Over-ride ISO 19115 rule based on the NMIS-specified proscription of gmd:LI_Source and gmd:LI_ProcessStep. -->
    <sch:rule context="gmd:DQ_DataQuality">
      <sch:assert test="($NMF_part2_profile or (not($NMF_part2_profile) and (not($scope_content) or ($scope_content and (gmd:lineage/gmd:LI_Lineage/gmd:statement/gco:CharacterString) ) )))">
        Profiling the NMF Part 1 Core, the data quality scope is 'dataset' or 'series', however no lineage statement is specified.</sch:assert>
    </sch:rule>
  </sch:pattern>
  
  <!-- Part 2 Quality rule : This ISO 19115 rule is over-ridden based on the NMIS-specified proscription of gmd:LI_Source and gmd:LI_ProcessStep.-->
  <!-- Part 2 adds additional report requirement - NMF Part 2 Quality Metadata - Section 7.4.1 -->
    <sch:pattern id="DataQuality_LineageAndReport_must_be_validly_specified">
		<sch:rule context="gmd:DQ_DataQuality">
			<sch:assert test="not($NMF_part2_profile) or ($NMF_part2_profile and (not($scope_content) or ($scope_content and (gmd:report/* or ((count(gmd:lineage/gmd:LI_Lineage/gmd:source/*) &gt; 0) or (count(gmd:lineage/gmd:LI_Lineage/gmd:processStep/*) &gt; 0) or gmd:lineage/gmd:LI_Lineage/gmd:statement))) ))">
			  Profiling the NMF Part 2, the data quality scope is 'dataset' or 'series' and there is no specified report information and no lineage information (source or process step information, and no lineage statement is specified).
			</sch:assert>
      </sch:rule>
    </sch:pattern>
  
  <!--  NMIS 2.2 - LevelDescription is more specifically specified using nas:ScopeAmplificationCode implemented immediately below  -->
  <sch:pattern id="ScopeDescription_uses_ScopeAmplificationCode">
    <!-- NMIS - Part 2, Table 7: ISO/TS 19139 Character String Properties instantiated using a Code List -->
    <sch:rule context="gmd:levelDescription">
      <sch:assert test="gmd:MD_ScopeDescription/gmd:other/nas:ScopeAmplificationCode">
        All scope description other elements shall have a scope amplification code as their content.</sch:assert>
    </sch:rule>
  </sch:pattern>
  
  <!-- Direct use of ScopeAmplificationCode does not conform to ISO 19139 Profiling rules -->  
  <!--<sch:pattern id="LevelDescription_uses_ScopeAmplificationCode">
    --><!-- NMIS - Part 2, Table 7: ISO/TS 19139 Character String Properties instantiated using a Code List --><!--
    <sch:rule context="gmd:levelDescription">
      <sch:assert test="nas:ScopeAmplificationCode">
        All level descriptions shall have a scope amplification code as their content.</sch:assert>
    </sch:rule>
  </sch:pattern>-->
    
    <sch:pattern id="DQ_Element_result_multiplicity">
		<sch:rule context="gmd:DQ_DataQuality/gmd:report/*">
			<sch:assert test="not(gmd:result/gmd:DQ_ConformanceResult/* or gmd:result/gmd:DQ_QuantitativeResult/*) or ((gmd:result/gmd:DQ_ConformmanceResult/* or gmd:result/gmd:DQ_QuantitativeResult/*) and (count(gmd:result/gmd:DQ_ConformanceResult) &lt; 2) and (count(gmd:result/gmd:DQ_QuantitativeResult) &lt; 2))">
				Sub-classes of DQ_Result can each only have one instance.</sch:assert>
		</sch:rule>
    </sch:pattern>
  
  <!-- **************************************************************** -->
  <!-- ******** ISO 19115 Clause A.2.5 Maintenance information ******** -->
  <!-- **************************************************************** -->
  
  <!-- *************************************************************************** -->
  <!-- ******** ISO 19115 Clause A.2.6 Spatial representation information ******** -->
  <!-- *************************************************************************** -->
  
  <!-- ********************************************************************* -->
  <!-- ******** ISO 19115 Clause A.2.7 Reference system information ******** -->
  <!-- ********************************************************************* -->
  
  <!-- ************************************************************ -->
  <!-- ******** ISO 19115 Clause A.2.8 Content information ******** -->
  <!-- ************************************************************ -->
  
  <!-- ************************************************************************ -->
  <!-- ******** ISO 19115 Clause A.2.9 Portrayal catalogue information ******** -->
  <!-- ************************************************************************ -->
  
  <!-- ****************************************************************** -->
  <!-- ******** ISO 19115 Clause A.2.10 Distribution information ******** -->
  <!-- ****************************************************************** -->
  
  <!-- ************************************************************************ -->
  <!-- ******** ISO 19115 Clause A.2.11 Metadata extension information ******** -->
  <!-- ************************************************************************ -->
  
  <!-- ************************************************************************ -->
  <!-- ******** ISO 19115 Clause A.2.12 Application Schema information ******** -->
  <!-- ************************************************************************ -->
  
  <!-- *********************************************************** -->
  <!-- ******** ISO 19115 Clause A.3.1 Extent information ******** -->
  <!-- *********************************************************** -->
  
  <sch:pattern id="Extent_must_be_validly_specified">
    <!-- Over-ride ISO 19115 rule based on the NMIS-specified proscription of gmd:description. -->
    <sch:rule context="gmd:EX_Extent">
      <sch:assert test="gmd:geographicElement or gmd:temporalElement or gmd:verticalElement">
        The spatial extent, if present, fails to specify at least one geographic element, temporal element or vertical element.</sch:assert>
    </sch:rule>
  </sch:pattern>
  
  <sch:pattern id="GeographicElement_must_be_validly_specified">
    <!-- NMIS - Part 2, Table 5: ISO/TS 19139 Elements Extended for the NMIS (additional substitutable type) -->
    <sch:rule context="gmd:geographicElement">
      <!-- Over-ride ISO 19115 rule based on the NMIS-specified extension of {abstract} EX_GeographicExtent to include nas:BoundingPoint. -->
      <sch:assert test="gmd:EX_GeographicBoundingBox or gmd:EX_BoundingPolygon or nas:BoundingPoint or gmd:EX_GeographicDescription">
        The geographic element, if present, must specify a geographic bounding box, bounding polygon, bounding point or description.</sch:assert>
    </sch:rule>
  </sch:pattern>
  
  <sch:pattern id="Extent_must_have_HorizontalGeometry">
    <!-- The NMF specifies that for an EX_extent that "at least one of MinimumBoundingRectangle, BoundingPolygon, or BoundingPoint is required". -->
    <!-- Note: ISO 19115 states that this "shall" is contingent on the dataset being spatially referenced. -->
    <sch:rule context="nas:MD_Metadata">
      <sch:assert test="not(gmd:referenceSystemInfo/*) or (gmd:identificationInfo/nas:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:geographicElement/gmd:EX_GeographicBoundingBox or 
        gmd:identificationInfo/nas:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:geographicElement/gmd:EX_BoundingPolygon or 
        gmd:identificationInfo/nas:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:geographicElement/nas:BoundingPoint)">
        The spatial extent, if present along with a spatial reference system, fails to specify at least one geographic bounding box, polygon or point.</sch:assert>
    </sch:rule>
  </sch:pattern>  

  <sch:pattern id="BoundingPoint_must_not_have_ExcludedContent">
    <!-- NMIS - Part 2, Table 5: ISO/TS 19139 Elements Extended for the NMIS (additional substitutable type) -->
    <sch:rule context="nas:BoundingPoint">
      <sch:assert test="not(gmd:extentTypeCode)">
        The bounding point extent type code must not be used.</sch:assert>
    </sch:rule>
  </sch:pattern>

  <sch:pattern id="GmlPoint_must_be_validly_specified">
    <!-- NMIS - Part 2, Table 5: ISO/TS 19139 Elements Extended for the NMIS (additional substitutable type) -->
    <sch:rule context="gml:Point">
      <sch:assert test="@srsName">
        The GML Point must have a specified CRS.</sch:assert>
    </sch:rule>
  </sch:pattern>
  
  <!-- *********************************************************************************** -->
  <!-- ******** ISO 19115 Clause A.3.2 Citation and responsible party information ******** -->
  <!-- *********************************************************************************** -->
  
  <sch:pattern id="Telephone_must_have_Content">
    <!-- Over-ride ISO 19115 rule based on the NMIS-specified pattern-restriction of CharacterString. -->
    <sch:rule context="gmd:CI_Telephone">
      <sch:assert test="*">
        Telesphone must have content</sch:assert>
      <sch:assert test="not(gmd:voice) or ((gmd:voice/nas:TelephoneNumber) and (string-length(normalize-space(gmd:voice/nas:TelephoneNumber)) &gt; 0))">
        The telephone voice(s), if present, must have non-empty string content.</sch:assert>
      <sch:assert test="not(gmd:facsimile) or ((gmd:facsimile/nas:TelephoneNumber) and (string-length(normalize-space(gmd:facsimile/nas:TelephoneNumber)) &gt; 0))">
        The telephone facsimile(s), if present, must have non-empty string content.</sch:assert>
    </sch:rule>
  </sch:pattern>

  <sch:pattern id="VoiceTelephoneNumber_Internationalized">
    <!-- NMIS - Part 2, Table 6: ISO/TS 19139 Character String Properties instantiated using a Pattern-restriction -->
    <sch:rule context="gmd:voice">
      <sch:assert test="nas:TelephoneNumber">
        All voice telephone number content shall be constrained to the internationalized telephone number pattern.</sch:assert>
    </sch:rule>
  </sch:pattern>
  
  <sch:pattern id="FacsimileTelephoneNumber_Internationalized">
    <!-- NMIS - Part 2, Table 6: ISO/TS 19139 Character String Properties instantiated using a Pattern-restriction -->
    <sch:rule context="gmd:facsimile">
      <sch:assert test="nas:TelephoneNumber">
        All facsimile telephone number content shall be constrained to the internationalized telephone number pattern.</sch:assert>
    </sch:rule>
  </sch:pattern>  

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  <!-- - - - - - - - - - - - - - Code List Restriction - - - - - - - - - - - - - - - - - - - - -->
  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
 
  <sch:pattern id="CRCTypeCode_Valid_in_Resource">
    <sch:rule context="nas:CRCTypeCode">
      <sch:assert test="@codeList = concat($GSIP, '/codelist/CRCTypeCode') or
								 @codeList = concat($NSGREG, '/codelist/CRCTypeCode')">
        The code list must reference an NMF-appropriate DSE resource.</sch:assert>
      <sch:let name="url" value="concat(@codeList, '/', @codeListValue)"/>
      <sch:assert test="document($url)">
        The URL '<sch:value-of select="$url"/>' must reference a net-accessible resource.</sch:assert>
      <sch:assert test="(@codeList = document($url)/gml:Definition/gml:identifier/@codeSpace) or
								 (@codeList = document($url)/reg:ListedValue/gml:identifier/@codeSpace)">
        The specified codeList must match the codespace of the identifier in the resource.</sch:assert>
      <sch:assert test="(@codeListValue = document($url)/gml:Definition/gml:identifier) or
								 (@codeListValue = document($url)/reg:ListedValue/gml:identifier)">
        The specified codeListValue must match the value of the identifier in the resource.</sch:assert>
      <sch:assert test="normalize-space(.) = ''">
        The element must be empty.</sch:assert>
    </sch:rule>
  </sch:pattern>

  <sch:pattern id="MetadataStandardNameCode_Valid_in_Resource">
    <sch:rule context="nas:MetadataStandardNameCode">
      <sch:assert test="@codeList = concat($GSIP, '/codelist/MetadataStandardNameCode') or
								 @codeList = concat($NSGREG, '/codelist/MetadataStandardNameCode')">
        The code list must reference an NMF-appropriate DSE resource.</sch:assert>
      <sch:let name="url" value="concat(@codeList, '/', @codeListValue)"/>
      <sch:assert test="document($url)">
        The URL '<sch:value-of select="$url"/>' must reference a net-accessible resource.</sch:assert>
      <sch:assert test="(@codeList = document($url)/gml:Definition/gml:identifier/@codeSpace) or
								 (@codeList = document($url)/reg:ListedValue/gml:identifier/@codeSpace)">
        The specified codeList must match the codespace of the identifier in the resource.</sch:assert>
      <sch:assert test="(@codeListValue = document($url)/gml:Definition/gml:identifier) or
								 (@codeListValue = document($url)/reg:ListedValue/gml:identifier)">
        The specified codeListValue must match the value of the identifier in the resource.</sch:assert>
      <sch:assert test="normalize-space(.) = ''">
        The element must be empty.</sch:assert>
    </sch:rule>
  </sch:pattern>

  <sch:pattern id="ResourceCategoryCode_Valid_in_Resource">
    <sch:rule context="nas:ResourceCategoryCode">
      <sch:assert test="@codeList = concat($GSIP, '/codelist/ResourceCategoryCode') or
								 @codeList = concat($NSGREG, '/codelist/ResourceCategoryCode')">
        The code list must reference an NMF-appropriate DSE resource.</sch:assert>
      <sch:let name="url" value="concat(@codeList, '/', @codeListValue)"/>
      <sch:assert test="document($url)">
        The URL '<sch:value-of select="$url"/>' must reference a net-accessible resource.</sch:assert>
      <sch:assert test="(@codeList = document($url)/gml:Definition/gml:identifier/@codeSpace) or
								 (@codeList = document($url)/reg:ListedValue/gml:identifier/@codeSpace)">
        The specified codeList must match the codespace of the identifier in the resource.</sch:assert>
      <sch:assert test="(@codeListValue = document($url)/gml:Definition/gml:identifier) or
								 (@codeListValue = document($url)/reg:ListedValue/gml:identifier)">
        The specified codeListValue must match the value of the identifier in the resource.</sch:assert>
      <sch:assert test="normalize-space(.) = ''">
        The element must be empty.</sch:assert>
    </sch:rule>
  </sch:pattern>

  <sch:pattern id="RevisionTypeCode_Valid_in_Resource">
    <sch:rule context="nas:RevisionTypeCode">
      <sch:assert test="@codeList = concat($GSIP, '/codelist/RevisionTypeCode') or
								 @codeList = concat($NSGREG, '/codelist/RevisionTypeCode')">
        The code list must reference an NMF-appropriate DSE resource.</sch:assert>
      <sch:let name="url" value="concat(@codeList, '/', @codeListValue)"/>
      <sch:assert test="document($url)">
        The URL '<sch:value-of select="$url"/>' must reference a net-accessible resource.</sch:assert>
      <sch:assert test="(@codeList = document($url)/gml:Definition/gml:identifier/@codeSpace) or
								 (@codeList = document($url)/reg:ListedValue/gml:identifier/@codeSpace)">
        The specified codeList must match the codespace of the identifier in the resource.</sch:assert>
      <sch:assert test="(@codeListValue = document($url)/gml:Definition/gml:identifier) or
								 (@codeListValue = document($url)/reg:ListedValue/gml:identifier)">
        The specified codeListValue must match the value of the identifier in the resource.</sch:assert>
      <sch:assert test="normalize-space(.) = ''">
        The element must be empty.</sch:assert>
    </sch:rule>
  </sch:pattern> 
 
  <sch:pattern id="ScopeAmplificationCode_Valid_in_Resource">
    <sch:rule context="nas:ScopeAmplificationCode">
      <sch:assert test="@codeList = concat($GSIP, '/codelist/ScopeAmplificationCode') or
								 @codeList = concat($NSGREG, '/codelist/ScopeAmplificationCode')">
        The code list must reference an NMF-appropriate DSE resource.</sch:assert>
      <sch:let name="url" value="concat(@codeList, '/', @codeListValue)"/>
      <sch:assert test="document($url)">
        The URL '<sch:value-of select="$url"/>' must reference a net-accessible resource.</sch:assert>
      <sch:assert test="(@codeList = document($url)/gml:Definition/gml:identifier/@codeSpace) or
								 (@codeList = document($url)/reg:ListedValue/gml:identifier/@codeSpace)">
        The specified codeList must match the codespace of the identifier in the resource.</sch:assert>
      <sch:assert test="(@codeListValue = document($url)/gml:Definition/gml:identifier) or
								 (@codeListValue = document($url)/reg:ListedValue/gml:identifier)">
        The specified codeListValue must match the value of the identifier in the resource.</sch:assert>
      <sch:assert test="normalize-space(.) = ''">
        The element must be empty.</sch:assert>
    </sch:rule>
  </sch:pattern>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  <!-- - - - - - - - - - - - - - Crs Name Restrictions - - - - - - - - - - - - - - - - - - - - -->
  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  
  <sch:pattern id="PointSrsName_Valid_in_Resource">
    <sch:rule context="gml:Point">
      <sch:assert test="starts-with(@srsName, concat($GSIP, '/crs')) or starts-with(@srsName, concat($NSGREG, '/coord-ref-system'))">
        The CRS must be from the set registered in the NSG Resgistry (DSE GSIP Governance Namespace depricated.)</sch:assert>
      <sch:assert test="document(@srsName)">
        The specified srsName must reference a net-accessible resource in the DSE GSIP Governance Namespace.</sch:assert>
      <!-- Verify that the content of the resource matches the instance document -->
      <sch:assert test="(concat(substring-before(@srsName, '/crs'),'/crs') = document(@srsName)//gml:identifier/@codeSpace) or
								 (concat(substring-before(@srsName, '/coord-ref-system'), '/coord-ref-system') = document(@srsName)/reg:GeodeticCRS/gml:identifier/@codeSpace)">
        The body of the srsName must match the codeSpace of the identifier in the resource.</sch:assert>
      <sch:assert test="(substring-after(@srsName, 'crs/') = document(@srsName)//gml:identifier) or
								 (substring-after(@srsName, 'coord-ref-system/') = document(@srsName)/reg:GeodeticCRS/gml:identifier)">
        The tail of the srsName ('<sch:value-of select="substring-after(@srsName, 'crs/')"/>') must match the value of the identifier in the resource.</sch:assert>
    </sch:rule>
  </sch:pattern>
  
</sch:schema>