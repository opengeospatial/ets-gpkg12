package org.opengis.cite.gpkg12.attributes;

import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import java.io.File;
import java.io.IOException;
import java.net.URISyntaxException;
import java.net.URL;
import java.sql.SQLException;

import org.junit.BeforeClass;
import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.ExpectedException;
import org.opengis.cite.gpkg12.SuiteAttribute;
import org.testng.ISuite;
import org.testng.ITestContext;

public class VerifyAttributeTests {

    private static ITestContext testContext;
    private static ISuite suite;
    @Rule
    public ExpectedException thrown = ExpectedException.none();

    @BeforeClass
    public static void initTestFixture() {
        testContext = mock(ITestContext.class);
        suite = mock(ISuite.class);
        when(testContext.getSuite()).thenReturn(suite);
    }

    @Test
    public void attributePrimarykey() throws IOException, SQLException, URISyntaxException {
        URL gpkgUrl = ClassLoader.getSystemResource("gpkg/gdal_sample_v1.2_no_extensions.gpkg");
        File dataFile = new File(gpkgUrl.toURI());
        dataFile.setWritable(false);
        when(suite.getAttribute(SuiteAttribute.TEST_SUBJ_FILE.getName())).thenReturn(dataFile);
        AttributeTests iut = new AttributeTests();
        iut.initCommonFixture(testContext);
        iut.setUp();
        iut.attributeTableIntegerPrimaryKey();
    }

    @Test
    public void attributePrimarykeyBad() throws IOException, SQLException, URISyntaxException {
        URL gpkgUrl = ClassLoader.getSystemResource("gpkg/v12_bad_attributes.gpkg");
        File dataFile = new File(gpkgUrl.toURI());
        dataFile.setWritable(false);
        when(suite.getAttribute(SuiteAttribute.TEST_SUBJ_FILE.getName())).thenReturn(dataFile);
        AttributeTests iut = new AttributeTests();
        iut.initCommonFixture(testContext);
        iut.setUp();
        thrown.expect(AssertionError.class);
        thrown.expectMessage("The features or attributes table attribute_table does not have a primary key. expected [true] but found [false]");
        iut.attributeTableIntegerPrimaryKey();
    }
}
