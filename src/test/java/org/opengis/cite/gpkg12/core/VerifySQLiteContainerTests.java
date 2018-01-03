package org.opengis.cite.gpkg12.core;

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
import org.opengis.cite.gpkg12.core.SQLiteContainerTests;
import org.testng.ISuite;
import org.testng.ITestContext;

public class VerifySQLiteContainerTests {

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
    public void validHeaderString() throws IOException, SQLException, URISyntaxException {
        URL gpkgUrl = ClassLoader.getSystemResource("gpkg/simple_sewer_features.gpkg");
        File dataFile = new File(gpkgUrl.toURI());
        dataFile.setWritable(false);
        when(suite.getAttribute(SuiteAttribute.TEST_SUBJ_FILE.getName())).thenReturn(dataFile);
        SQLiteContainerTests iut = new SQLiteContainerTests();
        iut.initCommonFixture(testContext);
        iut.fileHeaderString();
    }

    @Test
    public void validApplicationId() throws IOException, SQLException, URISyntaxException {
        URL gpkgUrl = ClassLoader.getSystemResource("gpkg/simple_sewer_features.gpkg");
        File dataFile = new File(gpkgUrl.toURI());
        dataFile.setWritable(false);
        when(suite.getAttribute(SuiteAttribute.TEST_SUBJ_FILE.getName())).thenReturn(dataFile);
        SQLiteContainerTests iut = new SQLiteContainerTests();
        iut.initCommonFixture(testContext);
        iut.applicationID();
    }
}
