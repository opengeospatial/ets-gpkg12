package org.opengis.cite.gpkg12.extensions.relatedtables;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

import org.opengis.cite.gpkg12.CommonFixture;
import org.opengis.cite.gpkg12.ErrorMessage;
import org.opengis.cite.gpkg12.ErrorMessageKeys;
import org.opengis.cite.gpkg12.util.DatabaseUtility;
import org.testng.Assert;
import org.testng.ITestContext;
import org.testng.annotations.BeforeClass;

public abstract class RTEBase extends CommonFixture {

	@BeforeClass
	public void activeExtension(ITestContext testContext) throws SQLException {
		Assert.assertTrue(DatabaseUtility.doesTableOrViewExist(this.databaseConnection, "gpkg_extensions"), 
				ErrorMessage.format(ErrorMessageKeys.CONFORMANCE_CLASS_NOT_USED, "Related Tables Extension"));
		
		try (
				final Statement statement = this.databaseConnection.createStatement();
				
				final ResultSet resultSet = statement.executeQuery(
						"SELECT count(*) from gpkg_extensions WHERE extension_name IN ('related_tables', 'gpkg_related_tables');");
				) {
			resultSet.next();
			
			Assert.assertTrue(resultSet.getInt(1) > 0, 
					ErrorMessage.format(ErrorMessageKeys.CONFORMANCE_CLASS_NOT_USED, "Related Tables Extension"));				
		}
	}

}