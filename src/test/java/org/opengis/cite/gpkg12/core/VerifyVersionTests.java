package org.opengis.cite.gpkg12.core;

import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;
import static org.opengis.cite.gpkg12.SuiteAttribute.GPKG_VERSION;
import static org.opengis.cite.gpkg12.SuiteAttribute.TEST_SUBJ_FILE;
import static org.opengis.cite.gpkg12.util.GeoPackageVersion.V102;
import static org.opengis.cite.gpkg12.util.GeoPackageVersion.V110;
import static org.opengis.cite.gpkg12.util.GeoPackageVersion.V120;

import java.io.File;
import java.net.URISyntaxException;
import java.net.URL;

import org.junit.BeforeClass;
import org.junit.Test;
import org.testng.ISuite;
import org.testng.ITestContext;

/**
 * @author <a href="mailto:goltz@lat-lon.de">Lyn Goltz </a>
 */
public class VerifyVersionTests {

	private static ITestContext testContext;

	private static ISuite suite;

	@BeforeClass
	public static void initTestFixture() {
		testContext = mock(ITestContext.class);
		suite = mock(ISuite.class);
		when(testContext.getSuite()).thenReturn(suite);
	}

	@Test
	public void testGeoPackage10() throws Exception {
		mockSuite("gpkg/sample1_0.gpkg");

		VersionTests versionTests = new VersionTests();
		versionTests.initGeoPackageFile(testContext);
		versionTests.geopackageVersion();
		versionTests.storeVersionInTestContext(testContext);

		verify(suite).setAttribute(GPKG_VERSION.getName(), V102);
	}

	@Test
	public void testGeoPackage11() throws Exception {
		mockSuite("gpkg/sample1_1.gpkg");

		VersionTests versionTests = new VersionTests();
		versionTests.initGeoPackageFile(testContext);
		versionTests.geopackageVersion();
		versionTests.storeVersionInTestContext(testContext);

		verify(suite).setAttribute(GPKG_VERSION.getName(), V110);
	}

	@Test
	public void testGeoPackage12() throws Exception {
		mockSuite("gpkg/sample1_2.gpkg");

		VersionTests versionTests = new VersionTests();
		versionTests.initGeoPackageFile(testContext);
		versionTests.geopackageVersion();
		versionTests.storeVersionInTestContext(testContext);

		verify(suite).setAttribute(GPKG_VERSION.getName(), V120);
	}

	private void mockSuite(String geopackage) throws URISyntaxException {
		URL gpkgUrl = ClassLoader.getSystemResource(geopackage);
		File dataFile = new File(gpkgUrl.toURI());
		dataFile.setWritable(false);
		when(suite.getAttribute(TEST_SUBJ_FILE.getName())).thenReturn(dataFile);
	}

}
