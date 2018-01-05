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
  <!-- ******** Only intended for use with NMIS - Part 2, Version 2.2   ******** -->
  <!-- ************************************************************************* -->
  
  <!-- 
    Restricts content based on constraints specified by ISO/TS 19139-2 that
      cannot be enforced using XSD.
    For ease in comparative and functional analysis, some XSD constraints
      on the presence of elements may also be duplicated here.
  -->

  <sch:title>NMIS ISO/TS 19139-2 Schematron validation</sch:title>

  <sch:ns prefix="sch" uri="http://purl.oclc.org/dsdl/schematron"/>
  <sch:ns prefix="gmd" uri="http://www.isotc211.org/2005/gmd"/>
  <sch:ns prefix="gco" uri="http://www.isotc211.org/2005/gco"/>
  <sch:ns prefix="gss" uri="http://www.isotc211.org/2005/gss"/>
  <sch:ns prefix="gmi" uri="http://www.isotc211.org/2005/gmi"/>
  <sch:ns prefix="gml" uri="http://www.opengis.net/gml/3.2"/>
  <sch:ns prefix="xlink" uri="http://www.w3.org/1999/xlink"/>
  <sch:ns prefix="ism" uri="urn:us:gov:ic:ism"/>
  <sch:ns prefix="nas" uri="http://metadata.ces.mil/dse/ns/GSIP/5.0/nas"/>
  <sch:ns prefix="reg" uri="http://api.nsgreg.nga.mil/schema/register/1.0"/>
  
  <sch:let name="NSGREG" value="'http://api.nsgreg.nga.mil'"/>
  <sch:let name="NMF_part2_profile" value="(//gmd:DQ_DataQuality/gmd:report) or (//gmd:DQ_DataQuality/gmd:lineage/gmd:LI_Lineage/gmd:processStep) or (//gmd:DQ_DataQuality/gmd:lineage/LI_Lineage/gmd:source)"/>
  <sch:let name="NMF_part3_profile" value="(//gmi:MI_Georectified) or (//gmi:MI_Georeferenceable) or (//gmd:MD_CoverageDescription) or (//gmi:MI_ImageDescription) or (//gmi:MI_AcquisitionInformation)"/>

  <!-- ************************************************************************ -->
  <!-- ******** ISO 19115-2 Clause A.2.5 Acquisition Information ******** -->
  <!-- ************************************************************************ -->
  
  <sch:pattern id="Operation_identifier_must_be_validly_specified">
	<sch:rule context="gmi:MI_Operation">
	  <sch:assert test="gmi:identifier and (count(gmi:identifier)=1)">
	    Operation must include exactly one identifier element.</sch:assert>
	</sch:rule>
  </sch:pattern>

  <!-- *************************************************************************** -->
  <!-- ******** ISO 19115-2 Clause A.2.3 Spatial representation information ******** -->
  <!-- *************************************************************************** -->

  <sch:pattern id="MI_Georectified_must_have_Consistent_check_point_values">
	  <sch:rule context="gmi:MI_Georectified">
		  <sch:assert test="gmd:checkPointAvailability/gco:Boolean='false' or (gmd:checkPointAvailability/gco:Boolean='true' and gmd:checkPointDescription/*)">
		  The Boolean value check point availability is true and the check point description is either missing or has no content.</sch:assert>
	  </sch:rule>
  </sch:pattern>
  
  <!--<sch:pattern id="GMD_Georectified_cornerPoints_must_be_present">
    <sch:rule context="gmd:MD_Georectified">
      <sch:test assert="gmd:cornerPoints">
        Georectified must include at least one cornerPoints element.</sch:test>
    </sch:rule>
  </sch:pattern>
  
  <sch:pattern id="GMI_Georectified_cornerPoints_must_be_present">
    <sch:rule context="gmi:MI_Georectified">
      <sch:test assert="gmd:cornerPoints">
        Georectified must include at least one cornerPoints element.</sch:test>
    </sch:rule>
  </sch:pattern>-->
  
  <sch:pattern id="Georectified_must_not_have_ExcludedContent">
    <sch:rule context="gmi:MI_Georectified">
      <sch:assert test="not(gmi:geolocationIndentification)">
        The georectified geolocationIdentification element must not be used.</sch:assert>
    </sch:rule>
  </sch:pattern>
  
  <!--<sch:pattern id="GridSpatialRepresentation_georectified_axisDimensionProperties_must_be_present">
    <sch:rule context="gmi:MI_Georectified">
      <sch:assert test="gmd:axisDimensionProperties">
        Georectified must include at least one axisDimensionProperties element.</sch:assert>
    </sch:rule>
  </sch:pattern>
  
  <sch:pattern id="GridSpatialRepresentation_georeferenceable_axisDimensionProperties_must_be_present">
    <sch:rule context="gmi:MI_Georeferenceable">
      <sch:assert test="gmd:axisDimensionProperties">
        Georeferenceable must include at least one axisDimensionProperties element.</sch:assert>
    </sch:rule>
  </sch:pattern>-->
    
    <sch:pattern id="AccuracyReport_prohibited_when_no_part2NMF">
		<sch:rule context="gmi:MI_GCP">
			<sch:assert test="$NMF_part2_profile or (not($NMF_part2_profile) and not(gmi:accuracyReport))">
				When Part 2 (of the NMF) is not present, the accuracyReport element of MI_GCP is prohibited.</sch:assert>
		</sch:rule>
    </sch:pattern>
  
  <!-- NMIS 2.2 - Removed: Not supported by any standards documentation or resource. -->
  <!--<sch:pattern id="MI_InstrumentType_uses_SensorTypeCode">
	  <sch:rule context="gmi:MI_Instrument/gmi:type">
		  <sch:assert test="gmi:MI_SensorTypeCode">
			  All MI_Instrument type descriptions shall have a  sensor type code as their content</sch:assert>
	  </sch:rule>
  </sch:pattern>-->
  
  <sch:pattern id="Band_must_have_content">
    <sch:rule context="gmi:MI_Band">
      <sch:assert test="*">
        Band must have content</sch:assert>
    </sch:rule>
  </sch:pattern>
  
  <sch:pattern id="Band_units_must_be_present_if_min_and_max_values_present">
	  <sch:rule context="gmi:MI_Band">
		  <sch:assert test="not(gmd:maxValue or gmd:minValue or gmd:peakResponse) or ((gmd:maxValue or gmd:minValue or gmd:peakResponse) and (gmd:units/@xlink:href or gmd:units/*))">
			  Units are mandatory if maxValue, minValue, or peakResponse is provided.</sch:assert>
	  </sch:rule>
  </sch:pattern>
  
  <sch:pattern id="ImageDescription_must_have_content">
    <sch:rule context="gmi:MI_ImageDescription">
      <sch:assert test="*">
        RangeDimension must have content</sch:assert>
    </sch:rule>
  </sch:pattern>
  
  <sch:pattern id="AcquisitionInformation_must_have_content">
    <sch:rule context="gmi:MI_AcquisitionInformation">
      <sch:assert test="*">
        AcquisitionInformation must have content</sch:assert>
    </sch:rule>
  </sch:pattern>
    
    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  <!-- - - - - - - - - - - - - - Code List Restriction - - - - - - - - - - - - - - - - - - - - -->
  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  
  <sch:pattern id="BandDefinition_Valid_in_Resouce">
    <sch:rule context="gmi:MI_BandDefinition">
	  <sch:assert test="@codeList = concat($NSGREG, '/codelist/BandDefinition')">
	    The code list mush reference an NMF-appropriate published resource.</sch:assert>
	  <sch:let name="url" value="concat(@codeList, '/', @codeListValue)"/>
      <sch:assert test="document($url)">
        The URL '<sch:value-of select="$url"/>' must reference a net-accessible resource.</sch:assert>
      <sch:assert test="normalize-space(.) = ''">The element must be empty.</sch:assert>
      <!-- Verify that the content of the resource matches the instance document -->
      <sch:assert test="@codeList = document($url)/reg:ListedValue/gml:identifier/@codeSpace">
        The specified codeList must match the codespace of the identifier in the resource.</sch:assert>
      <sch:assert test="@codeListValue = document($url)/reg:ListedValue/gml:identifier">
        The specified codeListValue must match the value of the identifier in the resource.</sch:assert>
    </sch:rule>
  </sch:pattern>

  <sch:pattern id="ContextCode_Valid_in_Resouce">
    <sch:rule context="gmi:MI_ContextCode">
	  <sch:assert test="@codeList = concat($NSGREG, '/codelist/ContextCode')">
	    The code list mush reference an NMF-appropriate published resource.</sch:assert>
	  <sch:let name="url" value="concat(@codeList, '/', @codeListValue)"/>
      <sch:assert test="document($url)">
        The URL '<sch:value-of select="$url"/>' must reference a net-accessible resource.</sch:assert>
      <sch:assert test="normalize-space(.) = ''">The element must be empty.</sch:assert>
      <!-- Verify that the content of the resource matches the instance document -->
      <sch:assert test="@codeList = document($url)/reg:ListedValue/gml:identifier/@codeSpace">
        The specified codeList must match the codespace of the identifier in the resource.</sch:assert>
      <sch:assert test="@codeListValue = document($url)/reg:ListedValue/gml:identifier">
        The specified codeListValue must match the value of the identifier in the resource.</sch:assert>
    </sch:rule>
  </sch:pattern>

  <sch:pattern id="GeometryTypeCode_Valid_in_Resouce">
    <sch:rule context="gmi:MI_GeometryTypeCode">
	  <sch:assert test="@codeList = concat($NSGREG, '/codelist/GeometryTypeCode')">
	    The code list mush reference an NMF-appropriate published resource.</sch:assert>
	  <sch:let name="url" value="concat(@codeList, '/', @codeListValue)"/>
      <sch:assert test="document($url)">
        The URL '<sch:value-of select="$url"/>' must reference a net-accessible resource.</sch:assert>
      <sch:assert test="normalize-space(.) = ''">The element must be empty.</sch:assert>
      <!-- Verify that the content of the resource matches the instance document -->
      <sch:assert test="@codeList = document($url)/reg:ListedValue/gml:identifier/@codeSpace">
        The specified codeList must match the codespace of the identifier in the resource.</sch:assert>
      <sch:assert test="@codeListValue = document($url)/reg:ListedValue/gml:identifier">
        The specified codeListValue must match the value of the identifier in the resource.</sch:assert>
    </sch:rule>
  </sch:pattern>

  <sch:pattern id="ObjectiveTypeCode_Valid_in_Resouce">
    <sch:rule context="gmi:MI_ObjectiveTypeCode">
	  <sch:assert test="@codeList = concat($NSGREG, '/codelist/ObjectiveTypeCode')">
	    The code list mush reference an NMF-appropriate published resource.</sch:assert>
	  <sch:let name="url" value="concat(@codeList, '/', @codeListValue)"/>
      <sch:assert test="document($url)">
        The URL '<sch:value-of select="$url"/>' must reference a net-accessible resource.</sch:assert>
      <sch:assert test="normalize-space(.) = ''">The element must be empty.</sch:assert>
      <!-- Verify that the content of the resource matches the instance document -->
      <sch:assert test="@codeList = document($url)/reg:ListedValue/gml:identifier/@codeSpace">
        The specified codeList must match the codespace of the identifier in the resource.</sch:assert>
      <sch:assert test="@codeListValue = document($url)/reg:ListedValue/gml:identifier">
        The specified codeListValue must match the value of the identifier in the resource.</sch:assert>
    </sch:rule>
  </sch:pattern>

  <sch:pattern id="OperationTypeCode_Valid_in_Resouce">
    <sch:rule context="gmi:MI_OperationTypeCode">
	  <sch:assert test="@codeList = concat($NSGREG, '/codelist/OperationTypeCode')">
	    The code list mush reference an NMF-appropriate published resource.</sch:assert>
	  <sch:let name="url" value="concat(@codeList, '/', @codeListValue)"/>
      <sch:assert test="document($url)">
        The URL '<sch:value-of select="$url"/>' must reference a net-accessible resource.</sch:assert>
      <sch:assert test="normalize-space(.) = ''">The element must be empty.</sch:assert>
      <!-- Verify that the content of the resource matches the instance document -->
      <sch:assert test="@codeList = document($url)/reg:ListedValue/gml:identifier/@codeSpace">
        The specified codeList must match the codespace of the identifier in the resource.</sch:assert>
      <sch:assert test="@codeListValue = document($url)/reg:ListedValue/gml:identifier">
        The specified codeListValue must match the value of the identifier in the resource.</sch:assert>
    </sch:rule>
  </sch:pattern>

  <sch:pattern id="PolarisationOrientationCode_Valid_in_Resouce">
    <sch:rule context="gmi:MI_PolarisationOrientationCode">
	  <sch:assert test="@codeList = concat($NSGREG, '/codelist/PolarisationOrientationCode')">
	    The code list mush reference an NMF-appropriate published resource.</sch:assert>
	  <sch:let name="url" value="concat(@codeList, '/', @codeListValue)"/>
      <sch:assert test="document($url)">
        The URL '<sch:value-of select="$url"/>' must reference a net-accessible resource.</sch:assert>
      <sch:assert test="normalize-space(.) = ''">The element must be empty.</sch:assert>
      <!-- Verify that the content of the resource matches the instance document -->
      <sch:assert test="@codeList = document($url)/reg:ListedValue/gml:identifier/@codeSpace">
        The specified codeList must match the codespace of the identifier in the resource.</sch:assert>
      <sch:assert test="@codeListValue = document($url)/reg:ListedValue/gml:identifier">
        The specified codeListValue must match the value of the identifier in the resource.</sch:assert>
    </sch:rule>
  </sch:pattern>

  <sch:pattern id="PriorityCode_Valid_in_Resouce">
    <sch:rule context="gmi:MI_PriorityCode">
	  <sch:assert test="@codeList = concat($NSGREG, '/codelist/PriorityCode')">
	    The code list mush reference an NMF-appropriate published resource.</sch:assert>
	  <sch:let name="url" value="concat(@codeList, '/', @codeListValue)"/>
      <sch:assert test="document($url)">
        The URL '<sch:value-of select="$url"/>' must reference a net-accessible resource.</sch:assert>
      <sch:assert test="normalize-space(.) = ''">The element must be empty.</sch:assert>
      <!-- Verify that the content of the resource matches the instance document -->
      <sch:assert test="@codeList = document($url)/reg:ListedValue/gml:identifier/@codeSpace">
        The specified codeList must match the codespace of the identifier in the resource.</sch:assert>
      <sch:assert test="@codeListValue = document($url)/reg:ListedValue/gml:identifier">
        The specified codeListValue must match the value of the identifier in the resource.</sch:assert>
    </sch:rule>
  </sch:pattern>

  <sch:pattern id="SequenceCode_Valid_in_Resouce">
    <sch:rule context="gmi:MI_SequenceCode">
	  <sch:assert test="@codeList = concat($NSGREG, '/codelist/SequenceCode')">
	    The code list mush reference an NMF-appropriate published resource.</sch:assert>
	  <sch:let name="url" value="concat(@codeList, '/', @codeListValue)"/>
      <sch:assert test="document($url)">
        The URL '<sch:value-of select="$url"/>' must reference a net-accessible resource.</sch:assert>
      <sch:assert test="normalize-space(.) = ''">The element must be empty.</sch:assert>
      <!-- Verify that the content of the resource matches the instance document -->
      <sch:assert test="@codeList = document($url)/reg:ListedValue/gml:identifier/@codeSpace">
        The specified codeList must match the codespace of the identifier in the resource.</sch:assert>
      <sch:assert test="@codeListValue = document($url)/reg:ListedValue/gml:identifier">
        The specified codeListValue must match the value of the identifier in the resource.</sch:assert>
    </sch:rule>
  </sch:pattern>

  <sch:pattern id="TransferFunctionTypeCode_Valid_in_Resouce">
    <sch:rule context="gmi:MI_TransferFunctionTypeCode">
	  <sch:assert test="@codeList = concat($NSGREG, '/codelist/TransferFunctionTypeCode')">
	    The code list mush reference an NMF-appropriate published resource.</sch:assert>
	  <sch:let name="url" value="concat(@codeList, '/', @codeListValue)"/>
      <sch:assert test="document($url)">
        The URL '<sch:value-of select="$url"/>' must reference a net-accessible resource.</sch:assert>
      <sch:assert test="normalize-space(.) = ''">The element must be empty.</sch:assert>
      <!-- Verify that the content of the resource matches the instance document -->
      <sch:assert test="@codeList = document($url)/reg:ListedValue/gml:identifier/@codeSpace">
        The specified codeList must match the codespace of the identifier in the resource.</sch:assert>
      <sch:assert test="@codeListValue = document($url)/reg:ListedValue/gml:identifier">
        The specified codeListValue must match the value of the identifier in the resource.</sch:assert>
    </sch:rule>
  </sch:pattern>

  <sch:pattern id="TriggerCode_Valid_in_Resouce">
    <sch:rule context="gmi:MI_TriggerCode">
	  <sch:assert test="@codeList = concat($NSGREG, '/codelist/TriggerCode')">
	    The code list mush reference an NMF-appropriate published resource.</sch:assert>
	  <sch:let name="url" value="concat(@codeList, '/', @codeListValue)"/>
      <sch:assert test="document($url)">
        The URL '<sch:value-of select="$url"/>' must reference a net-accessible resource.</sch:assert>
      <sch:assert test="normalize-space(.) = ''">The element must be empty.</sch:assert>
      <!-- Verify that the content of the resource matches the instance document -->
      <sch:assert test="@codeList = document($url)/reg:ListedValue/gml:identifier/@codeSpace">
        The specified codeList must match the codespace of the identifier in the resource.</sch:assert>
      <sch:assert test="@codeListValue = document($url)/reg:ListedValue/gml:identifier">
        The specified codeListValue must match the value of the identifier in the resource.</sch:assert>
    </sch:rule>
  </sch:pattern>

</sch:schema>
