
package org.opengis.cite.gpkg12.nsg.core;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.text.MessageFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.LinkedList;
import java.util.List;
//import java.util.function.Function;
import java.util.stream.Collectors;
import org.opengis.cite.gpkg12.nsg.util.NSG_XMLUtils;
import org.opengis.referencing.FactoryException;
import org.opengis.referencing.crs.CoordinateReferenceSystem;
import org.geotools.referencing.CRS;
import org.opengis.cite.gpkg12.ErrorMessage;
import org.opengis.cite.gpkg12.ErrorMessageKeys;
import org.opengis.cite.gpkg12.core.SpatialReferenceSystemsTests;
import org.testng.Assert;
import org.testng.SkipException;
import org.testng.annotations.Test;
import org.w3c.dom.Element;
import org.w3c.dom.NodeList;

public class NSG_SpatialReferenceSystemsTests extends SpatialReferenceSystemsTests {
	private final String NSG_CRS_listing = "NSG_CRS_WKT.xml";
	private final String Annex_C_3395_Table = "Annex_C_3395_Table.txt";
	private final String Annex_E_4326_Table = "Annex_E_4326_Table.txt";
	/*
	 * boolean _useHardCode = true; private String CRS_XML_Path = null;
	 */
	private String XML_root = "Row";

	/*
	 * private String CRS_XML_Str =
	 * "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>" +
	 * "<Root xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\">" +
	 * "    <Row>" + "        <srs_name>WGS 84 Geographic 3D</srs_name>" +
	 * "        <srs_id>4979</srs_id>" + "        <organization>EPSG</organization>"
	 * + "        <organization_coordsys_id>4979</organization_coordsys_id>" +
	 * "        <definition>" + "GEODCRS[\"WGS 84\", " +
	 * "DATUM[\"World Geodetic System 1984\"," +
	 * "ELLIPSOID[\"WGS 84\",6378137,298.257223563,LENGTHUNIT[\"metre\",1.0]]]," +
	 * "CS[ellipsoidal,3]," +
	 * "AXIS[\"latitude\",north,ORDER[1],ANGLEUNIT[\"degree\",0.01745329252]]," +
	 * "AXIS[\"longitude\",east,ORDER[2],ANGLEUNIT[\"degree\",0.01745329252]]," +
	 * "AXIS[\"ellipsoidal height\",up,ORDER[3],LENGTHUNIT[\"metre\",1.0]]," +
	 * "ID[\"EPSG\",4979]]" + "		   </definition>" +
	 * "        <description>Used by the GPS satellite navigation system and for NATO military geodetic surveying.</description>"
	 * + "    </Row>" + "    <Row>" +
	 * "        <srs_name>WGS 84 Geographic 2D</srs_name>" +
	 * "        <srs_id>4326</srs_id>" + "        <organization>EPSG</organization>"
	 * + "        <organization_coordsys_id>4326</organization_coordsys_id>" +
	 * "        <definition>" + "GEODCRS[\"WGS 84\"," +
	 * "DATUM[\"World Geodetic System 1984\"," +
	 * "ELLIPSOID[\"WGS 84\",6378137,298.257223563,LENGTHUNIT[\"metre\",1.0]]]," +
	 * "CS[ellipsoidal,2]," + "AXIS[\"latitude\",north,ORDER[1]]," +
	 * "AXIS[\"longitude\",east,ORDER[2]]," + "ANGLEUNIT[\"degree\",0.01745329252],"
	 * + "ID[\"EPSG\",4326]]" + "		   </definition>" +
	 * "        <description>Horizontal component of 3D system. Used by the GPS satellite navigation systemand for NATO military geodetic surveying.</description>"
	 * + "    </Row>" + "    <Row>" +
	 * "        <srs_name>WGS 84 / World Mercator</srs_name>" +
	 * "        <srs_id>3395</srs_id>" + "        <organization>EPSG</organization>"
	 * + "        <organization_coordsys_id>3395</organization_coordsys_id>" +
	 * "        <definition>" + "PROJCRS[\"WGS 84 / World Mercator\"," +
	 * "BASEGEODCRS[\"WGS 84\"," + "DATUM[\"World Geodetic System 1984\"," +
	 * "ELLIPSOID[\"WGS 84\",6378137,298.257223563,LENGTHUNIT[\"metre\",1.0]]]]," +
	 * "CONVERSION[\"World Mercator\"," +
	 * "METHOD[\"Mercator (variant A)\",ID[\"EPSG\",9804]]," +
	 * "PARAMETER[\"Latitude of natural origin\",0,ANGLEUNIT[\"degree\",0.01745329252]],"
	 * +
	 * "PARAMETER[\"Longitude of natural origin\",0,ANGLEUNIT[\"degree\",0.01745329252]],"
	 * + "PARAMETER[\"Scale factor at natural origin\",1,SCALEUNIT[\"unity\",1.0]],"
	 * + "PARAMETER[\"False easting\",0,LENGTHUNIT[\"metre\",1.0]]," +
	 * "PARAMETER[\"False northing\",0,LENGTHUNIT[\"metre\",1.0]]]," +
	 * "CS[cartesian,2]," + "AXIS[\"easting (E)\",east,ORDER[1]]," +
	 * "AXIS[\"northing (N)\",north,ORDER[2]]," + "LENGTHUNIT[\"metre\",1.0]," +
	 * "ID[\"EPSG\",3395]]" + "		   </definition>" +
	 * "        <description>Euro-centric view of world excluding polar areas for very small scale mapping</description>"
	 * + "    </Row>" + "    <Row>" +
	 * "        <srs_name>WGS 84 / UPS North (E,N)</srs_name>" +
	 * "        <srs_id>5041</srs_id>" + "        <organization>EPSG</organization>"
	 * + "        <organization_coordsys_id>5041</organization_coordsys_id>" +
	 * "        <definition>" + "PROJCRS[\"WGS 84 / UPS North (E,N)\"," +
	 * "BASEGEODCRS[\"WGS 84\"," + "DATUM[\"World Geodetic System 1984\"," +
	 * "ELLIPSOID[\"WGS 84\",6378137,298.257223563,LENGTHUNIT[\"metre\",1.0]]]]," +
	 * "CONVERSION[\"Universal Polar Stereographic North\"," +
	 * "METHOD[\"Polar Stereographic (variant A)\",ID[\"EPSG\",9810]]," +
	 * "PARAMETER[\"Latitude of natural origin\",90,ANGLEUNIT[\"degree\",0.01745329252]],"
	 * +
	 * "PARAMETER[\"Longitude of natural origin\",0,ANGLEUNIT[\"degree\",0.01745329252]],"
	 * +
	 * "PARAMETER[\"Scale factor at natural origin\",0.994,SCALEUNIT[\"unity\",1.0]],"
	 * + "PARAMETER[\"False easting\",2000000,LENGTHUNIT[\"metre\",1.0]]," +
	 * "PARAMETER[\"False northing\",2000000,LENGTHUNIT[\"metre\",1.0]]]," +
	 * "CS[cartesian,2]," +
	 * "AXIS[\"easting (E)\",south,MERIDIAN[90,ANGLEUNIT[\"degree\",0.01745329252]],ORDER[1]],"
	 * +
	 * "AXIS[\"northing (N)\",south,MERIDIAN[180,ANGLEUNIT[\"degree\",0.01745329252]],ORDER[2]],"
	 * + "LENGTHUNIT[\"metre\",1.0]," + "ID[\"EPSG\",5041]]" +
	 * "		   </definition>" +
	 * "        <description>Military mapping by NATO north of 60Â° N</description>"
	 * + "    </Row>" + "    <Row>" +
	 * "        <srs_name>WGS 84 / UPS South (E,N)</srs_name>" +
	 * "        <srs_id>5042</srs_id>" + "        <organization>EPSG</organization>"
	 * + "        <organization_coordsys_id>5042</organization_coordsys_id>" +
	 * "        <definition>" + "PROJCRS[\"WGS 84 / UPS South (E,N)\"," +
	 * "BASEGEODCRS[\"WGS 84\"," + "DATUM[\"World Geodetic System 1984\"," +
	 * "ELLIPSOID[\"WGS 84\",6378137,298.257223563,LENGTHUNIT[\"metre\",1.0]]]]," +
	 * "CONVERSION[\"Universal Polar Stereographic South\"," +
	 * "METHOD[\"Polar Stereographic (variant A)\",ID[\"EPSG\",9810]]," +
	 * "PARAMETER[\"Latitude of natural origin\",-90,ANGLEUNIT[\"degree\",0.01745329252]],"
	 * +
	 * "PARAMETER[\"Longitude of natural origin\",0,ANGLEUNIT[\"degree\",0.01745329252]],"
	 * +
	 * "PARAMETER[\"Scale factor at natural origin\",0.994,SCALEUNIT[\"unity\",1.0]],"
	 * + "PARAMETER[\"False easting\",2000000,LENGTHUNIT[\"metre\",1.0]]," +
	 * "PARAMETER[\"False northing\",2000000,LENGTHUNIT[\"metre\",1.0]]]," +
	 * "CS[cartesian,2]," +
	 * "AXIS[\"easting (E)\",north,MERIDIAN[90,ANGLEUNIT[\"degree\",0.01745329252]],ORDER[1]],"
	 * +
	 * "AXIS[\"northing (N)\",north,MERIDIAN[0,ANGLEUNIT[\"degree\",0.01745329252]],ORDER[2]],"
	 * + "LENGTHUNIT[\"metre\",1.0]," + "ID[\"EPSG\",5042]]" +
	 * "		   </definition>" +
	 * "        <description>Military mapping by NATO south of 60Â° S</description>"
	 * + "    </Row>" + "    <Row>" +
	 * "        <srs_name>EGM2008 geoid height</srs_name>" +
	 * "        <srs_id>3855</srs_id>" + "        <organization>EPSG</organization>"
	 * + "        <organization_coordsys_id>3855</organization_coordsys_id>" +
	 * "        <definition>" + "VERTCRS[\"EGM2008 height\"," +
	 * "VDATUM[\"EGM2008 geoid\"]," + "CS[vertical,1]," +
	 * "AXIS[\"gravity-related height (H)\",up]," + "LENGTHUNIT[\"metre\",1.0]," +
	 * "ID[\"EPSG\",3855]]" + "		   </definition>" +
	 * "        <description>Good approximation of Orthometric height above the EGM2008 modelof the geoid. Replaces EGM96 geoid (CRS code 5773).</description>"
	 * + "    </Row>" + "    <Row>" +
	 * "        <srs_name>EGM2008 geoid depth</srs_name>" +
	 * "        <srs_id>8056</srs_id>" + "        <organization>NGA</organization>"
	 * + "        <organization_coordsys_id>8056</organization_coordsys_id>" +
	 * "        <definition>" + "VERTCRS[\"EGM2008 geoid depth\"," +
	 * "VDATUM[\"EGM2008 geoid\",ANCHOR[\"WGS 84 ellipsoid\"]]," + "CS[vertical,1],"
	 * + "AXIS[\"gravity-related depth (D)\",down]," + "LENGTHUNIT[\"metre\",1.0],"
	 * + "ID[\"NSG\",\"8056\"]]" + "		   </definition>" +
	 * "        <description>Good approximation of Orthometric distance below the EGM2008model of the geoid.</description>"
	 * + "    </Row>" + "    <Row>" +
	 * "        <srs_name>EGM96 geoid height</srs_name>" +
	 * "        <srs_id>5773</srs_id>" + "        <organization>EPSG</organization>"
	 * + "        <organization_coordsys_id>5773</organization_coordsys_id>" +
	 * "        <definition>" + "VERTCRS[\"EGM96 height\"," +
	 * "VDATUM[\"EGM96 geoid\"]," + "CS[vertical,1]," +
	 * "AXIS[\"gravity-related height (H)\",up]," + "LENGTHUNIT[\"metre\",1.0]," +
	 * "ID[\"EPSG\",5773]]" + "		   </definition>" +
	 * "        <description>Height surface resulting from the application of the EGM96 geoidmodel to the WGS 84 ellipsoid. Replaces EGM84 geoid height (CRScode 5798). Replaced by EGM2008 geoid height (CRS code 3855).</description>"
	 * + "    </Row>" + "    <Row>" +
	 * "        <srs_name>EGM96 geoid depth</srs_name>" +
	 * "        <srs_id>8047</srs_id>" + "        <organization>NGA</organization>"
	 * + "        <organization_coordsys_id>8047</organization_coordsys_id>" +
	 * "        <definition>" + "VERTCRS[\"EGM96 geoid depth\"," +
	 * "VDATUM[\"EGM96 geoid\",ANCHOR[\"WGS 84 ellipsoid\"]]," + "CS[vertical,1]," +
	 * "AXIS[\"gravity-related depth (D)\",down]," + "LENGTHUNIT[\"metre\",1.0]," +
	 * "ID[\"NSG\",\"8047\"]]" + "		   </definition>" +
	 * "        <description>The distance below the geopotential surface defined by the EarthGravity Model 1996 (EGM96) that is closely associated with the meanocean surface.</description>"
	 * + "    </Row>" + "    <Row>" + "        <srs_name>MSL height</srs_name>" +
	 * "        <srs_id>5714</srs_id>" + "        <organization>EPSG</organization>"
	 * + "        <organization_coordsys_id>5714</organization_coordsys_id>" +
	 * "        <definition>" + "VERTCRS[\"MSL height\"," +
	 * "VDATUM[\"Mean Sea Level\"]," + "CS[vertical,1]," +
	 * "AXIS[\"gravity-related height (H)\",up]," + "LENGTHUNIT[\"metre\",1.0]," +
	 * "ID[\"EPSG\",5714]]" + "		   </definition>" +
	 * "        <description>Height related to the average height of the surface of the sea at a tidestation for all stages of the tide over a 19-year period, usuallydetermined from hourly height readings measured from a fixedpredetermined reference level, usually by survey techniques.</description>"
	 * + "    </Row>" + "    <Row>" + "        <srs_name>MSL depth</srs_name>" +
	 * "        <srs_id>5715</srs_id>" + "        <organization>EPSG</organization>"
	 * + "        <organization_coordsys_id>5715</organization_coordsys_id>" +
	 * "        <definition>" + "VERTCRS[\"MSL depth\"," +
	 * "VDATUM[\"Mean Sea Level\"]," + "CS[vertical,1]," +
	 * "AXIS[\"depth (D)\",down]," + "LENGTHUNIT[\"metre\",1.0]," +
	 * "ID[\"EPSG\",5715]]" + "		   </definition>" +
	 * "        <description>Depth related to the average height of the surface of the sea at a tidestation for all stages of the tide over a 19-year period, usuallydetermined from hourly height readings measured from a fixedpredetermined reference level, usually by survey techniques.</description>"
	 * + "    </Row>" + "</Root>";
	 */
	NSG_SpatialReferenceSystemsTests() {
		/*
		 * this.CRS_XML_Path = "..\\webapps\\TEAMEngine\\WEB-INF\\NSG_LUTs\\"; File
		 * testPath = new File(this.CRS_XML_Path); if ( !testPath.exists() ) // --- if,
		 * for example, in Eclipse IDE Workspace { this.CRS_XML_Path =
		 * ".\\src\\test\\resources\\WEB-INF\\NSG_LUTs\\"; testPath = new
		 * File(this.CRS_XML_Path);
		 * 
		 * if ( !testPath.exists() ) // --- not sure where, assume in local directory {
		 * this.CRS_XML_Path = "."; } }
		 */
	}

