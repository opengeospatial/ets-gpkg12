<?xml version="1.0" encoding="UTF-8"?>
<sch:schema
  xmlns:sch="http://purl.oclc.org/dsdl/schematron"
  xmlns:gmd="http://www.isotc211.org/2005/gmd"
  xmlns:gmi="http://www.isotc211.org/2005/gmi"
  xmlns:gco="http://www.isotc211.org/2005/gco"
  xmlns:gss="http://www.isotc211.org/2005/gss"
  xmlns:gml="http://www.opengis.net/gml/3.2"
  xmlns:genc="http://api.nsgreg.nga.mil/schema/genc/2.0"
  xmlns:genc-cmn="http://api.nsgreg.nga.mil/schema/genc/2.0/genc-cmn"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:ism="urn:us:gov:ic:ism"
  xmlns:nas="http://metadata.ces.mil/dse/ns/GSIP/5.0/nas"
  xml:lang="en">

  <!-- ************************************************************************* -->
  <!-- ******** Only intended for use with NMIS - Part 2, Version 2.1.0 ******** -->
  <!-- ************************************************************************* -->
  
  <!-- 
    Restricts XML component cardinalities as specified in NMIS - Part 2, Table 4,
      equivalent to increasing the value of the minOccurs facet from zero to one
      or decreasing the value of the maxOccurs facet from unbounded to a
      smaller fixed number, such as one.
   Restricts XML component domains as specified in NMIS - Part 2, Table 4 and
      Table 7, e.g., requiring that the values of nas:MD_Metadata/gmd:hierarchyLevel
      be only those established by codeList
      "http://metadata.ces.mil/dse/ns/GSIP/codelist/ScopeCode".
   Restricts XML component code lists to those defined by DSE-based authoritative
      namespaces as specified in NMIS - Part 2, Table 10 and Annex B.3.4.
  -->
  
  <sch:title>NMIS GMD Profile Restriction Schematron validation</sch:title>
  
  <sch:ns prefix="sch" uri="http://purl.oclc.org/dsdl/schematron"/>
  <sch:ns prefix="gmd" uri="http://www.isotc211.org/2005/gmd"/>
  <sch:ns prefix="gmi" uri="http://www.isotc211.org/2005/gmi"/>
  <sch:ns prefix="gco" uri="http://www.isotc211.org/2005/gco"/>
  <sch:ns prefix="gss" uri="http://www.isotc211.org/2005/gss"/>
  <sch:ns prefix="gml" uri="http://www.opengis.net/gml/3.2"/>
  <sch:ns prefix="genc" uri="http://api.nsgreg.nga.mil/schema/genc/2.0"/>
  <sch:ns prefix="genc-cmn" uri="http://api.nsgreg.nga.mil/schema/genc/2.0/genc-cmn"/>
  <sch:ns prefix="xlink" uri="http://www.w3.org/1999/xlink"/>
  <sch:ns prefix="ism" uri="urn:us:gov:ic:ism"/>
  <sch:ns prefix="nas" uri="http://metadata.ces.mil/dse/ns/GSIP/5.0/nas"/>
  <sch:ns prefix="reg" uri="http://api.nsgreg.nga.mil/schema/register/1.0"/>
  
  <!--
    Note that the paths in the following are for referencing
    codelists and therefore contine to use the 'mdr' path-component
    since that's how these resources are currently specified in the MDR.
    This will change in the next NMIS release to instead use the NSG Standards
    Registry component: Information Resources (IR) Registry.
  -->
  <sch:let name="GPAS" value="'http://metadata.ces.mil/mdr/ns/GPAS'"/>
  <sch:let name="GSIP" value="'http://metadata.ces.mil/mdr/ns/GSIP'"/>
  <sch:let name="NSGREG" value="'http://api.nsgreg.nga.mil'"/>
  <sch:let name="NMF_part2_profile" value="(//gmd:DQ_DataQuality/gmd:report) or (//gmd:DQ_DataQuality/gmd:lineage/gmd:LI_Lineage/gmd:processStep) or (//gmd:DQ_DataQuality/gmd:lineage/LI_Lineage/gmd:source)"/>
  <sch:let name="NMF_part3_profile" value="(//gmi:MI_Georectified) or (//gmi:MI_Georeferenceable) or (//gmd:MD_CoverageDescription) or (//gmi:MI_ImageDescription) or (//gmi:MI_AcquisitionInformation)"/>
  <sch:let name="Record_AbstractDataComponent_Subclasses" value="'swe:Quantityswe:QuantityRangeswe:Categoryswe:Booleanswe:Categoryswe:CategoryRangeswe:Countswe:CountRangeswe:Textswe:Timeswe:TimeRangeswe:DataArrayswe:Matrixswe:DataChoiceswe:DataRecordswe:Vector'"/>
  
  
  <!-- ************************************************************************ -->
  <!-- ******** ISO 19115 Clause A.2.1 Metadata entity set information ******** -->
  <!-- ************************************************************************ -->
 
  <sch:pattern id="Metadata_must_have_Content">
    <sch:rule context="gmd:MD_Metadata">
      <sch:assert test="gmd:hierarchLevel/* and (count(gmd:hierarchLevel) = 1)">
        The metadata must include exactly one hierarchal level, with content.</sch:assert>
      <sch:assert test="gmd:hierarchLevelName/* and (count(gmd:hierarchLevelName) = 1)">
        The metadata must include exactly one hierarchal level name with content.</sch:assert>
      <sch:assert test="gmd:metadataStandardName/* and (count(gmd:metadataStandardName) = 1)">
        The metadata must include exactly one meta data Standard Name with content.</sch:assert>
      <sch:assert test="gmd:metadataStandardVersion/* and (count(gmd:metadataStandardVersion) = 1)">
        The metadata must include exactly one meta data Standard Version with content.</sch:assert>      
	 <!--  NMIS 2.2 Remove assertion making locale mandatory -->
     <!--<sch:assert test="gmd:locale/* and (count(gmd:locale) = 1)">
        The metadatae must include exactly one locale, with content.</sch:assert>-->
      <sch:assert test="gmd:metadataConstraints/* and (count(gmd:metadataConstraints) &lt;= 2)">
        The metadata must include at least one but no more than two meta data contraints, with content..</sch:assert>                
    </sch:rule>
  </sch:pattern>

 <sch:pattern id="Locale_must_have_Content">
    <sch:rule context="gmd:PT_Locale">
      <sch:assert test="gmd:country/*">
        The metadata must include at least one country, with content.</sch:assert>               
    </sch:rule>
  </sch:pattern>
  <!-- ******************************************************************* -->
  <!-- ******** ISO 19115 Clause A.2.2 Identification information ******** -->
  <!-- ******************************************************************* -->
  
  <sch:pattern id="Keywords_includes_Content">
    <sch:rule context="gmd:MD_Keywords">
      <sch:assert test="gmd:thesaurusName/*">
        The metadata keywords must include at least 1 thesaurus name, with content.</sch:assert>
    </sch:rule>
  </sch:pattern>
  
  <sch:pattern id="Indentification_includes_Content">
    <sch:rule context="gmd:MD_Indentification">
      <sch:assert test="gmd:pointOfContact/*">
        Identification must include at least 1 point of contact name, with content.</sch:assert>
     <sch:assert test="gmd:descriptiveKeywords/*">
        Identification must include at least 1 descriptive keyword, with content.</sch:assert>
     <sch:assert test="gmd:resourceConstraints/* and (count(gmd:resourceConstraints) &lt;= 2)">
        The metadata must include at least one but no more than two resource contraints, with content..</sch:assert>
    </sch:rule>
  </sch:pattern>
  <!-- *************************************************************** -->
  <!-- ******** ISO 19115 Clause A.2.3 Constraint information ******** -->
  <!-- *************************************************************** -->
  
  <sch:pattern id="SecurityConstraints_include_ClassificationSystem">
    <sch:rule context="*[*/gmd:classificationSystem]">
      <sch:assert test="not(nas:MD_SecurityConstraints or gmd:MD_SecurityConstraints) or */gmd:classificationSystem/*">
        The security constraints must include at least 1 classification system, with content(test).</sch:assert>
    </sch:rule>
  </sch:pattern>
  
  <sch:pattern id="LegalConstraints_must_have_Content">
    <sch:rule context="gmd:MD_LegalConstraints">
      <sch:assert test="gmd:accessConstraints or gmd:useConstraints">
        The legal constraints constraints must have either access or use constraints.</sch:assert>
    </sch:rule>
  </sch:pattern>
  
  <!-- ***************************************************************** -->
  <!-- ******** ISO 19115 Clause A.2.4 Data quality information ******** -->
  <!-- ***************************************************************** -->
  
  <sch:pattern id="Scope_limited_to_One">
    <sch:rule context="gmd:DQ_Scope">
      <sch:assert test="gmd:levelDescription/* and (count(gmd:levelDescription) = 1)">
        The scope must include exactly one level description, with content.</sch:assert>
    </sch:rule>
  </sch:pattern>
  
  <sch:pattern id="Lineage_must_have_content">
    <sch:rule context="gmd:LI_Lineage">
      <sch:assert test="($NMF_part2_profile and *) or (not($NMF_part2_profile) and gmd:statement/*)">
        Lineage must have content.  If only using entities of NMF Part 1 Core, statement must have content.</sch:assert>
    </sch:rule>
  </sch:pattern>
  
  <sch:pattern id="Temporal_extent_must_have_content_type_gmlTimePeriod_or_gmlTimeInstant">
    <sch:rule context="gmd:EX_TemporalExtent/gmd:extent">
	  <sch:assert test="(string-length(normalize-space(@xlink:href)) &gt; 0) or (gml:TimePeriod or gml:TimeInstant)">
        The temporal extent must be either a non-empty xlink:href or it must have content of the type gml:TimerPeriod or gml:TimeInstant</sch:assert>
    </sch:rule>
  </sch:pattern>

  <!-- **************************************************************** -->
  <!-- ******** ISO 19115 Clause A.2.5 Maintenance information ******** -->
  <!-- **************************************************************** -->
  
  <!-- *************************************************************************** -->
  <!-- ******** ISO 19115 Clause A.2.6 Spatial representation information ******** -->
  <!-- *************************************************************************** -->
  
  <sch:pattern id="GridSpatialRepresentation_axisDimensionProperties_must_be_present">
    <sch:rule context="nas:MD_Metadata/gmd:spatialRepresentationInfo">
      <sch:let name="axisDimPropsCount" value="count(*/gmd:axisDimensionProperties)"/>
      <sch:assert test="not((name(*/*[1])='gmd:numberOfDimensions') and (name(*/*[$axisDimPropsCount+2])='gmd:cellGeometry')
                                      and (name(*/*[$axisDimPropsCount+3])='gmd:transformationParameterAvailability')) or */gmd:axisDimensionProperties">
        GridSpatialRepresentation must include at least one axisDimensionProperties element.</sch:assert>
    </sch:rule>
  </sch:pattern>
  
  <sch:pattern id="GMD_Georectified_cornerPoints_must_be_present">
    <sch:rule context="nas:MD_Metadata/gmd:spatialRepresentationInfo">
      <sch:let name="axisDimPropsCount" value="count(*/gmd:axisDimensionProperties)"/>
      <sch:let name="chkPntDescrCount" value="count(*/gmd:checkPointDescription)"/>
      <sch:let name="crnrPntCount" value="count(*/gmd:cornerPoints)"/>
      <sch:let name="ctrPntCount" value="count(*/gmd:centerPoint)"/>
      <sch:let name="elemCountTot1" value="$axisDimPropsCount + $chkPntDescrCount + $crnrPntCount + $ctrPntCount"/>
      <sch:assert test="not((name(*/*[1])='gmd:numberOfDimensions') and (name(*/*[$axisDimPropsCount+4])='gmd:checkPointAvailability')
                                and (name(*/*[$elemCountTot1+5])='gmd:pointInPixel')) or */gmd:cornerPoints">
            Georectified must include at least one cornerPoints element.</sch:assert>
      <!--<sch:assert test="not(gmd:MD_Georectified) or gmi:MD_Georectified/gmd:cornerPoints">
            Georectified must include at least one cornerPoints element.</sch:assert>-->
    </sch:rule>
  </sch:pattern>
  
  <!--<sch:pattern id="GridSpatialRepresentation_axisDimensionProperties_must_be_present">
    <sch:rule context="gmd:MD_GridSpatialRepresentation">
      <sch:assert test="gmd:axisDimensionProperties">
        GridSpatialRepresentation must include at least one axisDimensionProperties element.</sch:assert>
    </sch:rule>
  </sch:pattern>
  
  <sch:pattern id="GSR_Georectified_axisDimensionProperties_must_be_present">
    <sch:rule context="gmd:MD_Georectified">
      <sch:assert test="gmd:axisDimensionProperties">
        Georectified must include at least one axisDimensionProperties element.</sch:assert>
    </sch:rule>
  </sch:pattern>
  
  <sch:pattern id="GSR_Georeferencable_axisDimensionProperties_must_be_present">
    <sch:rule context="gmd:MD_Georeferenceable">
      <sch:assert test="gmd:axisDimensionProperties">
        Georeferenceable must include at least one axisDimensionProperties element.</sch:assert>
    </sch:rule>
  </sch:pattern>-->
  
  <sch:pattern id="VectorSpatialRepresentation_must_have_content">
    <sch:rule context="gmd:MD_VectorSpatialRepresentation">
      <sch:assert test="*">
        MD_VectorSpatialRepresentation must have content</sch:assert>
    </sch:rule>
  </sch:pattern>
  
  <!-- ********************************************************************* -->
  <!-- ******** ISO 19115 Clause A.2.7 Reference system information ******** -->
  <!-- ********************************************************************* -->
  
  <sch:pattern id="MdIdentifier_must_have_Authority">
    <!-- Rule required because if gmd:MD_Identifier/gmd:authority is made mandatory in the XSD
      then it will become mandatory in the gmd:RS_Identifier that extends it - which we do not want!
      Therefore we leave it optional in the gmd:MD_Identifier XSD and make it mandatory here. -->
    <sch:rule context="gmd:MD_Identifier">
      <sch:assert test="gmd:authority">
        The metadata identifier must have an authority.</sch:assert>
    </sch:rule>
  </sch:pattern>
  
  <sch:pattern id="MdIdentifierAuthority_must_be_validly_specified">
    <sch:rule context="gmd:MD_Identifier/gmd:authority">
      <sch:assert test="(string-length(normalize-space(@xlink:href)) &gt; 0) or gmd:CI_Citation">
        The metadata identifier authority must be either a non-empty xlink:href or a valid citation.</sch:assert>
    </sch:rule>
  </sch:pattern>
  
  <sch:pattern id="AuthorityLocalHref_must_be_Valid">
    <sch:rule context="gmd:authority">
      <sch:assert test="not(@xlink:href) or (not(starts-with(@xlink:href, '#')) or (starts-with(@xlink:href, '#') and (//gmd:CI_Citation[@id=(substring-after(current()/@xlink:href,'#'))])))">
        The authority attempts to locally reference a non-existent citation.</sch:assert>
    </sch:rule>
  </sch:pattern> 
  
  <sch:pattern id="RsIdentifierAuthority_must_be_validly_specified">
    <sch:rule context="gmd:RS_Identifier/gmd:authority">
      <sch:assert test="(string-length(normalize-space(@xlink:href)) &gt; 0) or gmd:CI_Citation">
        The metadata identifier authority must be either a non-empty xlink:href or a valid citation.</sch:assert>
    </sch:rule>
  </sch:pattern>
  
  <sch:pattern id="ReferenceSystem_must_have_content">
    <sch:rule context="gmd:MD_ReferenceSystem">
      <sch:assert test="*">
        Reference System must have content</sch:assert>
    </sch:rule>
  </sch:pattern>
  
  <sch:pattern id="Identifier_includes_Content">
    <sch:rule context="gmd:RS_Identifier">
      <sch:assert test="gmd:codeSpace/*">
        RS Identifier must include at least 1 codeSpace, with content.</sch:assert>
    </sch:rule>
  </sch:pattern>
  <!-- ************************************************************ -->
  <!-- ******** ISO 19115 Clause A.2.8 Content information ******** -->
  <!-- ************************************************************ -->
  
  <sch:pattern id="ImageDescription_must_have_content">
    <sch:rule context="gmd:MD_ImageDescription">
      <sch:assert test="*">
        Image description must have content</sch:assert>
    </sch:rule>
  </sch:pattern>
  
  <sch:pattern id="RangeDimension_must_have_content">
    <sch:rule context="gmd:MD_RangeDimension">
      <sch:assert test="*">
        RangeDimension must have content</sch:assert>
    </sch:rule>
  </sch:pattern>
  
  <sch:pattern id="Band_must_have_content">
    <sch:rule context="gmd:MD_Band">
      <sch:assert test="*">
        Band must have content</sch:assert>
    </sch:rule>
  </sch:pattern>
  
  <!-- ************************************************************************ -->
  <!-- ******** ISO 19115 Clause A.2.9 Portrayal catalogue information ******** -->
  <!-- ************************************************************************ -->
  
  <!-- ****************************************************************** -->
  <!-- ******** ISO 19115 Clause A.2.10 Distribution information ******** -->
  <!-- ****************************************************************** -->
  
  <!--<sch:pattern id="DigitalTransferOptions_must_have_Content">
    <sch:rule context="gmd:MD_DigitalTransferOptions">
      <sch:assert test="*">
        The digital transfer options must have content, e.g. on-line resource information.</sch:assert>
    </sch:rule>
  </sch:pattern>-->
  
  <sch:pattern id="NMF_DigitalTransferOptions_must_have_Content">
    <sch:rule context="nas:NMF_DigitalTransferOptions">
      <sch:assert test="*">
        The digital transfer options must have content, e.g. on-line resource information.</sch:assert>
    </sch:rule>
  </sch:pattern>
  
  <!-- ************************************************************************ -->
  <!-- ******** ISO 19115 Clause A.2.11 Metadata extension information ******** -->
  <!-- ************************************************************************ -->
  
  <!-- ************************************************************************ -->
  <!-- ******** ISO 19115 Clause A.2.12 Application Schema information ******** -->
  <!-- ************************************************************************ -->
  
  <!-- *********************************************************** -->
  <!-- ******** ISO 19115 Clause A.3.1 Extent information ******** -->
  <!-- *********************************************************** -->
  
  <sch:pattern id="TimePosition_must_not_have_InconsistentContent">
    <sch:rule context="gml:timePosition">
      <sch:assert test="not(@indeterminatePosition = 'now')">
        The time position indeterminate position 'now' shall not be used.</sch:assert>
      <sch:assert test="not((@indeterminatePosition = 'unknown') and normalize-space(.))">
        The time position indeterminate position 'unknown' shall not be used if there is a specified time position value.</sch:assert>
      <sch:assert test="not(((@indeterminatePosition = 'before') or (@indeterminatePosition = 'after')) and not(normalize-space(.)))">
        The time position indeterminate positions 'before' and 'after' shall not be used if there is no specified time position value..</sch:assert>
    </sch:rule>
  </sch:pattern>
  
  <sch:pattern id="TimeInstantIsolated_must_not_have_InconsistentContent">
    <sch:rule context="gmd:EX_TemporalExtent/gmd:extent/gml:TimeInstant/gml:timePosition">
      <sch:assert test="not(@indeterminatePosition)">
        The time position indeterminate position shall not be used in the case of an isolated time instant (as opposed to one that is participating in a time period).</sch:assert>
    </sch:rule>
  </sch:pattern>
 
  <sch:pattern id="BoundingPolygon_must_have_Content">
    <sch:rule context="gmd:EX_BoundingPolygon">
      <sch:assert test="gmd:polygon/*">
        The bounding polygon must have content.</sch:assert>
    </sch:rule>
  </sch:pattern>
  
  <sch:pattern id="TemporalExtent_must_have_Content">
    <sch:rule context="gmd:EX_TemporalExtent">
      <sch:assert test="gmd:extent/*">
        The temporal extent must have content.</sch:assert>
    </sch:rule>
  </sch:pattern>
  <!--
    When specifying a time instant a degree of precision should be used that is consistent with
    applicable business practices.  However, in the context of enterprise-wide search it is necessary 
    to ensure that a consistent interpretation of reduced-precision values of gml:timePosition is shared.
    
    To this end the following rules shall be observed:
    
    1.	The date/times reported for a time period shall be inclusive in the period.
    
    2.	The reported time shall always be based on Universal Time (UTC), indicated
           by appending the capital letter Z (meaning the "zero meridian") to the time specification. 
           
    3.	Given a truncated specification of date/time (see Table 13) for the start of the period, 
           it shall be understood that for the year specified the period begins at:
              o the first month of the year when the month is not specified,
              o the first day of the month when the day is not specified,
              o the exact specified time when the fractional seconds are not specified, and
              o 00:00:00.0Z when the time is not specified.
              
    4.	Given a truncated specification of date/time (see Table 13) for the end of the period,
           it shall be understood that for the year specified the period ends at:
              o the last month of the year when the month is not specified,
              o the last day of the month when the day is not specified,
              o the specified time plus 0.9 seconds when the fractional seconds are not specified, and
              o 23:59:59.9Z when the time is not specified.
              
    Rigorous observance of these rules when preparing or using NMIS instance documents will ensure
    a consistent understanding of temporal extents.
  -->
  
  <sch:pattern id="TimePosition_must_have_ValidContent">
    <!-- Constrain the value of TimePosition to be a valid gml:CalDate (xs:gYear, xs:gYearMonth, or xs:date) value or valid xs:dateTime value. -->
    <sch:rule context="gml:timePosition">
      <sch:let name="year" value="number(substring(.,1,4))"/>
      <sch:let name="month" value="number(substring(.,6,2))"/>
      <sch:let name="day" value="number(substring(.,9,2))"/>
      <sch:let name="hour" value="number(substring(.,12,2))"/>
      <sch:let name="minute" value="number(substring(.,15,2))"/>
      <sch:let name="second1" value="number(substring(.,18,2))"/>
      <sch:let name="second2" value="number(substring(.,18,4))"/>

      <!-- 23 value from NMIS v2.1 has no known application.  Unused in NMIS v2.2 -->
      <!--<sch:assert test="(string-length(.) &gt;= 4) and (string-length(.) &lt;= 23) or (@indeterminatePosition = 'unknown')">-->
      <!-- Check correct string-length range and that it is a "known" time position -->
      <sch:assert test="(string-length(.) &gt;= 4) and (string-length(.) &lt;= 22) or (@indeterminatePosition = 'unknown')">
        The time position element contains '<sch:value-of select="."/>' but should contain a proper date or dateTime.</sch:assert>
      <!-- Check the CCYY, CCYY-MM, and CCYY-MM-DD patterns -->
      <sch:assert test="not(string-length(.) = 4) or
        ((string-length(.) = 4) and ($year))">
        The time position element contains '<sch:value-of select="."/>' but should contain a year in the format CCYY.</sch:assert>
      <sch:assert test="not((string-length(.) &gt; 4) and (string-length(.) &lt;= 7)) or 
        ((string-length(.) = 7) and ($year) and 
        (substring(.,5,1) = '-') and ($month &gt;= 1 and $month &lt;= 12))">
        The time position element contains '<sch:value-of select="."/>' but should contain a year-month in the format CCYY-MM.</sch:assert>
      <sch:assert test="not((string-length(.) &gt; 7) and (string-length(.) &lt;= 10)) or 
        ((string-length(.) = 10) and ($year) and 
        (substring(.,5,1) = '-') and ($month &gt;= 1 and $month &lt;= 12) and 
        (substring(.,8,1) = '-') and ($day &gt;= 1 and $day &lt;= 31))">
        The time position element contains '<sch:value-of select="."/>' but should contain a year-month-day in the format CCYY-MM-DD.</sch:assert>
      <!-- Check the CCYY-MM-DDTHH:MM:SSZ pattern -->
      <sch:assert test="not((string-length(.) &gt; 12) and (string-length(.) &lt;= 20)) or 
        ((string-length(.) = 20) and ($year) and 
        (substring(.,5,1) = '-') and ($month &gt;= 1 and $month &lt;= 12) and 
        (substring(.,8,1) = '-') and ($day &gt;= 1 and $day &lt;= 31) and
        (substring(.,11,1) = 'T') and ($hour &gt;= 0 and $hour &lt;= 23) and 
        (substring(.,14,1) = ':') and ($minute &gt;= 0 and $minute &lt;= 59) and
        (substring(.,17,1) = ':') and ($second1 &gt;=0 and $second1 &lt;= 59) and
        (substring(.,20,1) = 'Z'))">
        The time position element contains '<sch:value-of select="."/>' but should contain a year-month-day/hour-minute-second in the format CCYY-MM-DDTHH:MM:SSZ.</sch:assert>
      <!-- Check the CCYY-MM-DDTHH:MM:SS.0Z pattern -->
      <sch:assert test="not((string-length(.) &gt; 20) and (string-length(.) &lt;= 22)) or 
        ((string-length(.) = 22) and ($year) and 
        (substring(.,5,1) = '-') and ($month &gt;= 1 and $month &lt;= 12) and 
        (substring(.,8,1) = '-') and ($day &gt;= 1 and $day &lt;= 31) and
        (substring(.,11,1) = 'T') and ($hour &gt;= 0 and $hour &lt;= 23) and 
        (substring(.,14,1) = ':') and ($minute &gt;= 0 and $minute &lt;= 59) and
        (substring(.,17,1) = ':') and ($second2 &gt;=0 and $second1 &lt;= 59) and
        (substring(.,22,1) = 'Z'))">
        The time position element contains '<sch:value-of select="."/>' but should contain a year-month-day/hour-minute-second in the format CCYY-MM-DDTHH:MM:SS.SZ.</sch:assert>
    </sch:rule> 
  </sch:pattern>
    
  <sch:pattern id="TimePeriod_must_not_have_InconsistentEnds">
    <sch:rule context="gml:TimePeriod">
      <sch:assert test="not(gml:begin/gml:TimeInstant/gml:timePosition/@indeterminatePosition = 'after')">
        The begin time position shall not have an indeterminate position of 'after'.</sch:assert>
      <sch:assert test="not(gml:end/gml:TimeInstant/gml:timePosition/@indeterminatePosition = 'before')">
        The end time position shall not have an indeterminate position of 'before'.</sch:assert>
    </sch:rule>
  </sch:pattern>

  <sch:pattern id="TimePeriod_must_have_PositiveDuration">
    <sch:rule context="gml:TimePeriod">
      <sch:let name="year_begin" value="number(substring(gml:begin/gml:TimeInstant/gml:timePosition,1,4))"/>
      <sch:let name="month_begin" value="number(substring(gml:begin/gml:TimeInstant/gml:timePosition,6,2))"/>
      <sch:let name="day_begin" value="number(substring(gml:begin/gml:TimeInstant/gml:timePosition,9,2))"/>
      <sch:let name="hour_begin" value="number(substring(gml:begin/gml:TimeInstant/gml:timePosition,12,2))"/>
      <sch:let name="minute_begin" value="number(substring(gml:begin/gml:TimeInstant/gml:timePosition,15,2))"/>
      <sch:let name="second1_begin" value="number(substring(gml:begin/gml:TimeInstant/gml:timePosition,18,2))"/>
      <sch:let name="second2_begin" value="number(substring(gml:begin/gml:TimeInstant/gml:timePosition,18,4))"/>
      <sch:let name="year_end" value="number(substring(gml:end/gml:TimeInstant/gml:timePosition,1,4))"/>
      <sch:let name="month_end" value="number(substring(gml:end/gml:TimeInstant/gml:timePosition,6,2))"/>
      <sch:let name="day_end" value="number(substring(gml:end/gml:TimeInstant/gml:timePosition,9,2))"/>
      <sch:let name="hour_end" value="number(substring(gml:end/gml:TimeInstant/gml:timePosition,12,2))"/>
      <sch:let name="minute_end" value="number(substring(gml:end/gml:TimeInstant/gml:timePosition,15,2))"/>
      <sch:let name="second1_end" value="number(substring(gml:end/gml:TimeInstant/gml:timePosition,18,2))"/>
      <sch:let name="second2_end" value="number(substring(gml:end/gml:TimeInstant/gml:timePosition,18,4))"/>

      <sch:let name="yrmth_begin" value="number(concat(year_begin, month_begin))"/>
      <sch:let name="yrmth_end" value="number(concat(year_end, month_end))"/>
      <sch:let name="date_begin" value="number(concat(yrmth_begin, day_begin))"/>
      <sch:let name="date_end" value="number(concat(yrmth_end, day_end))"/>
      <sch:let name="datehr_begin" value="number(concat(date_begin, hour_begin))"/>
      <sch:let name="datehr_end" value="number(concat(date_end, hour_end))"/>
      <sch:let name="datehrmn_begin" value="number(concat(datehr_begin, minute_begin))"/>
      <sch:let name="datehrmn_end" value="number(concat(datehr_end, minute_end))"/>
      <sch:let name="fullDate1_begin" value="number(concat(datehrmn_begin, second1_begin))"/>
      <sch:let name="fullDate2_begin" value="number(concat(datehrmn_begin, second2_begin))"/>
      <sch:let name="fullDate1_end" value="number(concat(datehrmn_end, second1_end))"/>
      <sch:let name="fullDate2_end" value="number(concat(datehrmn_end, second2_end))"/>
      
      <!-- Erroneous logic from NMIS v2.1 -->
      <!--<sch:assert test="not(gml:begin/gml:TimeInstant/gml:timePosition/@indeterminatePosition = 'unknown') or not(gml:end/gml:TimeInstant/gml:timePosition/@indeterminatePosition = 'unknown') and
        ((not($year_end) or not($year_begin)) or ($year_begin &lt;= $year_end)) and
        ((not($month_end) or not($month_begin)) or ($month_begin &lt;= $month_end)) and
        ((not($day_end) or not($day_begin)) or ($day_begin &lt;= $day_end)) and
        ((not($hour_end) or not($hour_begin)) or ($hour_begin &lt;= $hour_end)) and
        ((not($minute_end) or not($minute_begin)) or ($minute_begin &lt;= $minute_end)) and
        ((not($second1_end) or not($second1_begin)) or ($second1_begin &lt;= $second1_end)) and
        ((not($second2_end) or not($second2_begin)) or ($second2_begin &lt;= $second2_end))">
        The time period element specifies a non-positive duration: '<sch:value-of select="gml:begin/gml:TimeInstant/gml:timePosition"/>' to '<sch:value-of select="gml:end/gml:TimeInstant/gml:timePosition"/>'.</sch:assert>--> 
        
      <!-- If the start-value is missing then it is always inferred to be the minimum-allowed value and thus the interval is valid. -->
      <!-- If the end-value is missing then it is always inferred to be the maximum-allowed value and thus the interval is also valid. -->
      <sch:assert test="not(gml:begin/gml:TimeInstant/gml:timePosition/@indeterminatePosition = 'unknown') or not(gml:end/gml:TimeInstant/gml:timePosition/@indeterminatePosition = 'unknown') and
        ((not($year_end) or not($year_begin)) or ($year_begin &lt;= $year_end)) and
        ((not($month_end) or not($month_begin)) or ($yrmth_begin &lt;= $yrmth_end)) and
        ((not($day_end) or not($day_begin)) or ($date_begin &lt;= $date_end)) and
        ((not($hour_end) or not($hour_begin)) or ($datehr_begin &lt;= $datehr_end)) and
        ((not($minute_end) or not($minute_begin)) or ($datehrmn_begin &lt;= $datehrmn_end)) and
        ((not($second1_end) or not($second1_begin)) or ($fullDate1_begin &lt;= $fullDate1_end)) and
        ((not($second2_end) or not($second2_begin)) or ($fullDate2_begin &lt;= $fullDate2_end))">
        The time period element specifies a non-positive duration: '<sch:value-of select="gml:begin/gml:TimeInstant/gml:timePosition"/>' to '<sch:value-of select="gml:end/gml:TimeInstant/gml:timePosition"/>'.</sch:assert>
    </sch:rule> 
  </sch:pattern>
  
  <sch:pattern id="VerticalExtent_Valid">
    <sch:rule context="gmd:EX_VerticalExtent">
      <sch:assert test="gmd:minimumValue/gco:Real &lt;= gmd:maximumValue/gco:Real">
        The vertical extent must be a valid interval.</sch:assert>
    </sch:rule>
  </sch:pattern>
  
  <!-- *********************************************************************************** -->
  <!-- ******** ISO 19115 Clause A.3.2 Citation and responsible party information ******** -->
  <!-- *********************************************************************************** -->
  
  <sch:pattern id="Contact_must_be_validly_specified">
    <sch:rule context="gmd:contact">
      <sch:assert test="(string-length(normalize-space(@xlink:href)) &gt; 0) or gmd:CI_ResponsibleParty">
        The contact must have valid content, either as an xlink:href or a valid responsible party.</sch:assert>
    </sch:rule>
  </sch:pattern>

  <sch:pattern id="ContactLocalHref_must_be_Valid">
    <sch:rule context="gmd:contact">
      <sch:assert test="not(@xlink:href) or (not(starts-with(@xlink:href, '#')) or (starts-with(@xlink:href, '#') and (//gmd:CI_ResponsibleParty[@id=(substring-after(current()/@xlink:href,'#'))])))">
        The contact attempts to locally reference a non-existent responsible party.</sch:assert>
    </sch:rule>
  </sch:pattern>
 
  <sch:pattern id="Series_must_have_Content">
    <sch:rule context="gmd:CI_Series">
      <sch:assert test="*">
        The series must have content, e.g., a name.</sch:assert>
    </sch:rule>
  </sch:pattern>
  
  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  <!-- - - - - - - - - - - - - - Code List Restriction - - - - - - - - - - - - - - - - - - - - -->
  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  
  <sch:pattern id="CellGeometryCode_Valid_in_Resouce">
    <sch:rule context="gmd:MD_CellGeometryCode">
	  <sch:assert test="@codeList = concat($NSGREG, '/codelist/CellGeometryCode')">
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

  <sch:pattern id="CharacterSetCode_Valid_in_Resource">
    <sch:rule context="gmd:MD_CharacterSetCode">
      <sch:assert test="@codeList = concat($GSIP, '/codelist/CharacterSetCode') or
								 @codeList = concat($NSGREG, '/codelist/CharacterSetCode')">
        The code list must reference an NMF-appropriate published NSG Registry resource. (DSE resources depricated)</sch:assert>
      <sch:let name="url" value="concat(@codeList, '/', @codeListValue)"/>
      <sch:assert test="document($url)">
        The URL '<sch:value-of select="$url"/>' must reference a net-accessible resource.</sch:assert>
      <sch:assert test="normalize-space(.) = ''">The element must be empty.</sch:assert>
      <!-- Verify that the content of the resource matches the instance document -->
      <sch:assert test="(@codeList = document($url)/gml:Definition/gml:identifier/@codeSpace) or
								 (@codeList = document($url)/reg:ListedValue/gml:identifier/@codeSpace)">
        The specified codeList must match the codespace of the identifier in the resource.</sch:assert>
      <sch:assert test="(@codeListValue = document($url)/gml:Definition/gml:identifier) or
								 (@codeListValue = document($url)/reg:ListedValue/gml:identifier)">
        The specified codeListValue must match the value of the identifier in the resource.</sch:assert>
    </sch:rule>
  </sch:pattern>

  <sch:pattern id="ClassificationCode_Valid_in_Resource">
    <sch:rule context="gmd:MD_ClassificationCode">
      <sch:assert test="@codeList = concat($GSIP, '/codelist/ClassificationCode') or
								 @codeList = concat($NSGREG, '/codelist/ClassificationCode')">
        The code list must reference an NMF-appropriate published NSG Registry resource. (DSE resources depricated)</sch:assert>
      <sch:let name="url" value="concat(@codeList, '/', @codeListValue)"/>
      <sch:assert test="document($url)">
        The URL '<sch:value-of select="$url"/>' must reference a net-accessible resource.</sch:assert>
      <sch:assert test="normalize-space(.) = ''">The element must be empty.</sch:assert>
      <!-- Verify that the content of the resource matches the instance document -->
      <sch:assert test="(@codeList = document($url)/gml:Definition/gml:identifier/@codeSpace) or
								 (@codeList = document($url)/reg:ListedValue/gml:identifier/@codeSpace)">
        The specified codeList must match the codespace of the identifier in the resource.</sch:assert>
      <sch:assert test="(@codeListValue = document($url)/gml:Definition/gml:identifier) or
								 (@codeListValue = document($url)/reg:ListedValue/gml:identifier)">
        The specified codeListValue must match the value of the identifier in the resource.</sch:assert>
    </sch:rule>
  </sch:pattern>

  <sch:pattern id="Country_Valid_in_Resource">
    <sch:rule context="gmd:Country">
      <sch:assert test="(@codeList = concat($GPAS, '/codelist/iso3166-1/digraph')) or 
                        (@codeList = concat($GPAS, '/codelist/iso3166-1/trigraph')) or 
                        (@codeList = concat($GPAS, '/codelist/fips10-4/digraph')) or
                        (@codeList = 'http://api.nsgreg.nga.mil/geo-political/GENC/3/2-1') or
                        (@codeList = 'http://api.nsgreg.nga.mil/geo-political/GENC/2/2-1') ">
        The code list must reference an NMF-appropriate published NSG Registry resource. (DSE resources depricated)</sch:assert>
      <sch:let name="url" value="concat(@codeList, '/', @codeListValue)"/>
      <sch:assert test="document($url)">
        The URL '<sch:value-of select="$url"/>' must reference a net-accessible resource.</sch:assert>
      <sch:assert test="normalize-space(.) = ''">The element must be empty.</sch:assert>
      <!-- Verify that the content of the resource matches the instance document -->
      <sch:assert test="(@codeList = document($url)/gml:Definition/gml:identifier/@codeSpace) or
								 (@codeList = document($url)/genc:GeopoliticalEntityEntry/genc:encoding/genc:char3CodeURISet/genc-cmn:codespaceURL)">
        The specified codeList must match the codespace of the identifier in the resource.</sch:assert>
      <sch:assert test="(@codeListValue = document($url)/gml:Definition/gml:identifier) or
								 (@codeListValue = document($url)/genc:GeopoliticalEntityEntry/genc:encoding/genc:char3Code)">
        The specified codeListValue must match the value of the identifier in the resource.</sch:assert>
    </sch:rule>
  </sch:pattern>

  <sch:pattern id="CoverageContentTypeCode_Valid_in_Resouce">
    <sch:rule context="gmd:MD_CoverageContentTypeCode">
      <sch:assert test="@codeList = concat($NSGREG, '/codelist/CoverageContentTypeCode')">
	    The code list mush reference an NMF-appropriate published resource.</sch:assert>
	  <sch:let name="url" value="concat(@codeList, '/', @codeListValue)"/>
      <sch:assert test="document($url)">
        The URL '<sch:value-of select="$url"/>' must reference a net-accessible resource.</sch:assert>
      <sch:assert test="normalize-space(.) = ''">The element must be empty.</sch:assert>
      <!-- Verify that the content of the resource matches the instance document -->
      <sch:assert test="(@codeList = document($url)/reg:ListedValue/gml:identifier/@codeSpace)">
        The specified codeList must match the codespace of the identifier in the resource.</sch:assert>
      <sch:assert test="(@codeListValue = document($url)/reg:ListedValue/gml:identifier)">
        The specified codeListValue must match the value of the identifier in the resource.</sch:assert>
    </sch:rule>
  </sch:pattern>

  <sch:pattern id="DateTypeCode_Valid_in_Resource">
    <sch:rule context="gmd:CI_DateTypeCode">
      <sch:assert test="@codeList = concat($GSIP, '/codelist/DateTypeCode') or
								 @codeList = concat($NSGREG, '/codelist/DateTypeCode')">
        The code list must reference an NMF-appropriate published NSG Registry resource. (DSE resources depricated)</sch:assert>
      <sch:let name="url" value="concat(@codeList, '/', @codeListValue)"/>
      <sch:assert test="document($url)">
        The URL '<sch:value-of select="$url"/>' must reference a net-accessible resource.</sch:assert>
      <sch:assert test="normalize-space(.) = ''">The element must be empty.</sch:assert>
      <!-- Verify that the content of the resource matches the instance document -->
      <sch:assert test="(@codeList = document($url)/gml:Definition/gml:identifier/@codeSpace) or
								 (@codeList = document($url)/reg:ListedValue/gml:identifier/@codeSpace)">
        The specified codeList must match the codespace of the identifier in the resource.</sch:assert>
      <sch:assert test="(@codeListValue = document($url)/gml:Definition/gml:identifier) or
								 (@codeListValue = document($url)/reg:ListedValue/gml:identifier)">
        The specified codeListValue must match the value of the identifier in the resource.</sch:assert>
    </sch:rule>
  </sch:pattern>

  <sch:pattern id="DimensionNameTypeCode_Valid_in_Resouce">
    <sch:rule context="gmd:MD_DimensionNameTypeCode">
      <sch:assert test="@codeList = concat($NSGREG, '/codelist/DimensionNameTypeCode')">
	    The code list mush reference an NMF-appropriate published resource.</sch:assert>
	  <sch:let name="url" value="concat(@codeList, '/', @codeListValue)"/>
      <sch:assert test="document($url)">
        The URL '<sch:value-of select="$url"/>' must reference a net-accessible resource.</sch:assert>
      <sch:assert test="normalize-space(.) = ''">The element must be empty.</sch:assert>
      <!-- Verify that the content of the resource matches the instance document -->
      <sch:assert test="(@codeList = document($url)/reg:ListedValue/gml:identifier/@codeSpace)">
        The specified codeList must match the codespace of the identifier in the resource.</sch:assert>
      <sch:assert test="(@codeListValue = document($url)/reg:ListedValue/gml:identifier)">
        The specified codeListValue must match the value of the identifier in the resource.</sch:assert>
    </sch:rule>
  </sch:pattern>

  <sch:pattern id="KeywordTypeCode_Valid_in_Resource">
    <sch:rule context="gmd:MD_KeywordTypeCode">
      <sch:assert test="@codeList = concat($GSIP, '/codelist/KeywordTypeCode') or
								 @codeList = concat($NSGREG, '/codelist/KeywordTypeCode')">
        The code list must reference an NMF-appropriate published NSG Registry resource. (DSE resources depricated)</sch:assert>
      <sch:let name="url" value="concat(@codeList, '/', @codeListValue)"/>
      <sch:assert test="document($url)">
        The URL '<sch:value-of select="$url"/>' must reference a net-accessible resource.</sch:assert>
      <sch:assert test="normalize-space(.) = ''">The element must be empty.</sch:assert>
      <!-- Verify that the content of the resource matches the instance document -->
      <sch:assert test="(@codeList = document($url)/gml:Definition/gml:identifier/@codeSpace) or
								 (@codeList = document($url)/reg:ListedValue/gml:identifier/@codeSpace)">
        The specified codeList must match the codespace of the identifier in the resource.</sch:assert>
      <sch:assert test="(@codeListValue = document($url)/gml:Definition/gml:identifier) or
								 (@codeListValue = document($url)/reg:ListedValue/gml:identifier)">
        The specified codeListValue must match the value of the identifier in the resource.</sch:assert>
    </sch:rule>
  </sch:pattern>

  <sch:pattern id="ImagingConditionCode_Valid_in_Resouce">
    <sch:rule context="gmd:MD_ImagingConditionCode">
      <sch:assert test="@codeList = concat($NSGREG, '/codelist/ImagingConditionCode')">
	    The code list mush reference an NMF-appropriate published resource.</sch:assert>
	  <sch:let name="url" value="concat(@codeList, '/', @codeListValue)"/>
      <sch:assert test="document($url)">
        The URL '<sch:value-of select="$url"/>' must reference a net-accessible resource.</sch:assert>
      <sch:assert test="normalize-space(.) = ''">The element must be empty.</sch:assert>
      <!-- Verify that the content of the resource matches the instance document -->
      <sch:assert test="(@codeList = document($url)/reg:ListedValue/gml:identifier/@codeSpace)">
        The specified codeList must match the codespace of the identifier in the resource.</sch:assert>
      <sch:assert test="(@codeListValue = document($url)/reg:ListedValue/gml:identifier)">
        The specified codeListValue must match the value of the identifier in the resource.</sch:assert>
    </sch:rule>
  </sch:pattern>

  <sch:pattern id="LanguageCode_Valid_in_Resource">
    <sch:rule context="nas:LanguageCode">
      <sch:assert test="@codeList = concat($GPAS, '/codelist/iso639-2') or
								 @codeList = concat($NSGREG, '/codelist/ISO639-2')">
        The code list must reference an NMF-appropriate published NSG Registry resource. (DSE resources depricated)</sch:assert>
      <sch:let name="url" value="concat(@codeList, '/', @codeListValue)"/>
      <sch:assert test="document($url)">
        The URL '<sch:value-of select="$url"/>' must reference a net-accessible resource.</sch:assert>
      <sch:assert test="normalize-space(.) = ''">The element must be empty.</sch:assert>
      <!-- Verify that the content of the resource matches the instance document -->
      <sch:assert test="@codeList = document($url)/gml:Definition/gml:identifier/@codeSpace or
								 @codeList = document($url)/reg:ListedValue/gml:identifier/@codeSpace">
        The specified codeList must match the codespace of the identifier in the resource.</sch:assert>
      <sch:assert test="@codeListValue = document($url)/gml:Definition/gml:identifier or
								 @codeList = document($url)/reg:ListedValue/gml:identifier">
        The specified codeListValue must match the value of the identifier in the resource.</sch:assert>
    </sch:rule>
  </sch:pattern>

  <sch:pattern id="MaintenanceFrequencyCode_Valid_in_Resource">
    <sch:rule context="gmd:MD_MaintenanceFrequencyCode">
      <sch:assert test="@codeList = concat($GSIP, '/codelist/MaintenanceFrequencyCode') or
								 @codeList = concat($NSGREG, '/codelist/MaintenanceFrequencyCode')">
        The code list must reference an NMF-appropriate NSG Registry resource. (DSE resources depricated)</sch:assert>
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

  <sch:pattern id="ProgressCode_Valid_in_Resouce">
    <sch:rule context="gmd:MD_ProgressCode">
      <sch:assert test="@codeList = concat($NSGREG, '/codelist/ProgressCode')">
	    The code list mush reference an NMF-appropriate published resource.</sch:assert>
	  <sch:let name="url" value="concat(@codeList, '/', @codeListValue)"/>
      <sch:assert test="document($url)">
        The URL '<sch:value-of select="$url"/>' must reference a net-accessible resource.</sch:assert>
      <sch:assert test="normalize-space(.) = ''">The element must be empty.</sch:assert>
      <!-- Verify that the content of the resource matches the instance document -->
      <sch:assert test="(@codeList = document($url)/reg:ListedValue/gml:identifier/@codeSpace)">
        The specified codeList must match the codespace of the identifier in the resource.</sch:assert>
      <sch:assert test="(@codeListValue = document($url)/reg:ListedValue/gml:identifier)">
        The specified codeListValue must match the value of the identifier in the resource.</sch:assert>
    </sch:rule>
  </sch:pattern>

  <sch:pattern id="ResourceAssociationTypeCode_Valid_in_Resource">
    <sch:rule context="gmd:DS_ResourceAssociationTypeCode">
      <sch:assert test="@codeList = concat($GSIP, '/codelist/ResourceAssociationTypeCode') or
								 @codeList = concat($NSGREG, '/codelist/ResourceAssociationTypeCode')">
        The code list must reference an NMF-appropriate published NSG Registry resource. (DSE resources depricated)</sch:assert>
      <sch:let name="url" value="concat(@codeList, '/', @codeListValue)"/>
      <sch:assert test="document($url)">
        The URL '<sch:value-of select="$url"/>' must reference a net-accessible resource.</sch:assert>
      <sch:assert test="normalize-space(.) = ''">The element must be empty.</sch:assert>
      <!-- Verify that the content of the resource matches the instance document -->
      <sch:assert test="(@codeList = document($url)/gml:Definition/gml:identifier/@codeSpace) or
								 (@codeList = document($url)/reg:ListedValue/gml:identifier/@codeSpace)">
        The specified codeList must match the codespace of the identifier in the resource.</sch:assert>
      <sch:assert test="(@codeListValue = document($url)/gml:Definition/gml:identifier) or
								 (@codeListValue = document($url)/reg:ListedValue/gml:identifier)">
        The specified codeListValue must match the value of the identifier in the resource.</sch:assert>
    </sch:rule>
  </sch:pattern>

  <sch:pattern id="RestrictionCode_Valid_in_Resource">
    <sch:rule context="gmd:MD_RestrictionCode">
      <sch:assert test="@codeList = concat($GSIP, '/codelist/RestrictionCode') or
								 @codeList = concat($NSGREG, '/codelist/RestrictionCode')">
        The code list must reference an NMF-appropriate published NSG Registry resource. (DSE resources depricated)</sch:assert>
      <sch:let name="url" value="concat(@codeList, '/', @codeListValue)"/>
      <sch:assert test="document($url)">
        The URL '<sch:value-of select="$url"/>' must reference a net-accessible resource.</sch:assert>
      <sch:assert test="normalize-space(.) = ''">The element must be empty.</sch:assert>
      <!-- Verify that the content of the resource matches the instance document -->
      <sch:assert test="(@codeList = document($url)/gml:Definition/gml:identifier/@codeSpace) or
								 (@codeList = document($url)/reg:ListedValue/gml:identifier/@codeSpace)">
        The specified codeList must match the codespace of the identifier in the resource.</sch:assert>
      <sch:assert test="(@codeListValue = document($url)/gml:Definition/gml:identifier) or
								 (@codeListValue = document($url)/reg:ListedValue/gml:identifier)">
        The specified codeListValue must match the value of the identifier in the resource.</sch:assert>
    </sch:rule>
  </sch:pattern>

  <sch:pattern id="RoleCode_Valid_in_Resource">
    <sch:rule context="gmd:CI_RoleCode">
      <sch:assert test="@codeList = concat($GSIP, '/codelist/RoleCode') or
								 @codeList = concat($NSGREG, '/codelist/RoleCode')">
        The code list must reference an NMF-appropriate published NSG Registry resource. (DSE resources depricated)</sch:assert>
      <sch:let name="url" value="concat(@codeList, '/', @codeListValue)"/>
      <sch:assert test="document($url)">
        The URL '<sch:value-of select="$url"/>' must reference a net-accessible resource.</sch:assert>
      <sch:assert test="normalize-space(.) = ''">The element must be empty.</sch:assert>
      <!-- Verify that the content of the resource matches the instance document -->
      <sch:assert test="(@codeList = document($url)/gml:Definition/gml:identifier/@codeSpace) or
								 (@codeList = document($url)/reg:ListedValue/gml:identifier/@codeSpace)">
        The specified codeList must match the codespace of the identifier in the resource.</sch:assert>
      <sch:assert test="(@codeListValue = document($url)/gml:Definition/gml:identifier) or
								 (@codeListValue = document($url)/reg:ListedValue/gml:identifier)">
        The specified codeListValue must match the value of the identifier in the resource.</sch:assert>
    </sch:rule>
  </sch:pattern>

  <sch:pattern id="ScopeCode_Valid_in_Resource">
    <sch:rule context="gmd:MD_ScopeCode">
      <sch:assert test="@codeList = concat($GSIP, '/codelist/ScopeCode') or
								 @codeList = concat($NSGREG, '/codelist/ScopeCode')">
        The code list must reference an NMF-appropriate published NSG Registry resource. (DSE resources depricated)</sch:assert>
      <sch:let name="url" value="concat(@codeList, '/', @codeListValue)"/>
      <sch:assert test="document($url)">
        The URL '<sch:value-of select="$url"/>' must reference a net-accessible resource.</sch:assert>
      <sch:assert test="normalize-space(.) = ''">The element must be empty.</sch:assert>
      <!-- Verify that the content of the resource matches the instance document -->
      <sch:assert test="(@codeList = document($url)/gml:Definition/gml:identifier/@codeSpace) or
								 (@codeList = document($url)/reg:ListedValue/gml:identifier/@codeSpace)">
        The specified codeList must match the codespace of the identifier in the resource.</sch:assert>
      <sch:assert test="(@codeListValue = document($url)/gml:Definition/gml:identifier) or
								 (@codeListValue = document($url)/reg:ListedValue/gml:identifier)">
        The specified codeListValue must match the value of the identifier in the resource.</sch:assert>
    </sch:rule>
  </sch:pattern>

  <sch:pattern id="SpatialRepresentationTypeCode_Valid_in_Resource">
    <sch:rule context="gmd:MD_SpatialRepresentationTypeCode">
      <sch:assert test="@codeList = concat($GSIP, '/codelist/SpatialRepresentationTypeCode') or
								 @codeList = concat($NSGREG, '/codelist/SpatialRepresentationTypeCode')">
        The code list must reference an NMF-appropriate published NSG Registry resource. (DSE resources depricated)</sch:assert>
      <sch:let name="url" value="concat(@codeList, '/', @codeListValue)"/>
      <sch:assert test="document($url)">
        The URL '<sch:value-of select="$url"/>' must reference a net-accessible resource.</sch:assert>
      <sch:assert test="normalize-space(.) = ''">The element must be empty.</sch:assert>
      <!-- Verify that the content of the resource matches the instance document -->
      <sch:assert test="(@codeList = document($url)/gml:Definition/gml:identifier/@codeSpace) or
								 (@codeList = document($url)/reg:ListedValue/gml:identifier/@codeSpace)">
        The specified codeList must match the codespace of the identifier in the resource.</sch:assert>
      <sch:assert test="(@codeListValue = document($url)/gml:Definition/gml:identifier) or
								 (@codeListValue = document($url)/reg:ListedValue/gml:identifier)">
        The specified codeListValue must match the value of the identifier in the resource.</sch:assert>
    </sch:rule>
  </sch:pattern>
     
  <!-- missing in NMIS 2.1 -->
  <sch:pattern id="TopologyLevelCode_Valid_in_Resource">
    <sch:rule context="gmd:MD_TopologyLevelCode">
      <sch:assert test="@codeList = concat($GSIP, '/codelist/TopologyLevelCode') or
								 @codeList = concat($NSGREG, '/codelist/TopologyLevelCode')">
        The code list must reference an NMF-appropriate NSG Registry resource. (DSE resources depricated)</sch:assert>
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
  <!-- End missing in NMIS 2.1 -->

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  <!-- - - - - - - - - - - - - - Crs Name Restrictions - - - - - - - - - - - - - - - - - - - - -->
  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <sch:pattern id="PolygonSrsName_Valid_in_Resource">
    <sch:rule context="gml:Polygon">
      <sch:assert test="starts-with(@srsName, concat($GSIP, '/crs')) or starts-with(@srsName, concat($NSGREG, '/coord-ref-system'))">
        The CRS must be from the set registered in the NSG Resgistry (DSE GSIP Governance Namespace depricated.)</sch:assert>
      <sch:assert test="document(@srsName)">
        The specified srsName must reference a net-accessible resource in the NSG Registry (DSE GSIP Governance Namespace depricated).</sch:assert>
      <!-- Verify that the content of the resource matches the instance document -->
      <sch:assert test="(concat(substring-before(@srsName, '/crs'),'/crs') = document(@srsName)//gml:identifier/@codeSpace) or
								 (concat(substring-before(@srsName, '/coord-ref-system'), '/coord-ref-system') = document(@srsName)/reg:GeodeticCRS/gml:identifier/@codeSpace)">
        The body of the srsName must match the codeSpace of the identifier in the resource.</sch:assert>
      <sch:assert test="(substring-after(@srsName, 'crs/') = document(@srsName)//gml:identifier) or
								 (substring-after(@srsName, 'coord-ref-system/') = document(@srsName)/reg:GeodeticCRS/gml:identifier)">
        The tail of the srsName ('<sch:value-of select="substring-after(@srsName, 'crs/')"/>') must match the value of the identifier in the resource.</sch:assert>
    </sch:rule>
  </sch:pattern>

  <sch:pattern id="VerticalCRS_Valid_in_Resource">
    <sch:rule context="gmd:verticalCRS">
      <sch:assert test="starts-with(@xlink:href, concat($GSIP, '/crs')) or starts-with(@xlink:href, concat($NSGREG, '/coord-ref-system'))">
        The CRS must be from the set registered in the NSG Resgistry (DSE GSIP Governance Namespace depricated.)</sch:assert>
      <sch:assert test="document(@xlink:href)">
        The specified xlink:href must reference a net-accessible resource in the NSG Resgistry (DSE GSIP Governance Namespace depricated.)</sch:assert>
      <!-- Verify that the content of the resource matches the instance document -->
      <sch:assert test="(concat(substring-before(@xlink:href, '/crs'),'/crs') = document(@xlink:href)//gml:identifier/@codeSpace) or
								 (concat(substring-before(@xlink:href, '/coord-ref-system'), '/coord-ref-system') = document(@xlink:href)/reg:VerticalCRS/gml:identifier/@codeSpace)">
        The body of the srsName must match the codeSpace of the identifier in the resource.</sch:assert>
      <sch:assert test="(substring-after(@xlink:href, 'crs/') = document(@xlink:href)//gml:identifier) or
								 (substring-after(@xlink:href, 'coord-ref-system/') = document(@xlink:href)/reg:VerticalCRS/gml:identifier)">
        The tail of the srsName ('<sch:value-of select="substring-after(@xlink:href, 'crs/')"/>') must match the value of the identifier in the resource.</sch:assert>
    </sch:rule>
  </sch:pattern>
  
  <sch:pattern id="RsIdentifier_Valid_in_Resource">
    <sch:rule context="gmd:RS_Identifier">
      <sch:assert test="(gmd:codeSpace/gco:CharacterString = concat($GSIP, '/crs')) or (gmd:codeSpace/gco:CharacterString = concat($NSGREG, '/coord-ref-system'))">
        The CRS must be from the set registered in the NSG Resgistry (DSE GSIP Governance Namespace depricated.)</sch:assert>
      <sch:let name="url" value="concat(gmd:codeSpace/gco:CharacterString, '/', gmd:code/gco:CharacterString)"/>
      <sch:assert test="document($url)">
        The URL '<sch:value-of select="$url"/>' must reference a net-accessible resource in the NSG Resgistry (DSE GSIP Governance Namespace depricated.)</sch:assert>
      <!-- Verify that the content of the resource matches the instance document -->
      <sch:assert test="(gmd:codeSpace/gco:CharacterString = document($url)//gml:identifier/@codeSpace) or
								 (gmd:codeSpace/gco:CharacterString = document($url)/reg:GeodeticCRS/gml:identifier/@codeSpace)">
        The body of the srsName must match the codeSpace of the identifier in the resource.</sch:assert>
      <sch:assert test="(gmd:code/gco:CharacterString = document($url)//gml:identifier) or
								 (gmd:code/gco:CharacterString = document($url)/reg:GeodeticCRS/gml:identifier)">
        The tail of the srsName ('<sch:value-of select="gmd:code/gco:CharacterString"/>') must match the value of the identifier in the resource.</sch:assert>
    </sch:rule>
  </sch:pattern>
  
  <!-- Given enough GCO test scenarios, create new Schematron file -->
  <sch:pattern id="gco-Record_contains_proper_derived_class">
    <sch:rule context="gco:Record">
	  <sch:let name="APath" value="name(*)"/>
      <sch:assert test="contains($Record_AbstractDataComponent_Subclasses, $APath)">
        Record must be or derived from type AbstractDataComponent.</sch:assert>
    </sch:rule>
  </sch:pattern>
  
</sch:schema>