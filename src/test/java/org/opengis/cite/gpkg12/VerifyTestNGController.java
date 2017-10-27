package org.opengis.cite.gpkg12;

import static org.junit.Assert.*;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.net.URL;
import java.text.MessageFormat;
import java.util.InvalidPropertiesFormatException;
import java.util.Properties;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.transform.Source;

import net.sf.saxon.s9api.XdmValue;

import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;
import org.opengis.cite.gpkg12.TestNGController;
import org.opengis.cite.gpkg12.TestRunArg;
import org.opengis.cite.gpkg12.util.XMLUtils;
import org.w3c.dom.Document;

/**
 * Verifies the results of executing a test run using the main controller
 * (TestNGController).
 * 
 */
public class VerifyTestNGController {

    private static DocumentBuilder docBuilder;
    private Properties testRunProps;

    @BeforeClass
    public static void initParser() throws ParserConfigurationException {
        DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
        dbf.setNamespaceAware(true);
        dbf.setValidating(false);
        dbf.setFeature("http://apache.org/xml/features/nonvalidating/load-external-dtd", false);
        docBuilder = dbf.newDocumentBuilder();
    }

    @Before
    public void loadDefaultTestRunProperties() throws InvalidPropertiesFormatException, IOException {
        this.testRunProps = new Properties();
        this.testRunProps.loadFromXML(getClass().getResourceAsStream("/test-run-props.xml"));
    }

    @Test
    public void cleanTestRun() throws Exception {
    	
        runTests(ClassLoader.getSystemResource("gpkg/gpkg-test-5208.gpkg"), 0);
        runTests(ClassLoader.getSystemResource("gpkg/gdal_sample_v1.2_spi_nonlinear_webp_elevation.gpkg"), 0);
        runTests(ClassLoader.getSystemResource("gpkg/gdal_sample_v1.2_spatial_index_extension.gpkg"), 0);
        runTests(ClassLoader.getSystemResource("gpkg/gdal_sample_v1.2_no_extensions.gpkg"), 0);
        runTests(ClassLoader.getSystemResource("gpkg/gdal_sample_v1.2_no_extensions_with_gpkg_ogr_contents.gpkg"), 0);
        runTests(ClassLoader.getSystemResource("gpkg/empty.gpkg"), 0);
        runTests(ClassLoader.getSystemResource("gpkg/states10.gpkg"), 0);
        runTests(ClassLoader.getSystemResource("gpkg/bluemarble.gpkg"), 0);
        runTests(ClassLoader.getSystemResource("gpkg/gdal_sample.gpkg"), 0);
        runTests(ClassLoader.getSystemResource("gpkg/elevation.gpkg"), 0); // These two are the id notnull thing
        runTests(ClassLoader.getSystemResource("gpkg/coastline-polyline-hydro-115mil-and-smaller.gpkg"), 0);
        runTests(ClassLoader.getSystemResource("gpkg/v12_bad_attributes.gpkg"), 1); // R119
        runTests(ClassLoader.getSystemResource("gpkg/sample1_0.gpkg"), 1); // R77
        runTests(ClassLoader.getSystemResource("gpkg/simple_sewer_features.gpkg"), 1); // This is an invalid 1.0 or 1.1 GPKG - it has an invalid metadata table (md_standard_URI instead of md_standard_uri) 
        runTests(ClassLoader.getSystemResource("gpkg/sample1_1.gpkg"), 1); // R77
        runTests(ClassLoader.getSystemResource("gpkg/sample1_2.gpkg"), 1); // R77
        runTests(ClassLoader.getSystemResource("gpkg/sample1_2F10.gpkg"), 2); // Default "undefined", R77
        runTests(ClassLoader.getSystemResource("gpkg/geonames_belgium.gpkg"), 3); // lower case data types, R77
        runTests(ClassLoader.getSystemResource("gpkg/haiti-vectors-split.gpkg"), 3); // lower case data types, R77
        runTests(ClassLoader.getSystemResource("gpkg/bentiu_southsudan-osm-20170213.gpkg"), 2); //R5, R29
    }
    private void runTests(URL testSubject, int fails) throws Exception {
        this.testRunProps.setProperty(TestRunArg.IUT.toString(), testSubject.toURI().toString());
        ByteArrayOutputStream outStream = new ByteArrayOutputStream(1024);
        this.testRunProps.storeToXML(outStream, "Integration test");

        Document testRunArgs = docBuilder.parse(new ByteArrayInputStream(outStream.toByteArray()));

        // set up the test controller and run the tests
        TestNGController controller = new TestNGController();
        Source results = controller.doTestRun(testRunArgs);
        String xpath = "/testng-results/@failed";
        XdmValue failed = XMLUtils.evaluateXPath2(results, xpath, null);
        int numFailed = Integer.parseInt(failed.getUnderlyingValue().getStringValue());
        if (fails != numFailed){
        	// Extraneous if allows you to set a breakpoint...
        	assertEquals(MessageFormat.format("Unexpected number of fail verdicts for file {0}.\nSee {1} for details.", testSubject.toString(), results.getSystemId()), fails, numFailed);
        }
    }
}