	// ----------------------------------------------------
	/*
	 * --- NSG Req 3: The CRSs listed in Table 4, Table 5, and Table 6 SHALL be the
	 * only CRSs used by raster tile pyramid and vector feature data tables in a
	 * GeoPackage.
	 * 
	 */

	@Test(groups = { "NSG" }, description = "NSG Req 3 (identifed CRSs)")
	public void NSG_CRS_Test() throws SQLException {
		NodeList crsList = NSG_XMLUtils.openXMLDocument(this.getClass().getResourceAsStream(this.NSG_CRS_listing),
				this.XML_root);
		/*
		 * NodeList crsList = null; if (this._useHardCode) { crsList =
		 * NSG_XMLUtils.openXMLDocString(this.CRS_XML_Str, this.XML_root); } else {
		 * crsList = NSG_XMLUtils.openXMLDocument(this.CRS_XML_Path + "NSG_CRS_WKT.xml",
		 * this.XML_root); }
		 */
		Assert.assertTrue(crsList != null,
				ErrorMessage.format(ErrorMessageKeys.UNDEFINED_SRS, " - no designated CRS Lookup Table"));

		if (crsList != null) {
			String queryStr = "SELECT srs_id, organization_coordsys_id FROM gpkg_spatial_ref_sys";

			try (final Statement statement = this.databaseConnection.createStatement();
					final ResultSet resultSet = statement.executeQuery(queryStr)) {
				final Collection<String> invalidSrsIds = new LinkedList<>();
				final Collection<String> invalidOrgIds = new LinkedList<>();

				while (resultSet.next()) {
					String srsID = resultSet.getString("srs_id").trim();
					String orgID = resultSet.getString("organization_coordsys_id").trim();

					if (srsID.equals("0") || orgID.equals("0")) {
						continue;
					}
					if (srsID.equals("-1") || orgID.equals("-1")) {
						continue;
					}

					// ---

					Element element = NSG_XMLUtils.getElement(crsList, "srs_id", srsID);
					if (element == null) {
						invalidSrsIds.add(srsID);
					} else {
						String crsOrgID = NSG_XMLUtils.getXMLElementTextValue(element, "organization_coordsys_id")
								.trim();
						if (!crsOrgID.equals(orgID)) {
							invalidOrgIds.add(orgID);
						}
					}
				}
				resultSet.close();
				statement.close();

				Assert.assertTrue(invalidSrsIds.isEmpty(),
						MessageFormat.format("The gpkg_spatial_ref_sys table contains invalid srs_id values {0}",
								invalidSrsIds.stream().map(Object::toString).collect(Collectors.joining(", "))));
				Assert.assertTrue(invalidOrgIds.isEmpty(),
						MessageFormat.format(
								"The gpkg_spatial_ref_sys table contains invalid organization_coordsys_id values {0}",
								invalidOrgIds.stream().map(Object::toString).collect(Collectors.joining(", "))));
			}
		}
	}

