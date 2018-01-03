<?xml version="1.0" encoding="UTF-8"?>
<sch:schema
  xmlns:sch="http://purl.oclc.org/dsdl/schematron"
  xmlns:gmd="http://www.isotc211.org/2005/gmd"
  xmlns:gco="http://www.isotc211.org/2005/gco"
  xmlns:gss="http://www.isotc211.org/2005/gss"
  xmlns:gml="http://www.opengis.net/gml/3.2"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:ism="urn:us:gov:ic:ism"
  xmlns:nas="http://metadata.ces.mil/dse/ns/GSIP/5.0/nas"
  xml:lang="en">
  
  <!-- ************************************************************************* -->
  <!-- ******** Only intended for use with NMIS - Part 2, Version 2.1.0 ******** -->
  <!-- ************************************************************************* -->
  
  <!-- 
    Restricts content based on constraints specified by ISO/TS 19139 that
      cannot be enforced using XSD.
    For ease in comparative and functional analysis, some XSD constraints
      on the presence of elements may also be duplicated here.
  -->

  <sch:title>NMIS ISO/TS 19139 Schematron validation</sch:title>

  <sch:ns prefix="sch" uri="http://purl.oclc.org/dsdl/schematron"/>
  <sch:ns prefix="gmd" uri="http://www.isotc211.org/2005/gmd"/>
  <sch:ns prefix="gco" uri="http://www.isotc211.org/2005/gco"/>
  <sch:ns prefix="gss" uri="http://www.isotc211.org/2005/gss"/>
  <sch:ns prefix="gml" uri="http://www.opengis.net/gml/3.2"/>
  <sch:ns prefix="xlink" uri="http://www.w3.org/1999/xlink"/>
  <sch:ns prefix="ism" uri="urn:us:gov:ic:ism"/>
  <sch:ns prefix="nas" uri="http://metadata.ces.mil/dse/ns/GSIP/5.0/nas"/>
  
  <!-- ************************************************************************ -->
  <!-- ******** ISO 19115 Clause A.2.1 Metadata entity set information ******** -->
  <!-- ************************************************************************ -->

  <!-- This ISO 19115 rule is over-ridden based on the NMIS-specified extension of MD_Metadata.
  <sch:pattern id="Metadata_must_have_Content">
    <sch:rule context="gmd:MD_Metadata">
      <sch:assert test="not(gmd:fileIdentifier) or ((gmd:fileIdentifier/gco:CharacterString) and (string-length(normalize-space(gmd:fileIdentifier/gco:CharacterString)) &gt; 0))">
        The metadata file identifier, if present, must have non-empty string content.</sch:assert>
      <sch:assert test="not(gmd:hierarchyLevel) or (gmd:hierarchyLevel/*)">
        The metadata hierarchy level, if present, must have content.</sch:assert>
      <sch:assert test="not(gmd:hierarchyLevelName) or ((gmd:hierarchyLevelName/gco:CharacterString) and (string-length(normalize-space(gmd:hierarchyLevelName/gco:CharacterString)) &gt; 0))">
        The metadata hierarchy level name, if present, must have non-empty string content.</sch:assert>
      <sch:assert test="gmd:contact/*">
        The metadata contact must have content.</sch:assert>
      <sch:assert test="gmd:dateStamp/*">
        The metadata date stamp must have content.</sch:assert>
      <sch:assert test="not(gmd:metadataStandardName) or ((gmd:metadataStandardName/gco:CharacterString) and (string-length(normalize-space(gmd:metadataStandardName/gco:CharacterString)) &gt; 0))">
        The metadata metadata standard name, if present, must have non-empty string content.</sch:assert>
      <sch:assert test="not(gmd:metadataStandardVersion) or ((gmd:metadataStandardVersion/gco:CharacterString) and (string-length(normalize-space(gmd:metadataStandardVersion/gco:CharacterString)) &gt; 0))">
        The metadata metadata standard version, if present, must have non-empty string content.</sch:assert>
      <sch:assert test="not(gmd:locale) or (gmd:locale/*)">
        The metadata locale, if present, must have content.</sch:assert> -->
      <!-- MD_Metadata associations --> <!--
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
  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  
  <!-- This ISO 19115 rule is over-ridden based on the NMIS-specified extension of MD_DataIdentification.
  <sch:pattern id="HierarchyLevel_dataset_implies_TopicCategory">
    <sch:rule context="gmd:MD_Metadata">
      <sch:assert test="(gmd:hierarchyLevel/gmd:MD_ScopeCode/@codeListValue='dataset') and (gmd:identificationInfo/gmd:MD_DataIdentification/gmd:topicCategory/*)">
        The metadata hierarchy level is 'dataset' however no topic categories are specified.
      </sch:assert>
    </sch:rule>
  </sch:pattern>
  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  
  <sch:pattern id="Locale_must_have_Content">
    <sch:rule context="gmd:PT_Locale">
      <!-- Note that ISO 19115 specifies this attribute as 'language' whereas ISO/TS 19139 states 'languageCode'. -->
      <sch:assert test="gmd:languageCode/*">The language code must have content.</sch:assert>
      <sch:assert test="gmd:country/*">The country must have content.</sch:assert>
      <sch:assert test="gmd:characterEncoding/*">The character encoding must have content.</sch:assert>
    </sch:rule>
  </sch:pattern>
  
  <!-- ******************************************************************* -->
  <!-- ******** ISO 19115 Clause A.2.2 Identification information ******** -->
  <!-- ******************************************************************* -->

  <!-- This ISO 19115 rule is over-ridden based on the NMIS-specified extension of MD_DataIdentification.
  <sch:pattern id="DataIdentification_must_have_Content">
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
        The data identification extent must have content.</sch:assert> -->
      <!-- {abstract} MD_Identification associations --> <!--
      <sch:assert test="not(gmd:aggregationInfo) or (gmd:aggregationInfo/*)">
        The data identification aggregation information association/element, if present, must have content.</sch:assert>
      <sch:assert test="not(gmd:descriptiveKeywords) or (gmd:descriptiveKeywords/*)">
        The data identification descriptive keywords association/element, if present, must have content.</sch:assert>
      <sch:assert test="not(gmd:referenceSystemInfo) or (gmd:referenceSystemInfo/*)">
        The data identification reference system information association/element, if present, must have content.</sch:assert>
      <sch:assert test="not(gmd:resourceConstraints) or (gmd:resourceConstraints/*)">
        The data identification resource constraints association/element, if present, must have content.</sch:assert>
      <sch:assert test="not(gmd:resourceFormat) or (gmd:resourceFormat/*)">
        The data identification resource format association/element, if present, must have content.</sch:assert>
    </sch:rule>
  </sch:pattern>
  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  
    <sch:pattern id="Resolution_must_have_Content">
    <sch:rule context="gmd:MD_Resolution">
      <sch:assert test="not(gmd:distance) or ((gmd:distance/gco:Distance) and (gmd:distance/gco:Distance &gt; 0))">
          The resolution distance, if present, must be a positive and non-zero numeric value.</sch:assert>
      <sch:assert test="not(gmd:equivalentScale) or ((gmd:equivalentScale/gmd:MD_RepresentativeFraction/gmd:denominator/*) and (gmd:equivalentScale/gmd:MD_RepresentativeFraction/gmd:denominator/gco:Integer &gt; 0))">
          The resolution quivalent scale, if present, has a denominator of a representative fraction that is a positive and non-zero integer value.</sch:assert>
    </sch:rule>
  </sch:pattern>

  <sch:pattern id="AggregateInformation_must_have_Content">
    <sch:rule context="gmd:MD_AggregateInformation">
      <sch:assert test="gmd:aggregateDataSetName/* or gmd:aggregateDataSetIdentifier/*">
        An aggregate information must be identified by either an aggregate data set name or identifier, with content.</sch:assert>
      <sch:assert test="gmd:associationType/*">
        An aggregate information must have an association type, with content.</sch:assert>
    </sch:rule>
  </sch:pattern>
  
  <sch:pattern id="Keywords_must_have_Content">
    <sch:rule context="gmd:MD_Keywords">
      <sch:assert test="gmd:keyword/gco:CharacterString and (string-length(normalize-space(gmd:keyword/gco:CharacterString)) &gt; 0)">
        The keyword must have non-empty string content.</sch:assert>
      <sch:assert test="not(gmd:type) or (gmd:type/*)">
        The keyword type, if present, must have content.</sch:assert>
      <sch:assert test="gmd:thesaurusName/*">
        The keyword thesaurusName name must have content.</sch:assert>
    </sch:rule>
  </sch:pattern>
  
  <!--<sch:pattern id="NMF_RevisionRecall_revisionID_properly_specified">
    <sch:rule context="nas:NMF_RevisionRecall/nas:revisionID">
      <sch:report test="*">Index is  <sch:value-of select="position()"/>, value is <sch:value-of select="gco:Integer"/></sch:report>
      <sch:assert test="position() = gco:integer">
        Current revisionID element location among revisionID elements is <sch:value-of select="position()"/>, value is <sch:value-of select="gco:Integer"/>.  Within the scope of this resource, the first Id must be 1 followed by 2, 3, etc.</sch:assert>
    </sch:rule>
  </sch:pattern>-->

  <!-- *************************************************************** -->
  <!-- ******** ISO 19115 Clause A.2.3 Constraint information ******** -->
  <!-- *************************************************************** -->

  <sch:pattern id="SecurityConstraints_must_have_Content">
    <sch:rule context="gmd:MD_SecurityConstraints">
      <sch:assert test="gmd:classification/*">
        The security constraints security classification must have content.</sch:assert>
      <sch:assert test="not(gmd:classificationSystem) or (gmd:classificationSystem/*)">
        The security constraints classification system, if present, must have content.</sch:assert>
    </sch:rule>
  </sch:pattern>
  
  <sch:pattern id="LegalConstraints_must_have_Content">
    <sch:rule context="gmd:MD_LegalConstraints">
      <sch:assert test="not(gmd:accessConstraints) or (gmd:accessConstraints/*)">
        The legal constraints access constraints, if present, must have content.</sch:assert>
      <sch:assert test="not(gmd:useConstraints) or (gmd:useConstraints/*)">
        The legal constraints use constraints, if present, must have content.</sch:assert>
    </sch:rule>
  </sch:pattern>
  
  <!-- ***************************************************************** -->
  <!-- ******** ISO 19115 Clause A.2.4 Data quality information ******** -->
  <!-- ***************************************************************** -->
  
  <!-- This ISO 19115 rule is over-ridden based on the NMIS-specified proscription of gmd:LI_Source and gmd:LI_ProcessStep.
    <sch:pattern id="DataQualityLineage_must_be_validly_specified">
      <sch:rule context="gmd:DQ_DataQuality">
        <sch:assert test="((gmd:scope/gmd:DQ_Scope/gmd:level/gmd:MD_ScopeCode/@codeListValue='dataset') or (gmd:scope/gmd:DQ_Scope/gmd:level/gmd:MD_ScopeCode/@codeListValue='series')) and (count(gmd:lineage/gmd:LI_Lineage/gmd:source/*) = 0) and (count(gmd:lineage/gmd:LI_Lineage/gmd:processStep/*) = 0) and not (gmd:lineage/gmd:LI_Lineage/gmd:statement)">
          The data quality scope is 'dataset' or 'series' and there is no specified source or process step information, however no lineage statement is specified.
        </sch:assert>
      </sch:rule>
    </sch:pattern>
    - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  
  <sch:pattern id="Scope_must_have_Content">
    <sch:rule context="gmd:DQ_Scope">
      <sch:assert test="gmd:level/*">
        The scope level must have content.</sch:assert>
      <sch:assert test="not(gmd:levelDescription) or (gmd:levelDescription/*)">
        The scope level description, if present, must have content.</sch:assert>
    </sch:rule>
  </sch:pattern>
  
  <sch:pattern id="DataQuality_must_have_Content">
    <sch:rule context="gmd:DQ_DataQuality">
      <sch:assert test="gmd:scope/*">
        The data quality scope must have content.</sch:assert>
      <sch:assert test="not(gmd:lineage) or (gmd:lineage/*)">
        The data quality lineage association/element, if present, must have content.</sch:assert>
	  <sch:assert test="not(gmd:report) or (gmd:report/*)">
		The data quality report association/element, if present, must have content.</sch:assert>
    </sch:rule>
  </sch:pattern> 
 
  <sch:pattern id="Lineage_must_have_Content">
    <sch:rule context="gmd:LI_Lineage">
      <sch:assert test="not(gmd:statement) or ((gmd:statement/gco:CharacterString) and ((string-length(normalize-space(gmd:statement/gco:CharacterString)) &gt; 0)))">
        The lineage statement, if present, must have non-empty string content.</sch:assert>
    </sch:rule>
  </sch:pattern>
    
    <!-- NMF Part 2 Quality Metadata - Section 7.4.2 -->
    <!--<sch:pattern id="Source_description_must_have_Content">
		<sch:rule context="gmd:LI_Source">
			<sch:assert test="not(gmd:description) or ((gmd:description/gco:CharacterString) and ((string-length(normalize-space(gmd:description/gco:CharacterString)) &gt; 0)))">
				The source description, if present, must have non-empty string content.</sch:assert>
		</sch:rule>
    </sch:pattern>-->
    
    <sch:pattern id="Source_description_must_have_Content">
      <sch:rule context="gmd:LI_Lineage/gmd:source">
        <sch:assert test="not(*/gmd:description)  or ((*/gmd:description/gco:CharacterString) and ((string-length(normalize-space(*/gmd:description/gco:CharacterString)) &gt; 0)))">
				The source description, if present, must have non-empty string content.</sch:assert>
      </sch:rule>
    </sch:pattern>
    
    <sch:pattern id="LI_Source_must_be_validly_specified">
      <sch:rule context="gmd:LI_Lineage/gmd:source">
        <sch:assert test="*/gmd:description/* or */gmd:sourceExtent/*">
				Either a description or sourceExtent must be specified for LI_Source/LE_Source.</sch:assert>
      </sch:rule>
    </sch:pattern>
    
    <!--<sch:pattern id="LI_Source_must_be_validly_specified">
		<sch:rule context="gmd:LI_Source">
			<sch:assert test="gmd:description/* or gmd:sourceExtent/*">
				Either a description or sourceExtent must be specified for LI_Source.</sch:assert>
		</sch:rule>
    </sch:pattern>-->
    
    <sch:pattern id="DQ_Element_evaluationMethodDescription_must_have_String_Content">
		<sch:rule context="gmd:DQ_DataQuality/gmd:report/*/gmd:evaluationMethodDescription">
			<sch:assert test="gco:CharacterString and (string-length(normalize-space(gco:CharacterString)) &gt; 0)">
				gmd:DQ_Element/gmd:evaluationMethodDescription, if present, must have non-empty string content.</sch:assert>
		</sch:rule>
    </sch:pattern>
  
  <!-- **************************************************************** -->
  <!-- ******** ISO 19115 Clause A.2.5 Maintenance information ******** -->
  <!-- **************************************************************** -->
  
  <!-- *************************************************************************** -->
  <!-- ******** ISO 19115 Clause A.2.6 Spatial representation information ******** -->
  <!-- *************************************************************************** -->

  <sch:pattern id="MD_Georectified_must_have_Consistent_check_point_values">
	  <sch:rule context="gmd:MD_Georectified">
		  <sch:assert test="gmd:checkPointAvailability/gco:Boolean='false' or (gmd:checkPointAvailability/gco:Boolean='true' and gmd:checkPointDescription/*)">
		  The Boolean value check point availability is true and the check point description is either missing or has no content.</sch:assert>
	  </sch:rule>
  </sch:pattern>
  
  <!-- ********************************************************************* -->
  <!-- ******** ISO 19115 Clause A.2.7 Reference system information ******** -->
  <!-- ********************************************************************* -->

  <sch:pattern id="ReferenceSystem_must_have_Content">
    <sch:rule context="gmd:MD_ReferenceSystem">
      <sch:assert test="gmd:referenceSystemIdentifier/*">
        The reference system identifier must have content.</sch:assert>
    </sch:rule>
  </sch:pattern>
  
  <sch:pattern id="MdIdentifier_must_have_Content">
    <sch:rule context="gmd:MD_Identifier">
      <!-- This ISO 19115 rule is over-ridden based on the NMIS-specified use of @xlink:href
      <sch:assert test="not(gmd:authority) or gmd:authority/*">
        The metadata identifier authority, if any, must have content.</sch:assert>
        - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
      <sch:assert test="gmd:code/gco:CharacterString and (string-length(normalize-space(gmd:code/gco:CharacterString)) &gt; 0)">
        The metadata identifier must have a code, with non-empty string content.</sch:assert>
    </sch:rule>
  </sch:pattern>
  
  <sch:pattern id="RsIdentifier_must_have_Content">
    <sch:rule context="gmd:RS_Identifier">
      <sch:assert test="gmd:code/gco:CharacterString and (string-length(normalize-space(gmd:code/gco:CharacterString)) &gt; 0)">
        The reference system identifier must have a code with non-empty string content.</sch:assert>
      <sch:assert test="not(gmd:codeSpace) or ((gmd:codeSpace/gco:CharacterString) and (string-length(normalize-space(gmd:codeSpace/gco:CharacterString)) &gt; 0))">
        The reference system identifier code space, if present, must have non-empty string content.</sch:assert>
    </sch:rule>
  </sch:pattern>

  <!-- ************************************************************ -->
  <!-- ******** ISO 19115 Clause A.2.8 Content information ******** -->
  <!-- ************************************************************ -->
  
  <!-- ************************************************************************ -->
  <!-- ******** ISO 19115 Clause A.2.9 Portrayal catalogue information ******** -->
  <!-- ************************************************************************ -->
  
  <!-- ****************************************************************** -->
  <!-- ******** ISO 19115 Clause A.2.10 Distribution information ******** -->
  <!-- ****************************************************************** -->
  
  <sch:pattern id="Distribution_must_have_content">
    <sch:rule context="gmd:MD_Distribution">
      <sch:assert test="*">
        Distribution must have content</sch:assert>
    </sch:rule>
  </sch:pattern>
  
  <sch:pattern id="Format_must_have_Content">
    <sch:rule context="gmd:MD_Format">
      <sch:assert test="gmd:name/gco:CharacterString and (string-length(normalize-space(gmd:name/gco:CharacterString)) &gt; 0)">
        The format name must have non-empty string content.</sch:assert>
      <sch:assert test="gmd:version/gco:CharacterString and (string-length(normalize-space(gmd:version/gco:CharacterString)) &gt; 0)">
        The format version must have non-empty string content.</sch:assert>
      <sch:assert test="not(gmd:formatDistributor) or (gmd:formatDistributor/*)">
        The format distributor association/element, if it exists, must have content, e.g., a contact.</sch:assert>
    </sch:rule>
  </sch:pattern>
  
  <sch:pattern id="Distributor_must_have_Content">
    <sch:rule context="gmd:MD_Distributor">
      <sch:assert test="gmd:distributorContact/*">
        The distributor must have a contact, with content.</sch:assert>
      <sch:assert test="not(gmd:distributorTransferOptions) or (gmd:distributorTransferOptions/*)">
        The distributor transfer options association/element, if it exists, must have content.</sch:assert>
    </sch:rule>
  </sch:pattern>
  
  <sch:pattern id="Distribution_must_be_validly_specified">
    <sch:rule context="gmd:MD_Distribution">
      <sch:assert test="(not(gmd:distributor/@xlink:href) and gmd:distributor/gmd:MD_distributor/gmd:distributorFormat) or
                                 (gmd:distributor/@xlink:href and not(starts-with(gmd:distributor/@xlink:href, '#')) or (starts-with(gmd:distributor/@xlink:href, '#') and (//gmd:MD_Distributor[@id=(substring-after(current()/gmd:distributor/@xlink:href,'#'))]/gmd:distributorFormat))) or
                                 (not(gmd:distributionFormat/@xlink:href) and gmd:distributionFormat) or
                                 (gmd:distributionFormat/@xlink:href and not(starts-with(gmd:distributionFormat/@xlink:href, '#')) or (starts-with(gmd:distributionFormat/@xlink:href,'#') and (//gmd:MD_Format[@id=(substring-after(current()/gmd:distributionFormat/@xlink:href,'#'))])))">
        The distributionFormat element must be present if MD_Distribution/distributor/MD_Distributor/distributorFormat is not documented.</sch:assert>
    </sch:rule>
  </sch:pattern>
  
  <!--<sch:pattern id="DigitalTransferOptions_must_have_Content">
    <sch:rule context="gmd:MD_DigitalTransferOptions">
      <sch:assert test="not(gmd:transferSize) or ((gmd:transferSize/gco:Real) and (gmd:transferSize/gco:Real &gt; 0))">
        The digital transfer options transfer size, if present, must have real value that is greater than zero.</sch:assert>
      <sch:assert test="not(gmd:onLine) or (gmd:onLine/*)">
        The digital transfer options on-line, if present, must have content.</sch:assert>
    </sch:rule>
  </sch:pattern>-->
  
  <sch:pattern id="NAS_DigitalTransferOptions_must_have_Content">
    <sch:rule context="nas:NMF_DigitalTransferOptions">
      <sch:assert test="not(gmd:transferSize) or ((gmd:transferSize/gco:Real) and (gmd:transferSize/gco:Real &gt; 0))">
        The digital transfer options transfer size, if present, must have real value that is greater than zero.</sch:assert>
      <sch:assert test="not(gmd:onLine) or (gmd:onLine/*)">
        The digital transfer options on-line, if present, must have content.</sch:assert>
    </sch:rule>
  </sch:pattern>

  <!-- ************************************************************************ -->
  <!-- ******** ISO 19115 Clause A.2.11 Metadata extension information ******** -->
  <!-- ************************************************************************ -->
  
  <!-- ************************************************************************ -->
  <!-- ******** ISO 19115 Clause A.2.12 Application Schema information ******** -->
  <!-- ************************************************************************ -->

  <sch:pattern id="ApplicationSchemaInformation_must_have_Content">
    <sch:rule context="gmd:MD_ApplicationSchemaInformation">
      <sch:assert test="gmd:name/*">
        The application schema information name must have content.</sch:assert>
      <sch:assert test="gmd:schemaLanguage/gco:CharacterString and (string-length(normalize-space(gmd:schemaLanguage/gco:CharacterString)) &gt; 0)">
        The application schema information schema language must have non-empty string content.</sch:assert>
      <sch:assert test="gmd:constraintLanguage/gco:CharacterString and (string-length(normalize-space(gmd:constraintLanguage/gco:CharacterString)) &gt; 0)">
        The application schema information constraint language must have non-empty string content.</sch:assert>
    </sch:rule>
  </sch:pattern>
  
  <!-- *********************************************************** -->
  <!-- ******** ISO 19115 Clause A.3.1 Extent information ******** -->
  <!-- *********************************************************** -->
  
  <!-- This ISO 19115 rule is over-ridden based on the NMIS-specified proscription of gmd:description.
    <sch:pattern id="Extent_must_have_Content">
      <sch:rule context="gmd:EX_Extent">
        <sch:assert test="gmd:description or gmd:geographicElement or gmd:temporalElement or gmd:verticalElement">
          The extent must specify at least one description, geographic element, temporal element or vertical element.</sch:assert>
      </sch:rule>
    </sch:pattern>
    - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <!-- This ISO 19115 rule is over-ridden based on the NMIS-specified extension of {abstract} EX_GeographicExtent to include nas:BoundingPoint.
    <sch:pattern id="GeographicElement_must_have_content">
      <sch:rule context="gmd:geographicElement">
        <sch:assert test="gmd:EX_GeographicBoundingBox or gmd:EX_BoundingPolygon or gmd:EX_GeographicDescription">
          The geographic element, if present, must specify a geographic bounding box, bounding polygon or description.</sch:assert>
      </sch:rule>
    </sch:pattern>
    - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  
  <sch:pattern id="GeographicBoundingBox_must_have_ValidContent">
    <sch:rule context="gmd:EX_GeographicBoundingBox">
      <sch:assert test="(-180.0 &lt;= gmd:westBoundLongitude) and (gmd:westBoundLongitude &lt;= 180.0)">
          The western bounding longitude must fall between -180 and 180 arc degrees, inclusive.</sch:assert>
      <sch:assert test="(-180.0 &lt;= gmd:eastBoundLongitude) and (gmd:eastBoundLongitude &lt;= 180.0)">
          The eastern bounding longitude must fall between -180 and 180 arc degrees, inclusive.</sch:assert>
      <sch:assert test="(-90.0 &lt;= gmd:southBoundLatitude) and (gmd:southBoundLatitude &lt;= 90.0)">
          The southern bounding latitude must fall between -90 and 90 arc degrees, inclusive.</sch:assert>
      <sch:assert test="(-90.0 &lt;= gmd:northBoundLatitude) and (gmd:northBoundLatitude &lt;= 90.0)">
          The northern bounding latitude must fall between -90 and 90 arc degrees, inclusive.</sch:assert>
      <sch:assert test="gmd:southBoundLatitude &lt;= gmd:northBoundLatitude">
          The southern bounding latitude must be less than or equal to the northern bounding latitude.</sch:assert>
    </sch:rule>
  </sch:pattern>

  <sch:pattern id="BoundingPolygon_must_have_Content">
    <sch:rule context="gmd:EX_BoundingPolygon">
      <sch:assert test="gmd:polygon/*">
        The bounding polygon must have content.</sch:assert>
    </sch:rule>
  </sch:pattern>
  
  <sch:pattern id="Polygon_must_be_validly_specified">
    <sch:rule context="gml:Polygon">
      <sch:assert test="@srsName and gml:exterior">
        The GML Polygon must have a specified CRS and content in the form of an exterior ring.</sch:assert>
    </sch:rule>
  </sch:pattern>

  <sch:pattern id="GeographicDescription_must_have_Content">
    <sch:rule context="gmd:EX_GeographicDescription">
      <sch:assert test="gmd:geographicIdentifier/*">
        The geographic description geographic identifier must have content.</sch:assert>
    </sch:rule>
  </sch:pattern>
  
  <sch:pattern id="TemporalElement_must_have_Content">
    <sch:rule context="gmd:temporalElement">
      <sch:assert test="*">The temporal element, if present, must have content.</sch:assert>
    </sch:rule>
  </sch:pattern>
  
  <sch:pattern id="VerticalElement_must_have_Content">
    <sch:rule context="gmd:verticalElement">
      <sch:assert test="*">The vertical element, if present, must have content.</sch:assert>
    </sch:rule>
  </sch:pattern>

  <sch:pattern id="VerticalExtent_must_have_Content">
    <sch:rule context="gmd:EX_VerticalExtent">
      <sch:assert test="gmd:minimumValue/*">
        The vertical extent minimum value must have content.</sch:assert>
      <sch:assert test="gmd:maximumValue/*">
        The vertical extent maximum value must have content.</sch:assert>
      <!-- Note that ISO 19115 Amd. 1 removed the 'unitOfMeasure' attribute/element. -->
      <!-- Note that ISO 19115 Amd. 1 renamed the 'verticalDatum' association/element to 'verticalCRS'. -->
      <sch:assert test="(string-length(normalize-space(gmd:verticalCRS/@xlink:href)) &gt; 0) or (gmd:verticalCRS/*)">
        The vertical extent vertical CRS association/element must be either a non-empty xlink:href or have content.</sch:assert>
    </sch:rule>
  </sch:pattern>
  
  <!-- *********************************************************************************** -->
  <!-- ******** ISO 19115 Clause A.3.2 Citation and responsible party information ******** -->
  <!-- *********************************************************************************** -->
  
  <sch:pattern id="Citation_must_have_Content">
    <sch:rule context="gmd:CI_Citation">
      <sch:assert test="gmd:title/gco:CharacterString and (string-length(normalize-space(gmd:title/gco:CharacterString)) &gt; 0)">
        The citation title must have non-empty string content.</sch:assert>
      <sch:assert test="gmd:date/*">
        The citation date(s) must have content.</sch:assert>
      <sch:assert test="not(gmd:identifier) or (gmd:identifier/*)">
        The citation identifier(s), if present, must have content.</sch:assert>
      <sch:assert test="not(gmd:citedResponsibleParty) or (gmd:citedResponsibleParty/*)">
        The citation cited responsible party(ies), if present, must have content.</sch:assert>
      <sch:assert test="not(gmd:series) or (gmd:series/*)">
        The citation series, if present, must have content.</sch:assert>
    </sch:rule>
  </sch:pattern>
    
    <!-- NMF Part 1 Citation - Section 7.4.13 -->
    <sch:pattern id="Citation_alternateTitle_must_have_String_Content">
		<sch:rule context="gmd:CI_Citation">
			<sch:assert test="not(gmd:alternateTitle) or ((gmd:alternateTitle/gco:CharacterString) and (string-length(normalize-space(gmd:alternateTitle/gco:CharacterString)) &gt; 0))">
				gmd:CI_Citation/gmd:alternateTitle, if present, must have non-empty string content.</sch:assert>
		</sch:rule>
    </sch:pattern>
  
  <sch:pattern id="ResponsibleParty_must_have_Content">
    <sch:rule context="gmd:CI_ResponsibleParty">
      <sch:assert test="(gmd:individualName and (string-length(normalize-space(gmd:individualName/gco:CharacterString)) &gt; 0)) or (gmd:organisationName and (string-length(normalize-space(gmd:organisationName/gco:CharacterString)) &gt; 0)) or (gmd:positionName and (string-length(normalize-space(gmd:positionName/gco:CharacterString)) &gt; 0))">
        A responsible party must be identified by either the name of the individual, organisation or position, with non-empty string content.</sch:assert>
      <sch:assert test="not(gmd:contactInfo) or (gmd:contactInfo/*)">
        The responsible party contact information, if present, must have content.</sch:assert>
      <sch:assert test="gmd:role/*">
        The responsible party role must have content.</sch:assert>
    </sch:rule>
  </sch:pattern>
  
  <sch:pattern id="Date_must_have_Content">
    <sch:rule context="gmd:CI_Date">
      <sch:assert test="gmd:date/*">The date must have content.</sch:assert>
      <sch:assert test="gmd:dateType/*">The date type must have content.</sch:assert>
    </sch:rule>
  </sch:pattern>

  <sch:pattern id="Series_must_have_Content">
    <sch:rule context="gmd:CI_Series">
      <sch:assert test="not(gmd:name) or ((gmd:name/gco:CharacterString) and (string-length(normalize-space(gmd:name/gco:CharacterString)) &gt; 0))">
        The series name, if present, must have non-empty string content.</sch:assert>
    </sch:rule>
  </sch:pattern>

  <sch:pattern id="Contact_must_have_Content">
    <sch:rule context="gmd:CI_Contact">
      <sch:assert test="*">
        Contact must have content</sch:assert>
      <sch:assert test="not(gmd:phone) or (gmd:phone/*)">
        The contact phone, if present, must have ontent.</sch:assert>
      <sch:assert test="not(gmd:address) or (gmd:address/*)">
        The contact address, if present, must have ontent.</sch:assert>
      <sch:assert test="not(gmd:onlineResource) or (gmd:onlineResource/*)">
        The contact online resource, if present, must have ontent.</sch:assert>
      <sch:assert test="not(gmd:hoursOfService) or ((gmd:hoursOfService/gco:CharacterString) and (string-length(normalize-space(gmd:hoursOfService/gco:CharacterString)) &gt; 0))">
        The contact hours of service, if present, must have non-empty string content.</sch:assert>
      <sch:assert test="not(gmd:contactInstructions) or ((gmd:contactInstructions/gco:CharacterString) and (string-length(normalize-space(gmd:contactInstructions/gco:CharacterString)) &gt; 0))">
        The contact instructions, if present, must have non-empty string content.</sch:assert>
    </sch:rule>
  </sch:pattern>
  
  <sch:pattern id="OnlineResource_must_have_Valid_Content">
    <sch:rule context="gmd:CI_OnlineResource">
      <sch:assert test="gmd:linkage/gmd:URL and (string-length(normalize-space(gmd:linkage/gmd:URL)) &gt; 0)">
        The online resource linkage must have non-empty string content.</sch:assert>
      <sch:assert test="not(gmd:protocol) or ((gmd:protocol/gco:CharacterString) and (string-length(normalize-space(gmd:protocol/gco:CharacterString)) &gt; 0))">
        The online resource protocol, if present, must have non-empty string content.</sch:assert>
      <sch:assert test="not(gmd:name) or ((gmd:name/gco:CharacterString) and (string-length(normalize-space(gmd:name/gco:CharacterString)) &gt; 0))">
        The online resource name, if present, must have non-empty string content.</sch:assert>
    </sch:rule>
  </sch:pattern>

  <!-- This ISO 19115 rule is over-ridden based on the NMIS-specified pattern-restriction of CharacterString.
  <sch:pattern id="Telephone_must_have_Content">
    <sch:rule context="gmd:CI_Telephone">
      <sch:assert test="not(gmd:voice) or ((gmd:voice/gco:CharacterString) and (string-length(normalize-space(gmd:voice/gco:CharacterString)) &gt; 0))">
        The telephone voice(s), if present, must have non-empty string content.</sch:assert>
      <sch:assert test="not(gmd:facsimile) or ((gmd:facsimile/gco:CharacterString) and (string-length(normalize-space(gmd:facsimile/gco:CharacterString)) &gt; 0))">
        The telephone facsimile(s), if present, must have non-empty string content.</sch:assert>
    </sch:rule>
  </sch:pattern>
  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  
  <sch:pattern id="Address_must_have_Content">
    <sch:rule context="gmd:CI_Address">
	  <sch:assert test="*">
	    Address must have content</sch:assert>
      <sch:assert test="not(gmd:deliveryPoint) or ((gmd:deliveryPoint/gco:CharacterString) and (string-length(normalize-space(gmd:deliveryPoint/gco:CharacterString)) &gt; 0))">
        The address delivery point(s), if present, must have non-empty string content.</sch:assert>
      <sch:assert test="not(gmd:city) or ((gmd:city/gco:CharacterString) and (string-length(normalize-space(gmd:city/gco:CharacterString)) &gt; 0))">
        The address city, if present, must have non-empty string content.</sch:assert>
      <sch:assert test="not(gmd:administrativeArea) or ((gmd:administrativeArea/gco:CharacterString) and (string-length(normalize-space(gmd:administrativeArea/gco:CharacterString)) &gt; 0))">
        The address administrative area, if present, must have non-empty string content.</sch:assert>
      <sch:assert test="not(gmd:postalCode) or ((gmd:postalCode/gco:CharacterString) and (string-length(normalize-space(gmd:postalCode/gco:CharacterString)) &gt; 0))">
        The address postal code, if present, must have non-empty string content.</sch:assert>
      <sch:assert test="not(gmd:country) or ((gmd:country/gco:CharacterString) and (string-length(normalize-space(gmd:country/gco:CharacterString)) &gt; 0))">
        The address country, if present, must have non-empty string content.</sch:assert>
      <sch:assert test="not(gmd:electronicMailAddress) or ((gmd:electronicMailAddress/gco:CharacterString) and (string-length(normalize-space(gmd:electronicMailAddress/gco:CharacterString)) &gt; 0))">
        The address electronic mail address(es), if present, must have non-empty string content.</sch:assert>
    </sch:rule>
  </sch:pattern>
  
  <!-- *********************************************************************************** -->
  <!-- ******** ISO 19115 Clause A.2.8 Content information ******** -->
  <!-- *********************************************************************************** -->
  
  <sch:pattern id="Band_units_must_be_present_if_min_and_max_values_present">
	  <sch:rule context="gmd:MD_Band">
		  <sch:assert test="not(gmd:maxValue or gmd:minValue or gmd:peakResponse) or ((gmd:maxValue or gmd:minValue or gmd:peakResponse) and gmd:units/*)">
			  Units are mandatory if maxValue, minValue, or peakResponse is provided.</sch:assert>
	  </sch:rule>
  </sch:pattern>
  
</sch:schema>