	// ----------------------------------------------------

	final private List<Object[]> AnnexC_3395 = new ArrayList<Object[]>();
	final private List<Object[]> AnnexE_4326 = new ArrayList<Object[]>();
	final private double tolerance = 1.0e-10;

	// ---

	private void Add2List(List<Object[]> table, int zoom, double scale, double pixelSz, long matrixWidth,
			long matrixHeight) {
		if (table != null) {
			Object[] row = { zoom, scale, pixelSz, matrixWidth, matrixHeight };
			table.add(row);
		}
	}

	// ---

	private void Add2List(List<Object[]> table, String zoom, String scale, String pixelSz, String matrixWidth,
			String matrixHeight) {
		Add2List(table, Integer.parseInt(zoom), Double.parseDouble(scale), Double.parseDouble(pixelSz),
				Long.parseLong(matrixWidth), Long.parseLong(matrixHeight));
	}

	// ---

	private void PopulateAnnexC() {
		AnnexC_3395.clear();

		try (BufferedReader br = new BufferedReader(
				new InputStreamReader(this.getClass().getResourceAsStream(this.Annex_C_3395_Table), "UTF-8"))) {
			String line = null;
			while ((line = br.readLine()) != null) {
				List<String> items = Arrays.asList(line.split("\\s*,\\s*"));
				if (!items.isEmpty() && (items.size() == 5)) {
					Add2List(AnnexC_3395, items.get(0), items.get(1), items.get(2), items.get(3), items.get(4));
				} else {
					throw new SkipException("Annex C (EPSG:3395) Table is corrupt ");
				}
			}
		} catch (IOException e) {
			throw new SkipException("Annex C (EPSG:3395) Table not available");
		}
		/*
		 * Add2List(AnnexC_3395, 0, 559082264.028718, 156543.033928041, 1, 1);
		 * Add2List(AnnexC_3395, 1, 279541132.014359, 78271.5169640205, 2, 2);
		 * Add2List(AnnexC_3395, 2, 139770566.007179, 39135.7584820103, 4, 4);
		 * Add2List(AnnexC_3395, 3, 69885283.0035897, 19567.8792410051, 8, 8);
		 * Add2List(AnnexC_3395, 4, 34942641.5017949, 9783.9396205026, 16, 16);
		 * Add2List(AnnexC_3395, 5, 17471320.7508974, 4891.9698102513, 32, 32);
		 * Add2List(AnnexC_3395, 6, 8735660.37544872, 2445.9849051256, 64, 64);
		 * Add2List(AnnexC_3395, 7, 4367830.18772436, 1222.9924525628, 128, 128);
		 * Add2List(AnnexC_3395, 8, 2183915.09386218, 611.4962262814, 256, 256);
		 * Add2List(AnnexC_3395, 9, 1091957.54693109, 305.7481131407, 512, 512);
		 * Add2List(AnnexC_3395, 10, 545978.773465545, 152.8740565704, 1024, 1024);
		 * Add2List(AnnexC_3395, 11, 272989.386732772, 76.4370282852, 2048, 2048);
		 * Add2List(AnnexC_3395, 12, 136494.693366386, 38.2185141426, 4096, 4096);
		 * Add2List(AnnexC_3395, 13, 68247.3466831931, 19.1092570713, 8192, 8192);
		 * Add2List(AnnexC_3395, 14, 34123.6733415965, 9.5546285356, 16384, 16384);
		 * Add2List(AnnexC_3395, 15, 17061.8366707983, 4.7773142678, 32768, 32768);
		 * Add2List(AnnexC_3395, 16, 8530.9183353991, 2.3886571339, 65536, 65536);
		 * Add2List(AnnexC_3395, 17, 4265.4591676996, 1.194328567, 131072, 131072);
		 * Add2List(AnnexC_3395, 18, 2132.7295838498, 0.5971642835, 262144, 262144);
		 * Add2List(AnnexC_3395, 19, 1066.3647919249, 0.2985821417, 524288, 524288);
		 * Add2List(AnnexC_3395, 20, 533.1823959624, 0.1492910709, 1048576, 1048576);
		 * Add2List(AnnexC_3395, 21, 266.5911979812, 0.0746455354, 2097152, 2097152);
		 * Add2List(AnnexC_3395, 22, 133.2955989906, 0.0373227677, 4194304, 4194304);
		 * Add2List(AnnexC_3395, 23, 66.6477994953, 0.0186613839, 8388608, 8388608);
		 * Add2List(AnnexC_3395, 24, 33.3238997477, 0.0093306919, 16777216, 16777216);
		 */

	}

	private void PopulateAnnexE() {
		AnnexE_4326.clear();

		try (BufferedReader br = new BufferedReader(
				new InputStreamReader(this.getClass().getResourceAsStream(this.Annex_E_4326_Table), "UTF-8"))) {
			String line = null;
			while ((line = br.readLine()) != null) {
				List<String> items = Arrays.asList(line.split("\\s*,\\s*"));
				if (!items.isEmpty() && (items.size() == 5)) {
					Add2List(AnnexE_4326, items.get(0), items.get(1), items.get(2), items.get(3), items.get(4));
				} else {
					throw new SkipException("Annex E (EPSG:4326) Table is corrupt ");
				}
			}
		} catch (IOException e) {
			throw new SkipException("Annex E (EPSG:4326) Table not available");
		}

		/*
		 * Add2List(AnnexE_4326, 0, 279541132.01435900, 0.7031250, 2, 1);
		 * Add2List(AnnexE_4326, 1, 139770566.00717900, 0.3515625, 4, 2);
		 * Add2List(AnnexE_4326, 2, 69885283.00358960, 0.17578125, 8, 4);
		 * Add2List(AnnexE_4326, 3, 34942641.50179480, 0.0878906250, 16, 8);
		 * Add2List(AnnexE_4326, 4, 17471320.75089740, 0.0439453125, 32, 16);
		 * Add2List(AnnexE_4326, 5, 8735660.37544870, 0.0219726563, 64, 32);
		 * Add2List(AnnexE_4326, 6, 4367830.18772435, 0.0109863281, 128, 64);
		 * Add2List(AnnexE_4326, 7, 2183915.09386218, 0.0054931641, 256, 128);
		 * Add2List(AnnexE_4326, 8, 1091957.54693109, 0.0027465820, 512, 256);
		 * Add2List(AnnexE_4326, 9, 545978.77346554, 0.0013732910, 1024, 512);
		 * Add2List(AnnexE_4326, 10, 272989.38673277, 0.0006866455, 2048, 1024);
		 * Add2List(AnnexE_4326, 11, 136494.69336639, 0.0003433228, 4096, 2048);
		 * Add2List(AnnexE_4326, 12, 68247.34668319, 0.0001716614, 8192, 4096);
		 * Add2List(AnnexE_4326, 13, 34123.67334160, 0.0000858307, 16384, 8192);
		 * Add2List(AnnexE_4326, 14, 17061.83667080, 0.0000429153, 32768, 16384);
		 * Add2List(AnnexE_4326, 15, 8530.91833540, 0.0000214577, 65536, 32768);
		 * Add2List(AnnexE_4326, 16, 4265.45916770, 0.0000107288, 131072, 65536);
		 * Add2List(AnnexE_4326, 17, 2132.72958385, 0.0000053644, 262144, 131072);
		 * Add2List(AnnexE_4326, 18, 1066.36479192, 0.0000026822, 524288, 262144);
		 * Add2List(AnnexE_4326, 19, 533.18239596, 0.0000013411, 1048576, 524288);
		 * Add2List(AnnexE_4326, 20, 266.59119798, 0.0000006706, 2097152, 1048576);
		 * Add2List(AnnexE_4326, 21, 133.29559899, 0.0000003353, 4194304, 2097152);
		 * Add2List(AnnexE_4326, 22, 66.64779950, 0.0000001676, 8388608, 4194304);
		 * Add2List(AnnexE_4326, 23, 33.32389975, 0.0000000838, 16777216, 8388608);
		 */
	}

	// ----------------------------------------------------
	/*
	 * --- NSG Req 4:
	 * 
	 * 
	 * --- NSG Req 5:
	 * 
	 * 
	 */
	@Test(groups = { "NSG" }, description = "NSG Req 4 & 5 (match Annex table)")
	public void NSG_MatchAnnexTableTest() throws SQLException {
		// --- original intent was to implement here; but may make more sense to
		// implement in NSG_TileTests

		final Collection<String> invalidMatrixEntries = new LinkedList<>();

		String queryStr = "SELECT tm.table_name AS tabName, sel.data_type AS dataTyp, sel.crs_id AS crsID, tm.zoom_level AS zoomLvl, tm.matrix_width AS matrixW, tm.matrix_height AS matrixH, tm.tile_width AS tileW, tm.tile_height AS tileH, tm.pixel_x_size AS pixelSzX, tm.pixel_y_size AS pixelSzY "
				+ "FROM gpkg_tile_matrix tm "
				+ "INNER JOIN (SELECT gc.table_name, gc.data_type, gs.organization_coordsys_id as crs_id  from gpkg_contents gc inner join gpkg_spatial_ref_sys gs where gc.srs_id=gs.srs_id) AS sel "
				+ "ON tm.table_name=sel.table_name " + "WHERE crsID IN (3395, 4326) ORDER BY zoomLvl;";

		Statement ss = this.databaseConnection.createStatement();
		ResultSet rs = ss.executeQuery(queryStr);

		try (final Statement statement = this.databaseConnection.createStatement();
				final ResultSet resultSet = statement.executeQuery(queryStr)) {
			PopulateAnnexC();
			PopulateAnnexE();
			invalidMatrixEntries.clear();

			List<Object[]> table = null;

			while (resultSet.next()) {
				String tabNam = resultSet.getString("tabName").trim();
				String srsID = resultSet.getString("crsID").trim();
				int zoomLvl = resultSet.getInt("zoomLvl");

				long mtrxW = resultSet.getLong("matrixW");
				long mtrxH = resultSet.getLong("matrixH");
				// int tileWidth = resultSet.getInt("tileW" );
				// int tileHeight = resultSet.getInt("tileH");
				double pxlXSz = resultSet.getDouble("pixelSzX");
				double pxlYSz = resultSet.getDouble("pixelSzY");

				if (srsID.equals("3395")) {
					table = this.AnnexC_3395; // --- test for: Req 4
				} else if ((srsID.equals("5041")) || (srsID.equals("5042"))) {
					table = null;
					// --- // --- test for: Req 4
				} else if (srsID.equals("4326")) {
					table = this.AnnexE_4326; // --- test for: Req 5
				} else {
					table = null;
				}

				for (int i = 0; (table != null) && (i < table.size()); i++) {
					Object[] obj = table.get(i);
					if (zoomLvl == (int) obj[0]) {
						long imW = (long) obj[3];
						long imH = (long) obj[4];
						double pX = (double) obj[2];
						double pY = (double) obj[2];

						if (Math.abs(pX - pxlXSz) > this.tolerance) {
							invalidMatrixEntries.add(tabNam + " (" + srsID + ", Zoom Level: " + zoomLvl + "): "
									+ "Pixel Size X: " + pxlXSz + "; but expected " + pX);
						} else if (Math.abs(pY - pxlYSz) > this.tolerance) {
							invalidMatrixEntries.add(tabNam + " (" + srsID + ", Zoom Level: " + zoomLvl + "): "
									+ "Pixel Size Y: " + pxlYSz + "; but expected " + pY);
						} else if (imW != mtrxW) {
							invalidMatrixEntries.add(tabNam + " (" + srsID + ", Zoom Level: " + zoomLvl + "): "
									+ "Matrix Width: " + mtrxW + "; but expected " + imW);
						} else if (imH != mtrxH) {
							invalidMatrixEntries.add(tabNam + " (" + srsID + ", Zoom Level: " + zoomLvl + "): "
									+ "Matrix Height: " + mtrxH + "; but expected " + imH);
						}
					}
				}
			}
			resultSet.close();
			statement.close();

			Assert.assertTrue(invalidMatrixEntries.isEmpty(), MessageFormat.format(
					"The gpkg_tile_matrix table contains invalid Pixels Size or Matrix Size values for tables: {0}",
					invalidMatrixEntries.stream().map(Object::toString).collect(Collectors.joining(", "))));
		}
	}

	// ----------------------------------------------------
	/*
	 * --- NSG Req 6: The WGS 84 Geographic 2D CRS SHALL be used for 2D vector
	 * features. WGS 84 Geographic 2D GeoPackages SHALL follow the technical
	 * guidance provided in Annex E: Implementation Guide for EPSG::4326 Tiles.
	 * 
	 */

	// --- TBD

	// @Test(groups = { "NSG" }, description = "NSG Req 6 (match Annex table)")

	// ----------------------------------------------------
	/*
	 * --- NSG Req 8: The CRS definitions in Table 7 through Table 19 below SHALL be
	 * used to specify the CRS used for tiles and vector feature user data tables
	 * containing NSG data in a GeoPackage.
	 * 
	 * --- NSG Req 9: Other CRS definitions SHALL NOT be specified for GeoPackage
	 * SQL tables containing NSG data.
	 * 
	 */

	@Test(groups = { "NSG" }, description = "NSG Req 8 & 9 (CRS definitions)")
	public void NSG_CRSdefinitionsTest() throws SQLException {
		NodeList crsList = NSG_XMLUtils.openXMLDocument(this.getClass().getResourceAsStream(this.NSG_CRS_listing),
				this.XML_root);
		/*
		 * NodeList crsList = null; if (this._useHardCode) { crsList =
		 * NSG_XMLUtils.openXMLDocString(this.CRS_XML_Str, this.XML_root); } else {
		 * crsList = NSG_XMLUtils.openXMLDocument(this.CRS_XML_Path + "NSG_CRS_WKT.xml",
		 * this.XML_root); }
		 */
		Assert.assertTrue(crsList != null,
				ErrorMessage.format(ErrorMessageKeys.UNDEFINED_SRS, " - no designated CRS Lookup Table"));

		if (crsList != null) {
			String queryStr = "SELECT srs_id,definition FROM gpkg_spatial_ref_sys";

			try (final Statement statement = this.databaseConnection.createStatement();
					final ResultSet resultSet = statement.executeQuery(queryStr)) {
				final Collection<String> invalidSrsDefs = new LinkedList<>();

				while (resultSet.next()) {
					String srsID = resultSet.getString("srs_id").trim();
					if (srsID.equals("0")) {
						continue;
					}
					if (srsID.equals("-1")) {
						continue;
					}

					String srsDef = resultSet.getString("definition").trim().replaceAll("\\s+", "");


					Element element = NSG_XMLUtils.getElement(crsList, "srs_id", srsID);
					if (element != null) {
						String crsDef = NSG_XMLUtils.getXMLElementTextValue(element, "definition").trim()
								.replaceAll("\\s+", "");
						
						System.out.println(crsDef);
						System.out.println(srsDef);

						String code;
						try {
							CoordinateReferenceSystem example = CRS.parseWKT(srsDef);
							code = CRS.lookupIdentifier(example, true);
							CoordinateReferenceSystem crs = CRS.decode(code);
							System.out.println(crs.toString());
						} catch (FactoryException e) {							
							invalidSrsDefs.add(srsID + ":" + srsDef);
							Assert.fail(MessageFormat.format(
								"The gpkg_spatial_ref_sys table contains invalid CRS defintions values for IDs {0}",
								invalidSrsDefs.stream().map(Object::toString).collect(Collectors.joining(", "))));
							e.printStackTrace();
						}

					}
				}
				resultSet.close();
				statement.close();
			}
		}
	}

	// ----------------------------------------------------
	/*
	 * --- NSG Req 19: Data validity SHALL be assessed against data value
	 * constraints specified in Table 26 below using a test suite. Data validity MAY
	 * be enforced by SQL triggers.
	 * 
	 * --- 19-A: Addresses Table 26 Rows 1-2 (regarding table
	 * "gpkg_spatial_ref_sys")
	 */

	@Test(groups = { "NSG" }, description = "NSG Req 19-A (Data Validity: gpkg_spatial_ref_sys)")
	public void NSG_DataValidity() throws SQLException {
		NodeList crsList = NSG_XMLUtils.openXMLDocument(this.getClass().getResourceAsStream(this.NSG_CRS_listing),
				this.XML_root);
		/*
		 * NodeList crsList = null; if (this._useHardCode) { crsList =
		 * NSG_XMLUtils.openXMLDocString(this.CRS_XML_Str, this.XML_root); } else {
		 * crsList = NSG_XMLUtils.openXMLDocument(this.CRS_XML_Path + "NSG_CRS_WKT.xml",
		 * this.XML_root); }
		 */
		Assert.assertTrue(crsList != null,
				ErrorMessage.format(ErrorMessageKeys.UNDEFINED_SRS, " - no designated CRS Lookup Table"));

		if (crsList != null) {
			String queryStr = "SELECT srs_id,organization,description FROM gpkg_spatial_ref_sys;";

			try (final Statement statement = this.databaseConnection.createStatement();
					final ResultSet resultSet = statement.executeQuery(queryStr)) {
				final Collection<String> invalidOrgs = new LinkedList<>();
				final Collection<String> invalidDesc = new LinkedList<>();

				while (resultSet.next()) {
					String srsID = resultSet.getString("srs_id").trim();
					if (srsID.equals("0")) {
						continue;
					}
					if (srsID.equals("-1")) {
						continue;
					}

					// --- test for: Table 26; Row 1

					String srsOrg = resultSet.getString("organization").trim().toUpperCase();
					if (!srsOrg.equals("EPSG") && !srsOrg.equals("NGA")) {
						invalidOrgs.add(srsID + ":" + srsOrg);
					}

					// --- test for: Table 26; Row 2

					String srsDesc = resultSet.getString("description").trim();

					boolean found = false;

					Element element = NSG_XMLUtils.getElement(crsList, "srs_id", srsID);
					if (element != null) {
						if ((srsDesc != null) && (srsDesc.length() > 0)
								&& (!srsDesc.toUpperCase().equalsIgnoreCase("NULL"))
								&& (!srsDesc.toUpperCase().equalsIgnoreCase("UNK"))
								&& (!srsDesc.toUpperCase().equalsIgnoreCase("UNKNOWN"))
								&& (!srsDesc.toUpperCase().equalsIgnoreCase("TBD"))) {
							String crsDesc = NSG_XMLUtils.getXMLElementTextValue(element, "description").trim();
							found = crsDesc.equalsIgnoreCase(srsDesc);
							if (!found && (crsDesc.endsWith(".") || srsDesc.endsWith("."))) {
								if (srsDesc.endsWith("."))
									srsDesc = srsDesc.substring(0, srsDesc.length() - 1);
								if (crsDesc.endsWith("."))
									crsDesc = crsDesc.substring(0, crsDesc.length() - 1);
								found = crsDesc.equalsIgnoreCase(srsDesc);
							}
						}
					}

					if (!found) {
						invalidDesc.add(srsID);
					}
				}
				resultSet.close();
				statement.close();

				Assert.assertTrue(invalidOrgs.isEmpty(), MessageFormat.format(
						"The gpkg_spatial_ref_sys table contains invalid organization values for IDs: {0}, should be \'EPSG\' or \'NGA\'",
						invalidOrgs.stream().map(Object::toString).collect(Collectors.joining(", "))));
				Assert.assertTrue(invalidDesc.isEmpty(),
						MessageFormat.format("The gpkg_spatial_ref_sys table contains invalid desciptions for IDs: {0}",
								invalidDesc.stream().map(Object::toString).collect(Collectors.joining(", "))));
			}
		}
	}

	// ----------------------------------------------------

	// ----------------------------------------------------

}